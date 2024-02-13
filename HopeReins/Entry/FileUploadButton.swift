//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI
import AppKit

struct FileUploadButton: View {
    @Environment(\.isEditable) var isEditable
    @Binding var fileData: Data?
    var body: some View {
        HStack {
            Button {
                openFile()
            } label: {
                Label("Open", systemImage: "doc.fill")
            }
            .buttonStyle(.borderedProminent)
            .padding(.trailing, 7)
            .disabled(fileData == nil)
            
            Button {
                updateFile()
            } label: {
                Label("\(fileData != nil ? "Change" : "Import") File", systemImage: "\(fileData != nil  ? "arrow.left.arrow.right.square.fill" : "square.and.arrow.down.fill")")
            }
            .disabled(!isEditable)

        }
    }

    func openFile() {
        guard let data = fileData, let url = saveToTemporaryFile(data: data) else { return }
        NSWorkspace.shared.open(url)
    }

    func updateFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK, let url = panel.url {
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.fileData = data
                    }
                } catch {
                    DispatchQueue.main.async {
                        // Update the UI to show an error message to the user
                        print("Error reading the file: \(error)")
                    }
                }
            }
        }
    }

}
