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
    @State var fileName: String = ""
    @State var modifiedProperties: UploadFileProperties = UploadFileProperties()
    @State var titleForChange: String = ""
    var uploadFile: UploadFile?
    private var changeDescription: String {
        guard let oldLessonProperties = uploadFile?.properties else { return "" }
        
        let oldFileName = uploadFile?.medicalRecordFile.fileName ?? "nil"
        let newFileName = fileName
        
        let fileNameChange = (oldFileName != newFileName) ?
            "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\", " : ""
        
        return fileNameChange + UploadFileProperties.compareProperties(old: oldLessonProperties, new: modifiedProperties)
    }

    
    var ridingFormType: RidingFormType?
    var phyiscalFormType: PhysicalTherabyFormType?
    
    var patient: Patient?
    var user: User?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CustomSectionHeader(title: "File Name")
                TextField("File Name...", text: $fileName, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                FileUploadButton(properties: $modifiedProperties)
                if uploadFile != nil {
                    if !changeDescription.isEmpty {
                        TextField("Reason for Change...", text: $titleForChange, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                        Text(changeDescription)
                            .bold()
                        Button("Save Changes") {
                            do {
                                let newFileChange = FileChange(properties: uploadFile!.properties, fileName: uploadFile!.medicalRecordFile.fileName, changeDescription: changeDescription, title: titleForChange, author: user!.username, date: .now)
                                uploadFile!.pastChanges.append(newFileChange)
                                uploadFile!.medicalRecordFile.fileName = fileName
                                uploadFile!.properties = modifiedProperties
                                try modelContext.save()
                                modifiedProperties = UploadFileProperties(otherProperties: uploadFile!.properties)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(titleForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    CustomSectionHeader(title: "Past Changes")
                    if let uploadFile = uploadFile {
                        ForEach(uploadFile.pastChanges) { change in
                            HStack {
                                VStack {
                                    Text(change.fileName)
                                    Text(change.date.description)
                                }
                                Spacer()
                                Button("Revert To") {
                                    do {
                                        revertLessonPlan(otherProperties: change.properties, otherFileName: change.fileName)
                                        uploadFile.pastChanges.removeAll(where: { element in
                                            return element.date == change.date
                                        })
                                        modelContext.delete(change)
                                        try modelContext.save()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            if uploadFile == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addFile()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear {
            if let uploadFile = uploadFile {
                fileName = uploadFile.medicalRecordFile.fileName
                modifiedProperties = UploadFileProperties(otherProperties: uploadFile.properties)
            }
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
        let digitalSignature = DigitalSignature(author: user!.username, dateAdded: .now)
        modelContext.insert(digitalSignature)
        let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: fileType, digitalSignature: digitalSignature)
        modelContext.insert(medicalRecordFile)
        let properties = UploadFileProperties(otherProperties: modifiedProperties)
        modelContext.insert(properties)
        let dataFile = UploadFile(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(dataFile)
        try? modelContext.save()
    }
    func revertLessonPlan(otherProperties: UploadFileProperties, otherFileName: String) {
        let oldProperties = uploadFile!.properties
        uploadFile!.properties = otherProperties
        modelContext.delete(oldProperties)
        uploadFile!.medicalRecordFile.fileName = otherFileName
        fileName = otherFileName
        modifiedProperties = UploadFileProperties(otherProperties: uploadFile!.properties)
        try? modelContext.save()
    }
}

struct FileUploadButton: View {
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
        }
    }
}

struct InitialUploadFileProperties {
    var fileName: String =  ""
    var data: Data = .init()
    
    init () { }
    
    
    init(fileName: String, properties: UploadFileProperties) {
        self.fileName = fileName
        self.data = properties.data
    }
}
