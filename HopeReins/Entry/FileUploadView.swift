//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

struct FileUploadView: View {
    // TODO: Add drag and drop interactivity
    @Environment(\.modelContext) var modelContext
    @State private var selectedFileName: String? = nil
    @Binding var selectedFileData: Data?
    @Binding var fileName: String
    private var selectedImage: Image? {
        if let data = selectedFileData, let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TextField("File Name...", text: $fileName, axis: .vertical)
                Button {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.canChooseFiles = true
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        selectedFileName = url.lastPathComponent
                        do {
                            selectedFileData = try Data(contentsOf: url)
                        } catch {
                            print("Error reading the file: \(error)")
                        }
                    }
                } label: {
                    Label("\((selectedFileData != nil) ? "Change" : "Import") File", systemImage: "square.and.arrow.down.fill")
                }
                if let image = selectedImage {
                    Button {
                        if let _selectedFileData = selectedFileData, let url = saveToTemporaryFile(data: _selectedFileData) {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(width: 250, height: 250)
                            .shadow(radius: 5)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
        }
            .navigationTitle("Release Statement")
    }
}
