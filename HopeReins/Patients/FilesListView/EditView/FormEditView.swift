//
//  FormEditView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/16/23.
//

import SwiftUI
import SwiftData

struct FormEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var file: MedicalRecordFile
    var user: User
    init(file: MedicalRecordFile,  user: User) {
        self.user = user
        self.file = file
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    InputtedFileType(user: user, fileTypeString: file.fileType, medicalFile: file)
                }
                .padding(.vertical)
            }
            .padding()
            .navigationTitle(file.fileName)
        }
        .frame(minWidth: 500, minHeight: 500)
    }
}

struct InputtedFileType: View {
    @Environment(\.modelContext) var modelContext
    var user: User
    var fileTypeString: String
    var medicalFile: MedicalRecordFile
    var body: some View {
        VStack {
            if let fileTypeString = RidingFormType(rawValue: fileTypeString) {
                switch fileTypeString {
                case .releaseStatement, .coverLetter, .updateCoverLetter:
                    if let uploadFile = try? fetchUploadFile(fileId: medicalFile.id) {
                        FileUploadView(uploadFile: uploadFile, user: user)
                    }
                case .ridingLessonPlan:
                    if let lessonPlan = try? fetchRidingLessonPlan(fileId: medicalFile.id) {
                        RidingLessonPlanView(lessonPlan: lessonPlan, username: user.username)
                    }
                }
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
