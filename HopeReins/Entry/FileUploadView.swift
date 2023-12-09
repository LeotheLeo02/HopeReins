//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

struct FileUploadView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var selectedFileData: Data?
    @Binding var fileName: String
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CustomSectionHeader(title: "File Name")
                TextField("File Name...", text: $fileName, axis: .vertical)
                FileUploadView(selectedFileData: $selectedFileData, fileName: $fileName)
            }
        }
    }
}

struct FileUploadButton: View {
    @Binding var selectedFileData: Data?
    @State private var selectedFileName: String? = nil
    var body: some View {
        HStack {
            if selectedFileData != nil {
                Button {
                    if let _selectedFileData = selectedFileData, let url = saveToTemporaryFile(data: _selectedFileData) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open", systemImage: "doc.fill")
                }
                .buttonStyle(.borderedProminent)
                .padding(.trailing, 7)
            }
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
                Label("\(selectedFileData != nil ? "Change" : "Import") File", systemImage: "\(selectedFileData != nil ? "arrow.left.arrow.right.square.fill" : "square.and.arrow.down.fill")")
            }
        }
    }
}
