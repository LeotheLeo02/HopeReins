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
    var patient: Patient

    private var fileGroups: [(String, [MedicalRecordFile])] {
        cases(for: formType).map { formTypeRaw in
            (formTypeRaw, filesForForm(formTypeRaw: formTypeRaw))
        }
    }

    var body: some View {
        VStack {
            if fileGroups.allSatisfy({ $0.1.isEmpty }) {
                emptyStateView
            } else {
                fileGroupsView
            }
        }
        .sheet(isPresented: $showEditSheet, content: {
            FormEditView(file: $selectedFile, isEditable: isEditable, user: user, patient: patient)
        })
    }
    
    private var fileGroupsView: some View {
        ForEach(fileGroups, id: \.0) { group in
            if !group.1.isEmpty {
                fileGroupDisclosureGroup(group)
            }
        }
    }
    
    
    private var emptyStateView: some View {
        HStack {
            Spacer()
            Label("No \(isEditable ? "" : "Deleted") Files Here...", systemImage: "tray.fill")
                .font(.title3.bold())
                .foregroundStyle(.gray)
                .padding()
            Spacer()
        }
    }

    private func fileGroupDisclosureGroup(_ group: (String, [MedicalRecordFile])) -> some View {
        DisclosureGroup {
            ForEach(group.1, id: \.id) { file in
                fileButton(file)
            }
        } label: {
            Label(group.0, systemImage: "\(group.1.count).circle.fill")
                .font(.headline)
        }
    }

    private func fileButton(_ file: MedicalRecordFile) -> some View {
        Button {
            selectedFile = file
            showEditSheet.toggle()
        } label: {
            ListItemLabel(file: file)
        }
        .contextMenu {
            if user.isAdmin {
                if file.isDead {
                    recoverFileButton(file)
                } else {
                    deleteFileButton(file)
                }
            }
        }
        .alert(isPresented: $showDeletionConfirmation) {
            deleteFileAlert(file)
        }
    }

    private func recoverFileButton(_ file: MedicalRecordFile) -> some View {
        Button(action: {
            file.isDead = false
        }, label: {
            Text("Recover File")
        })
    }
    
    private func deleteFileButton(_ file: MedicalRecordFile) -> some View {
        Button {
            showDeletionConfirmation.toggle()
        } label: {
            Text("Delete File")
        }
    }

    private func deleteFileAlert(_ file: MedicalRecordFile) -> Alert {
        Alert(
            title: Text("Confirm Delete"),
            message: Text("Are you sure you want to delete \"\(file.properties["File Name"]!.stringValue)\"? This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                file.isDead = true
            },
            secondaryButton: .cancel()
        )
    }


    private func cases(for formType: FormType) -> [String] {
        var formTypes: [String]
        switch formType {
        case .physicalTherapy(_):
            formTypes = PhysicalTherapyFormType.allCases.map { $0.rawValue }
            // Replace "Plan of Care" and "Re-Evaluation" with "POC Summary and Revaluation"
            if let pocIndex = formTypes.firstIndex(of: PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue) {
                formTypes[pocIndex] = "POC Summary and Revaluation"
            }
            if let reEvalIndex = formTypes.firstIndex(of: PhysicalTherapyFormType.reEvaluation.rawValue) {
                formTypes.remove(at: reEvalIndex)
            }
        case .riding(_):
            formTypes = RidingFormType.allCases.map { $0.rawValue }
        }
        return formTypes
    }



    private func filesForForm(formTypeRaw: String) -> [MedicalRecordFile] {
        let filteredFiles: [MedicalRecordFile]
        if formTypeRaw == "POC Summary and Revaluation" {
            // Include both "Plan of Care" and "Re-Evaluation" files in this group
            filteredFiles = files.filter {
                $0.fileType == PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue ||
                $0.fileType == PhysicalTherapyFormType.reEvaluation.rawValue
            }
        } else {
            filteredFiles = files.filter { $0.fileType == formTypeRaw }
        }
        
        let sortedFiles = filteredFiles.sorted {
            $0.addedSignature!.dateModified > $1.addedSignature!.dateModified
        }

        return sortedFiles
    }


}
