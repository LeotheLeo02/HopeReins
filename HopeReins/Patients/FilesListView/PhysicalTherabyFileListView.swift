//
//  PhysicalTherabyFileListView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/18/23.
//

import SwiftUI

struct PhysicalTherapyFileListView: View {
    var files: [PatientFile]
    var user: User
    var body: some View {
        ForEach(PhysicalTherabyFormType.allCases, id: \.self) { formType in
            DisclosureGroup(
                content: {
                    filesForPhysicalTherapyForm(formType)
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
    
    private func fileCountFor(_ formType: PhysicalTherabyFormType) -> Int {
        files.filter { file in
            if let fileType = FormType.from(string: file.fileType), case .physicalTherapy(let type) = fileType {
                return type == formType
            }
            return false
        }.count
    }


    @ViewBuilder
    private func filesForPhysicalTherapyForm(_ formType: PhysicalTherabyFormType) -> some View {
        let filteredFiles = files.filter { file in
            if let fileType = FormType.from(string: file.fileType), case .physicalTherapy(let type) = fileType {
                return type == formType
            }
            return false
        }
        ForEach(filteredFiles, id: \.self) { file in
            NavigationLink {
                FormEditView(file: file, user: user)
            } label: {
                UploadedListItem(file: file)
            }
        }
    }
}
