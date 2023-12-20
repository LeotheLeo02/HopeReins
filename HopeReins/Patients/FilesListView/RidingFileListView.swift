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
            NavigationLink {
                FormEditView(file: file, user: user)
            } label: {
                UploadedListItem(file: file)
            }
        }
    }
}
