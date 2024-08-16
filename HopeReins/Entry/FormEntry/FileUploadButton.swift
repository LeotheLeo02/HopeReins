//
//  FileUploadView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//
import UniformTypeIdentifiers
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
                Text("Open")
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
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.data, UTType(filenameExtension: "docx")!, UTType(filenameExtension: "xlsx")!]) { result in
            do {
                let newURL = try result.get()
                let fileType = UTType(filenameExtension: newURL.pathExtension) ?? .data
                let fileData = try Data(contentsOf: newURL)
                self.fileData = encodeDataFile(data: fileData, fileType: fileType)
            } catch {
                print("Error importing file: \(error)")
            }
        }
    }
    
    func openFile() {
        guard let encodedData = fileData, let encodedFile = decodeDataFile(from: encodedData), let url = saveToTemporaryFile(data: encodedFile.data, fileType: encodedFile.fileType) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private func saveToTemporaryFile(data: Data, fileType: UTType?) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileExtension = fileType?.preferredFilenameExtension ?? "data"
        let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
        
        do {
            try data.write(to: tempFileURL)
            return tempFileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    func encodeDataFile(data: Data, fileType: UTType) -> Data? {
        let encodedFile = EncodedFile(data: data, type: fileType)
        let encoder = JSONEncoder()
        return try? encoder.encode(encodedFile)
    }
    
    func decodeDataFile(from data: Data) -> EncodedFile? {
        let decoder = JSONDecoder()
        return try? decoder.decode(EncodedFile.self, from: data)
    }
}
