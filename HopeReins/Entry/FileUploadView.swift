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
    @State var properties: UploadFileProperties
    var uploadFile: UploadFile?
    
    var ridingFormType: RidingFormType?
    var phyiscalFormType: PhysicalTherabyFormType?
    
    var patient: Patient?
    var user: User?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CustomSectionHeader(title: "File Name")
                if let uploadFile = uploadFile {
                    OptionalFileNameField(file: uploadFile.medicalRecordFile)
                } else {
                    TextField("File Name...", text: $fileName, axis: .vertical)
                }
                FileUploadButton(properties: properties)
            }
            .toolbar {
                if uploadFile == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if properties.data != .init() {
                            Button("Save") {
                                addFile()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
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
        let dataFile = UploadFile(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(dataFile)
        try? modelContext.save()
    }
}

struct OptionalFileNameField: View {
    @State var file: MedicalRecordFile
    var body: some View {
        TextField("File Name...", text: $file.fileName, axis: .vertical)
    }
}

struct FileUploadButton: View {
    @Environment(\.modelContext) var modelContext
    @State var properties: UploadFileProperties
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
