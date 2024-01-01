//
//  FileListView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/1/24.
//

import SwiftUI

struct FileListView: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedFile: MedicalRecordFile? = nil
    @State var showEditSheet: Bool = false
    @State var showDeletionConfirmation: Bool = false
    var files: [MedicalRecordFile]
    var user: User
    var formType: FormType
    var isEditable: Bool

    
    func cases(for formType: FormType) -> [String] {
        switch formType {
        case .physicalTherapy(_):
            return PhysicalTherabyFormType.allCases.map { $0.rawValue }
        case .riding(_):
            return RidingFormType.allCases.map { $0.rawValue }
        }
    }

    var body: some View {
        VStack {
            let nestedCases = cases(for: formType)
            ForEach(nestedCases, id: \.self) { nestedCase in
                DisclosureGroup {
                    ForEach(filesForForm(formTypeRaw: nestedCase), id: \.id) { file in
                        Button {
                            selectedFile = file
                            showEditSheet.toggle()
                        } label: {
                            UploadedListItem(file: file)
                        }
                        .contextMenu {
                            if user.isAdmin {
                                Button {
                                    showDeletionConfirmation.toggle()
                                } label: {
                                    Text("Delete File")
                                }
                            }
                        }
                        .alert(isPresented: $showDeletionConfirmation) {
                            Alert(
                                title: Text("Confirm Delete"),
                                message: Text("Are you sure you want to delete \"\(file.fileName)\"? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    file.isDead = true
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text(nestedCase)
                        Image(systemName: "\(fileCountFor(formTypeRaw: nestedCase)).circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet, content: {
            FormEditView(file: $selectedFile, isEditable: isEditable, user: user)
        })
    }

    // Update your helper functions to use a raw value (String) of the nested enum
    private func fileCountFor(formTypeRaw: String) -> Int {
        files.filter { $0.fileType == formTypeRaw }.count
    }

    private func filesForForm(formTypeRaw: String) -> [MedicalRecordFile] {
        files.filter { $0.fileType == formTypeRaw }
    }
}
