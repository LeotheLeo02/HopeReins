//
//  Utils.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/18/23.
//

import SwiftUI

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
    var file: PatientFile
    var body: some View {
        HStack {
            FilePreview(data: file.data, size: 25)
            Text(file.name)
            Spacer()
            Text("Created By: \(file.author) \(file.dateAdded.formatted())")
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
