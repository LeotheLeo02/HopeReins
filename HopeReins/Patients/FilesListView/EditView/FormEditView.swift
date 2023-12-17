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
    var uploadFile: UploadFile?
    let fileId: UUID
    var user: User
    var isUploadedFile : Bool {
        return uploadFile != nil
    }
    @Query(sort: \FileChange.date) var fileChanges: [FileChange]
    @State var reasonForChange: String = ""
    @State var uploadNewFile: Bool = false
    @State var fileData: Data? = nil
    @State var fileName: String = ""
    init(file: MedicalRecordFile, uploadedFile: UploadFile? = nil,  user: User) {
        self.file = file
        self.fileId = file.id
        self.user = user
        self.uploadFile = uploadedFile
        let predicate = #Predicate<FileChange> { fileChange in
            fileChange.fileId == fileId
        }
        _fileChanges = Query(filter: predicate, sort: \FileChange.date)
    }

    private var changeDescription: String {
        var description = ""

        if file.fileName != fileName {
            description += "Changed File Name"
        }

        if  uploadFile?.data != fileData {
            if !description.isEmpty {
                description += " and "
            }
            description += "Changed File"
        }

        return description
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    CustomSectionHeader(title: "File Name")
                    TextField("File Name...", text: $fileName, axis: .vertical)
                    InputtedFileType(fileData: $fileData, user: user, fileTypeString: file.fileType, fileId: file.id, medicalFile: file)
                }
                .padding(.vertical)
            }
            .padding()
            .navigationTitle(file.fileName)
        }
        .frame(minWidth: 500, minHeight: 500)
        .onAppear {
            fileData = uploadFile?.data
            fileName = file.fileName
        }
    }
}

struct InputtedFileType: View {
    @Environment(\.modelContext) var modelContext
    @Binding var fileData: Data?
    var user: User
    var fileTypeString: String
    var fileId: UUID
    var medicalFile: MedicalRecordFile
    var body: some View {
        VStack {
            if let fileTypeString = RidingFormType(rawValue: fileTypeString) {
                switch fileTypeString {
                case .releaseStatement, .coverLetter, .updateCoverLetter:
                    FileUploadButton(selectedFileData: $fileData)
                case .ridingLessonPlan:
                    if let lessonPlan =  try? fetchRidingLessonPlan() {
                        RidingLessonPlanView(mockLessonPlan: MockRidingLesson(lessonPlan: lessonPlan, patient: medicalFile.patient, username: user.username), isAddingPlan: false, lessonPlan: lessonPlan, username: user.username)
                    }
                }
            }
            
        }
    }
    func fetchRidingLessonPlan() throws -> RidingLessonPlan? {
        let lessonPlans = FetchDescriptor<RidingLessonPlan>(predicate: #Predicate { file in
            file.medicalRecordFile.id == fileId
        })
        return try modelContext.fetch(lessonPlans).first
    }
}
