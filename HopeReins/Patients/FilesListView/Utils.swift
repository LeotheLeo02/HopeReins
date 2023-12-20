//
//  Utils.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/18/23.
//

import SwiftUI
import SwiftData

struct FilePreview: View {
    var data: Data
    var size: CGFloat
    var body: some View {
        if let image = NSImage(data: data) {
            HStack {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size, alignment: .center)
            }
        }
    }
}

struct UploadedListItem: View {
    @Environment(\.modelContext) var modelContext
    var file: MedicalRecordFile
    
    var body: some View {
        HStack {
            if let uploadedFile = try? uploadedFile(modelContext: modelContext, fileType: file.fileType, fileId: file.id) {
                FilePreview(data: uploadedFile.properties.data, size: 25)
            }
            Text(file.fileName)
            Spacer()
            Text("Created By: \(file.digitalSignature.author) \(file.digitalSignature.dateAdded.formatted())")
                .font(.caption.italic())
            Image(systemName: "chevron.right")
        }
        .font(.title3)
        .padding()
    }
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

func uploadedFile(modelContext: ModelContext, fileType: String, fileId: UUID) throws ->  UploadFile? {
    if let typeOfFile = RidingFormType(rawValue: fileType) {
        
        switch typeOfFile {
        case .releaseStatement, .coverLetter, .updateCoverLetter:
            let predicate = #Predicate<UploadFile> { uploadedFile in
                uploadedFile.medicalRecordFile.id == fileId
            }
            let uploadedFiles = FetchDescriptor<UploadFile>(predicate: #Predicate { file in
                file.medicalRecordFile.id == fileId
            })
            return try modelContext.fetch(uploadedFiles).first
        case .ridingLessonPlan:
            return nil
        }
    }
    if let typeOfFile = PhysicalTherabyFormType(rawValue: fileType) {
        switch typeOfFile {
        case .referral:
            let predicate = #Predicate<UploadFile> { uploadedFile in
                uploadedFile.medicalRecordFile.id == fileId
            }
            let uploadedFiles = FetchDescriptor<UploadFile>(predicate: #Predicate { file in
                file.medicalRecordFile.id == fileId
            })
            return try modelContext.fetch(uploadedFiles).first
        case .evaluation, .dailyNote, .reEvaluation, .medicalForm, .missedVisit:
            return nil
        }
    }
    return nil
}
