//
//  FormEditView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/16/23.
//

import SwiftUI

struct FormEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var file: PatientFile
    var user: User
    @State var reasonForChange: String = ""
    @State var uploadNewFile: Bool = false
    @State var fileData: Data? = .init()
    @State var fileName: String = ""
    var body: some View {
        ScrollView {
            VStack {
                FileUploadView(selectedFileData: $fileData, fileName: $fileName)
                TextField("Reason for Change...", text: $reasonForChange)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 500)
        .onAppear {
            fileData = file.data
            fileName = file.name
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    do {
                        file.data = fileData ?? .init()
                        file.name = fileName
                        try modelContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }
            }
        }
    }
}
