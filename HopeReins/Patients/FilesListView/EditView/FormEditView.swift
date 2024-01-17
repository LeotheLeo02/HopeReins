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
    @Binding var file: MedicalRecordFile?
    @State var isEditable: Bool
    var user: User
    var body: some View {
        VStack {
            if let file  = file {
                InputtedFileType(user: user, fileTypeString: file.fileType, medicalFile: file)
                    .environment(\.isEditable, isEditable)
            }
        }
        .navigationTitle(file?.fileName ?? "")
        .frame(minWidth: 500, minHeight: 500)
    }
}

struct InputtedFileType: View {
    @Environment(\.isEditable) var isEditable: Bool
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
                        EditingView<UploadFile>(modifiedProperties: UploadFileProperties(other: uploadFile.properties), initialFileName: uploadFile.medicalRecordFile.fileName, record: uploadFile, username: user.username)
                    }
                case .ridingLessonPlan:
                    if let lessonPlan = try? fetchRidingLessonPlan(fileId: medicalFile.id) {
                        RidingLessonPlanView(lessonPlan: lessonPlan, username: user.username)
                    }
                }
            } else if let fileTypeString = PhysicalTherabyFormType(rawValue: fileTypeString) {
                switch fileTypeString {
                case .referral:
                    if let uploadFile = try? fetchUploadFile(fileId: medicalFile.id) {
                        EditingView<UploadFile>(modifiedProperties: UploadFileProperties(other: uploadFile.properties), initialFileName: uploadFile.medicalRecordFile.fileName, record: uploadFile, username: user.username)
                    }
                case  .dailyNote, .evaluation, .reEvaluation, .medicalForm, .missedVisit:
                    Text("Nothing")
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
