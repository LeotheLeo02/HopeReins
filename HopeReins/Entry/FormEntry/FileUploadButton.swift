//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//
import SwiftUI

struct FileUploadButton: View {
    @Environment(\.isEditable) var isEditable
    @Binding var fileData: Data?
    @State private var showingFileImporter = false
    
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
                showingFileImporter = true
            } label: {
                Label("\(fileData != nil ? "Change" : "Import") File", systemImage: "\(fileData != nil ? "arrow.left.arrow.right.square.fill" : "square.and.arrow.down.fill")")
            }
            .disabled(!isEditable)
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.data]) { result in
            do {
                 let newURL = try result.get()
                self.fileData = try Data(contentsOf: newURL)
            } catch {
                print("Error importing file: \(error)")
            }
        }
    }
    
    func openFile() {
        guard let data = fileData, let url = saveToTemporaryFile(data: data) else { return }
        NSWorkspace.shared.open(url)
    }
}
