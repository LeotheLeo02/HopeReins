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
    private var selectedImage: Image? {
        if let data = selectedFileData, let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return nil
    }
    init(selectedFileData: Binding<Data?>) {
        self._selectedFileData = selectedFileData
    }

    var body: some View {
            VStack(spacing: 20) {
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
                    Label("\((selectedFileName != nil) ? "Change" : "Import") File", systemImage: "square.and.arrow.down.fill")
                }
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Release Statement")
    }
}
