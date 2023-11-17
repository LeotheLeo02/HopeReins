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
    var file: PatientFile
    let fileId: UUID
    var user: User
    @Query(sort: \FileChange.date) var fileChanges: [FileChange]
    @State var reasonForChange: String = ""
    @State var uploadNewFile: Bool = false
    @State var fileData: Data? = .init()
    @State var fileName: String = ""
    init(file: PatientFile, user: User) {
        self.file = file
        self.fileId = file.id
        self.user = user
        let predicate = #Predicate<FileChange> { fileChange in
            fileChange.fileId == fileId
        }
        _fileChanges = Query(filter: predicate, sort: \FileChange.date)
    }

    private var changeDescription: String {
        var description = ""

        if file.name != fileName {
            description += "Changed File Name"
        }

        if  file.data != fileData {
            if !description.isEmpty {
                description += " and "
            }
            description += "Changed File"
        }

        return description
    }
    var body: some View {
        ScrollView {
            VStack {
                FileUploadView(selectedFileData: $fileData, fileName: $fileName)
                TextField("Reason for Change...", text: $reasonForChange)
                Text(changeDescription)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    Spacer()
                    Button("Done") {
                        do {
                            let newFileChange = FileChange(fileId: file.id, reason: reasonForChange, date: .now, author: user.username, title: changeDescription)
                            file.changes.append(newFileChange)
                            file.data = fileData ?? .init()
                            file.name = fileName
                            try modelContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        dismiss()
                    }
                }
                ForEach(fileChanges) { fileChange in
                    HStack {
                        Text(fileChange.reason)
                        Spacer()
                        Text(fileChange.date.formatted())
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 500)
        .onAppear {
            fileData = file.data
            fileName = file.name
        }
    }
}
