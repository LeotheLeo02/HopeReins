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
                FilePreview(data: uploadedFile.properties.data, size: 30)
            } else {
                Image(systemName: "doc.fill")
                    .font(.title3)
                    .foregroundStyle(Color(.primary))
            }
            Text(file.fileName)
            Spacer()
            Text("\(file.digitalSignature.modification) By: \(file.digitalSignature.author) \(file.digitalSignature.dateModified.formatted())")
                .font(.caption2.italic())
        }
        .font(.subheadline.bold())
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
