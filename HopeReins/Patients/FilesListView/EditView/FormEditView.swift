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
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    FileUploadView(selectedFileData: $fileData, fileName: $fileName)
                    if !changeDescription.isEmpty {
                        TextField("Reason for Change...", text: $reasonForChange, axis: .vertical)
                        Text(changeDescription)
                            .bold()
                        HStack {
                            Spacer()
                            Button("Save Changes") {
                                do {
                                    let newFileChange = FileChange(fileId: file.id, reason: reasonForChange, date: .now, author: user.username, title: changeDescription)
                                    file.changes.append(newFileChange)
                                    file.data = fileData ?? .init()
                                    file.name = fileName
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
            .navigationTitle(file.name)
        }
        .frame(minWidth: 500, minHeight: 500)
        .onAppear {
            fileData = file.data
            fileName = file.name
        }
    }
}
