//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

struct FileUploadView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.isEditable) var isEditable: Bool
    @State var fileName: String = ""
    @State var modifiedProperties: UploadFileProperties = UploadFileProperties()
    @State var titleForChange: String = ""
    @State var showChanges: Bool = false
    @State var pastChangesExpanded: Bool = false 
    var uploadFile: UploadFile?
    private var changeDescriptions: [String] {
        guard let oldLessonProperties = uploadFile?.properties else { return [] }
        
        let oldFileName = uploadFile?.medicalRecordFile.fileName ?? "nil"
        let newFileName = fileName
        
        let fileNameChange = (oldFileName != newFileName) ?
            "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\"" : ""
        
        var totalChanges =  UploadFileProperties.compareProperties(old: oldLessonProperties, new: modifiedProperties)
        
        if !fileNameChange.isEmpty {
            totalChanges.append(fileNameChange)
        }
        return totalChanges
    }

    
    var ridingFormType: RidingFormType?
    var phyiscalFormType: PhysicalTherabyFormType?
    
    var patient: Patient?
    var user: User?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if uploadFile != nil {
                    pastChangesView()
                }
                formDetailsView()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text((uploadFile == nil || !changeDescriptions.isEmpty) ? "Cancel" : "Done")
                })
            }
            if uploadFile == nil {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        addFile()
                        try? modelContext.save()
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                    .buttonStyle(.borderedProminent)
                }
            } else if !changeDescriptions.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showChanges.toggle()
                    } label: {
                        Text("Apply Changes")
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
            }
        }
        .sheet(isPresented: $showChanges) {
            ReviewChangesView<UploadFile, FileChange>(
                modifiedProperties: $modifiedProperties,
                record: uploadFile,
                changeDescriptions: changeDescriptions,
                username: user!.username,
                oldFileName: uploadFile!.medicalRecordFile.fileName,
                fileName: fileName
            )
        }
        .onAppear {
            if let uploadFile = uploadFile {
                fileName = uploadFile.medicalRecordFile.fileName
                modifiedProperties = UploadFileProperties(other: uploadFile.properties)
            }
        }
    }
    @ViewBuilder
    func formDetailsView() -> some View {
        BasicTextField(title: "File Name...", text: $fileName)
        FileUploadButton(properties: $modifiedProperties)
    }
    @ViewBuilder
    func pastChangesView() -> some View {
        ScrollView {
            DisclosureGroup(isExpanded: $pastChangesExpanded) {
                ForEach(uploadFile?.pastChanges ?? [], id: \.self) { change in
                    ChangeView<UploadFile, FileChange>(
                        record: uploadFile,
                        fileName: $fileName,
                        modifiedProperties: $modifiedProperties,
                        onRevert: {
                            revertToChange(change: change)
                        }, change: change
                    )
                }
            } label: {
                CustomSectionHeader(title: "Past Changes")
            }
        }
    }
    func revertToChange(change: FileChange) {
        let objectID = change.persistentModelID
        let objectInContext = modelContext.model(for: objectID)
        uploadFile!.pastChanges.removeAll { $0.date == change.date }
        modelContext.delete(objectInContext)
        do {
            try modelContext.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    func addFile() {
        var fileType: String = ""
        if let type = ridingFormType {
            if type == .releaseStatement {
                fileType = type.rawValue
            } else if type == .coverLetter {
                fileType = type.rawValue
            } else if type == .updateCoverLetter {
                fileType = type.rawValue
            }
        } else {
            if let type = phyiscalFormType {
                if type == .referral {
                    fileType = type.rawValue
                }
            }
        }
        let digitalSignature = DigitalSignature(author: user!.username, modification: FileModification.added.rawValue, dateModified: .now)
        modelContext.insert(digitalSignature)
        let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: fileType, digitalSignature: digitalSignature)
        modelContext.insert(medicalRecordFile)
        let properties = UploadFileProperties(other: modifiedProperties)
        modelContext.insert(properties)
        let dataFile = UploadFile(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(dataFile)
        try? modelContext.save()
    }
}

struct FileUploadButton: View {
    @Environment(\.isEditable) var isEditable
    @Environment(\.modelContext) var modelContext
    @Binding var properties: UploadFileProperties
    var body: some View {
        HStack {
            if properties.data != .init() {
                Button {
                    if let url = saveToTemporaryFile(data: properties.data) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open", systemImage: "doc.fill")
                }
                .buttonStyle(.borderedProminent)
                .padding(.trailing, 7)
            }
            Button {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                
                if panel.runModal() == .OK, let url = panel.url {
                    do {
                        properties.data = try Data(contentsOf: url)
                        try modelContext.save()
                    } catch {
                        print("Error reading the file: \(error)")
                    }
                }
            } label: {
                Label("\(properties.data != .init() ? "Change" : "Import") File", systemImage: "\(properties.data != .init()  ? "arrow.left.arrow.right.square.fill" : "square.and.arrow.down.fill")")
            }
            .disabled(!isEditable)
        }
    }
}
