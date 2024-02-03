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

struct ListItemLabel: View {
    @Environment(\.modelContext) var modelContext
    var file: MedicalRecordFile
    
    var body: some View {
        HStack {
            if isUploadFile(fileType: file.fileType) {
                FilePreview(data: file.properties["Data"]!.dataValue, size: 30)
            } else {
                Image(systemName: "doc.fill")
                    .font(.title3)
                    .foregroundStyle(Color(.primary))
            }
            Text(file.properties["File Name"]?.stringValue ?? "None")
            Spacer()
            Text("\(file.digitalSignature?.modification ?? "") By: \(file.digitalSignature?.author ?? "") \(file.digitalSignature?.dateModified.formatted() ?? "")")
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

func isUploadFile(fileType: String) -> Bool {
    
    let specificFileTypes = [
        RidingFormType.releaseStatement.rawValue,
        RidingFormType.coverLetter.rawValue,
        RidingFormType.updateCoverLetter.rawValue,
        PhysicalTherabyFormType.referral.rawValue
    ]

    return specificFileTypes.contains(fileType)
}
