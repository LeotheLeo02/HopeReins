//
//  ListItemLabel.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 8/14/24.
//

import SwiftUI

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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
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
            if let dateOfServiceString = formatPerformedDateFromString(from: file.properties["Date of Service"]?.stringValue ?? "") {
                Text("Performed \(dateOfServiceString)")
                    .foregroundStyle(.primary)
                    .font(.callout)
            }
            if isFileEdited {
                fileEditedInfo
            }
            Text(fileAddedInfo)
                .foregroundStyle(dateOfServiceExists ? (isFileEdited ? .tertiary : .secondary) : (isFileEdited ? .secondary : .primary))
                .font(dateOfServiceExists ? (isFileEdited ? .footnote : .subheadline) : (isFileEdited ? .subheadline : .callout))
        }
        .font(.footnote)
    }

    private var fileAddedInfo: String {
        let author = file.addedSignature?.author ?? ""
        
        if let date = file.addedSignature?.dateModified {
            return "Added by \(author) \(formatDate(date))"
        }
        
        return "Invalid Date"
    }

    private var isFileEdited: Bool {
        file.digitalSignature?.modification == .edited
    }

    private var fileEditedInfo: some View {
        VStack {
            Text(fileUpdatedInfo)
                .foregroundStyle(dateOfServiceExists ? .secondary : .primary)
                .font(dateOfServiceExists ? .subheadline : .headline)
        }
    }

    private var fileUpdatedInfo: String {
        let author = file.digitalSignature?.author ?? ""
        
        if let date = file.digitalSignature?.dateModified {
            return "Updated by \(author) \(formatDate(date))"
        }
        
        return "Invalid Date"
    }

    private var dateOfServiceExists: Bool {
        return formatPerformedDateFromString(from: file.properties["Date of Service"]?.stringValue ?? "") != nil
    }
}
