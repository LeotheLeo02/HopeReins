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
            fileIcon
            fileName
            Spacer()
            fileDetails
        }
        .padding()
    }

    private var fileIcon: some View {
        Group {
            if isUploadFile(fileType: file.fileType) {
                FilePreview(data: fileData, size: 30)
            } else {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundStyle(Color(.primary))
            }
        }
    }

    private var fileData: Data {
        file.properties["File Data"]?.dataValue ?? Data()
    }

    private var fileName: some View {
        Text(file.properties["File Name"]?.stringValue ?? "None")
            .font(.callout)
            .fontWeight(.medium)
    }

    private var fileDetails: some View {
        VStack(alignment: .trailing) {
            Text(fileAddedInfo)
                .fontWeight(.medium)
            if isFileEdited {
                fileEditedInfo
            }
        }
        .font(.footnote)
    }

    private var fileAddedInfo: String {
        let author = file.addedSignature?.author ?? ""
        let date = file.addedSignature?.dateModified.formatted() ?? ""
        return "Added: \(author) \(date)"
    }

    private var isFileEdited: Bool {
        file.digitalSignature?.modification == .edited
    }

    private var fileEditedInfo: some View {
        VStack {
            Text(fileUpdatedInfo)
                .font(.caption.italic())
                .foregroundStyle(.gray)
                .fontWeight(.light)
                .padding(.top, 2)
        }
    }

    private var fileUpdatedInfo: String {
        let author = file.digitalSignature?.author ?? ""
        let date = file.digitalSignature?.dateModified.formatted() ?? ""
        return "Updated: \(author) \(date)"
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

public func isUploadFile(fileType: String) -> Bool {
    
    let specificFileTypes = [
        RidingFormType.releaseStatement.rawValue,
        RidingFormType.coverLetter.rawValue,
        PhysicalTherapyFormType.referral.rawValue,
        PhysicalTherapyFormType.medicalForm.rawValue,
        PhysicalTherapyFormType.missedVisit.rawValue
    ]

    return specificFileTypes.contains(fileType)
}
