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
    @State var showDeletionConfirmation: Bool = false
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
                        if let fileTypeString = RidingFormType(rawValue: file.fileType) {
                            switch fileTypeString {
                            case .releaseStatement, .coverLetter, .updateCoverLetter:
                                if let uploadFile = try? fetchUploadFile(fileId: file.id) {
                                    modelContext.delete(uploadFile)
                                }
                            case .ridingLessonPlan:
                                if let lessonPlan = try? fetchRidingLessonPlan(fileId: file.id) {
                                    modelContext.delete(lessonPlan)
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    func fetchRidingLessonPlan(fileId: UUID) throws -> RidingLessonPlan? {
        let lessonPlans = FetchDescriptor<RidingLessonPlan>(predicate: #Predicate { file in
            file.medicalRecordFile.id == fileId
        })
        return try modelContext.fetch(lessonPlans).first
    }
    func fetchUploadFile(fileId: UUID) throws -> UploadFile? {
        let uploadFiles = FetchDescriptor<UploadFile>(predicate: #Predicate { file in
            file.medicalRecordFile.id == fileId
        })
        
        return try modelContext.fetch(uploadFiles).first
    }
}
