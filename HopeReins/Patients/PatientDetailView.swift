//
//  PatientDetailView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

enum FileType: String {
    case releaseStatement = "ReleaseStatement"
    case coverLetter = "CoverLetter"
}

struct PatientDetailView: View {
    @State private var selectedFileURL: URL?
    var patient: Patient
    
    var body: some View {
        ScrollView {
            ForEach(patient.files) { file in
                if let type = FileType(rawValue: file.fileType) {
                    switch type {
                    case .releaseStatement:
                        filePreview(data: file.data)
                    case .coverLetter:
                        filePreview(data: file.data)
                    }
                } else {
                    Text("Unexpected file type")
                }
            }
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
}

extension PatientDetailView {
    @ViewBuilder func filePreview(data: Data) -> some View {
        if let image = NSImage(data: data) {
            Button(action: {
                if let url = saveToTemporaryFile(data: data) {
                    self.selectedFileURL = url
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Text(patient.name)
                    Spacer()
                }
                .padding()
            }
        }
    }
}
