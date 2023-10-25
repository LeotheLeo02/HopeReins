//
//  PatientDetailView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI
import SwiftData

enum FileType: String {
    case releaseStatement = "ReleaseStatement"
    case coverLetter = "CoverLetter"
}

struct PatientDetailView: View {
    let patientId: UUID
    @Environment(\.modelContext) var modelContext
    @State var showDeleteAlert: Bool = false
    @State var selectedFile: PatientFile?
    @Query(sort: \PatientFile.fileType) private var files: [PatientFile]
    
    init(patientId: UUID) {
        self.patientId = patientId
        let predicate = #Predicate<PatientFile> { patientFile in
            patientFile.patient?.id == patientId
        }
        _files = Query(filter: predicate, sort: \PatientFile.fileType)
    }
    
    var body: some View {
        List(files) { file in
            HStack {
                Button(action: {
                    if let url = saveToTemporaryFile(data: file.data) {
                        NSWorkspace.shared.open(url)
                    }
                }, label: {
                    HStack {
                        if let type = FileType(rawValue: file.fileType) {
                            filePreview(data: file.data)
                            switch type {
                            case .releaseStatement:
                                Text("Release Statement")
                            case .coverLetter:
                                Text("Cover Letter")
                            }
                        } else {
                            Text("Unexpected file type")
                        }
                        Spacer()
                    }
                })
            }
            .contextMenu {
                Button  {
                    selectedFile = file
                    showDeleteAlert.toggle()
                } label: {
                    Text("Delete")
                }

            }
        }
        .alert("Delete \(selectedFile?.fileType ?? "")", isPresented: $showDeleteAlert, actions: {
            Button(role: .destructive) {
                if let _selectedFile = selectedFile {
                    modelContext.delete(_selectedFile)
                }
            } label: {
                Text("Delete")
            }
        })
    }
    
    func saveToTemporaryFile(data: Data) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving to temporary file: \(error)")
            return nil
        }
    }
}

extension PatientDetailView {
    @ViewBuilder func filePreview(data: Data) -> some View {
        if let image = NSImage(data: data) {
            HStack {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 25, height: 25, alignment: .center)
            }
        }
    }
}
