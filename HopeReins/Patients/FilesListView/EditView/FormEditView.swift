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
            if let file = file, let formType = determineFormType(from: file) {
                editingViewForFormType(formType)
            }
        }
        .navigationTitle(file?.fileName ?? "")
        .frame(minWidth: 500, minHeight: 500)
        .environment(\.isEditable, isEditable)
    }
    
    private func determineFormType(from file: MedicalRecordFile) -> FormType? {
        if let ridingType = RidingFormType(rawValue: file.fileType) {
            return .riding(ridingType)
        } else if let physicalType = PhysicalTherabyFormType(rawValue: file.fileType) {
            return .physicalTherapy(physicalType)
        }
        else {
            return nil
        }
    }
    
    @ViewBuilder
    private func editingViewForFormType(_ formType: FormType) -> some View {
        switch formType {
        case .riding(let type):
            switch type {
            case .releaseStatement, .coverLetter, .updateCoverLetter:
                if let uploadFile = fetchUploadFile(fileId: file!.id) {
                    EditingView<UploadFile>(
                        modifiedProperties: UploadFileProperties(other: uploadFile.properties),
                        initialFileName: uploadFile.medicalRecordFile.fileName,
                        record: uploadFile,
                        username: user.username
                    )
                }
            case .ridingLessonPlan:
                if let lessonPlan = fetchRidingLessonPlan(fileId: file!.id) {
                    EditingView<RidingLessonPlan>(
                        modifiedProperties: RidingLessonProperties(other: lessonPlan.properties),
                        initialFileName: lessonPlan.medicalRecordFile.fileName,
                        record: lessonPlan,
                        username: user.username
                    )
                }
            }
        case .physicalTherapy(let type):
            Text("Nothing Yet...")
        }
    }
    private func fetchRidingLessonPlan(fileId: UUID) -> RidingLessonPlan? {
        return try? modelContext.fetch(FetchDescriptor<RidingLessonPlan>(predicate: #Predicate { $0.medicalRecordFile.id == fileId })).first
    }
    
    private func fetchUploadFile(fileId: UUID)  -> UploadFile? {
        return try? modelContext.fetch(FetchDescriptor<UploadFile>(predicate: #Predicate { $0.medicalRecordFile.id == fileId })).first
    }
}
