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
                    fileChangeAddress()
                }
                .padding(.vertical)
                CustomSectionHeader(title: "Past Changes")
                ForEach(fileChanges) { fileChange in
                    HStack {
                        VStack(alignment: .listRowSeparatorLeading) {
                            Text(fileChange.title)
                                .font(.title3.bold())
                            Text(fileChange.reason)
                                .italic()
                                .fontWeight(.light)
                        }
                        Spacer()
                        Text("Modified by \(fileChange.author) \(fileChange.date.formatted())")
                            .font(.caption.italic())
                    }
                }
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
    @ViewBuilder func fileChangeAddress() -> some View {
        if !changeDescription.isEmpty {
            TextField("Reason for Change...", text: $reasonForChange, axis: .vertical)
            Text(changeDescription)
                .bold()
            HStack {
                Spacer()
                Button("Save Changes") {
                    do {
                        let newFileChange = FileChange(fileId: file.id, reason: reasonForChange, date: .now, author: user.username, title: changeDescription)
                        file.fileChanges.append(newFileChange)
                        if isUploadedFile {
                            uploadFile?.data = fileData ?? .init()
                        }
                        file.fileName = fileName
                        try modelContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(reasonForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
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
                        RidingLessonPlanView(mockLessonPlan: MockRidingLesson(lessonPlan: lessonPlan, patient: medicalFile.patient, username: user.username))
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
