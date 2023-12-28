//
//  RidingFileListView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/18/23.
//

import SwiftUI
import SwiftData

struct RidingFileListView: View {
    @Environment(\.modelContext) var modelContext
    @State var showEditSheet: Bool = false
    @State var selectedFile: MedicalRecordFile? = nil
    var files: [MedicalRecordFile]
    var user: User
    var body: some View {
        ForEach(RidingFormType.allCases, id: \.self) { formType in
            DisclosureGroup(
                content: {
                    filesForRidingForm(formType)
                },
                label: {
                    HStack {
                        Text(formType.rawValue)
                        Image(systemName: "\(fileCountFor(formType)).circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            )
        }
        .sheet(isPresented: $showEditSheet, content: {
            FormEditView(file: $selectedFile, user: user)
        })
    }
    private func fileCountFor(_ formType: RidingFormType) -> Int {
        files.filter { file in
            if let fileType = FormType.from(string: file.fileType), case .riding(let type) = fileType {
                return type == formType
            }
            return false
        }.count
    }
    @ViewBuilder func filesForRidingForm(_ formType: RidingFormType) -> some View {
        ForEach(files.filter {file in
            return file.fileType == formType.rawValue
        }) { file in
            Button {
                selectedFile = file
                showEditSheet.toggle()
            } label: {
                UploadedListItem(file: file)
            }
        }
    }
}
