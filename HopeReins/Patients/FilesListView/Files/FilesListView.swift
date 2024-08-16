//
//  FilesListView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 8/11/24.
//

import SwiftUI

struct FileListView: View {
    @State var showDeletionConfirmation: Bool = false
    @State var selectedFile: MedicalRecordFile?
    @State var showEditSheet: Bool = false
    var group: (String, [MedicalRecordFile])
    var user: User
    var files: [MedicalRecordFile]
    var isEditable: Bool
    var patient: Patient
    var body: some View {
        List {
            ForEach(Array(group.1.enumerated()), id: \.element.id) { index, file in
                VStack {
                    ListItemLabel(file: file)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundStyle(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.white.opacity(0.00001))
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                selectedFile = file
                                showDeletionConfirmation.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onTapGesture {
                    selectedFile = file
                    showEditSheet.toggle()
                }
                .listRowSeparator(.hidden)
            }
            .font(.title2)
            .fontWeight(.medium)
        }
        .navigationTitle(group.0 + "s")
        .sheet(isPresented: $showEditSheet, content: {
            FormEditView(file: $selectedFile, isEditable: isEditable, user: user, patient: patient, files: files)
        })
        .alert(isPresented: $showDeletionConfirmation) {
            deleteFileAlert(selectedFile!)
        }

    }
    private func deleteFileAlert(_ file: MedicalRecordFile) -> Alert {
        Alert(
            title: Text("Confirm Deletion"),
            message: Text("Are you sure you want to delete \"\(selectedFile!.properties["File Name"]!.stringValue)\"?"),
            primaryButton: .destructive(Text("Move to Trash")) {
                selectedFile!.isDead = true
            },
            secondaryButton: .cancel()
        )
    }
}
