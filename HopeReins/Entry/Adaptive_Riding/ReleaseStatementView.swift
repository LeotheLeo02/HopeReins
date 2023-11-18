//
//  ReleaseStatementView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct ReleaseStatementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var selectedFileData: Data? = nil
    @State private var fileName: String = ""
    var ridingFormType: RidingFormType?
    var phyiscalFormType: PhysicalTherabyFormType?
    var patient: Patient
    var user: User
    var body: some View {
        VStack(spacing: 20) {
            FileUploadView(selectedFileData: $selectedFileData, fileName: $fileName)
        }
        .padding()
        .navigationTitle("Upload File")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if let data = selectedFileData {
                    Button("Save") {
                        addFile(data: data)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    func addFile(data: Data) {
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
        let fileToAdd = PatientFile(data: data, fileType: fileType, name: fileName, author: user.username, dateAdded: .now)
        modelContext.insert(fileToAdd)
        patient.files.append(fileToAdd)
        fileToAdd.patient = patient
    }
}
