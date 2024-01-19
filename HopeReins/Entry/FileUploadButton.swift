//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI

struct FileUploadButton: View {
    @Environment(\.isEditable) var isEditable
    @Environment(\.modelContext) var modelContext
    @Binding var properties: UploadFileProperties
    var body: some View {
        HStack {
            if properties.data != .init() {
                Button {
                    if let url = saveToTemporaryFile(data: properties.data) {
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
                    do {
                        properties.data = try Data(contentsOf: url)
                        try modelContext.save()
                    } catch {
                        print("Error reading the file: \(error)")
                    }
                }
            } label: {
                Label("\(properties.data != .init() ? "Change" : "Import") File", systemImage: "\(properties.data != .init()  ? "arrow.left.arrow.right.square.fill" : "square.and.arrow.down.fill")")
            }
            .disabled(!isEditable)
        }
    }
}
