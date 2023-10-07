//
//  HomeView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/7/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \ReleaseStatement.id, order: .forward)
    var releaseStatements: [ReleaseStatement]

    @State private var selectedFileURL: URL?
    

    var body: some View {
        List(releaseStatements) { releaseStatement in
            if let image = NSImage(data: releaseStatement.data) {
                Button(action: {
                    if let url = saveToTemporaryFile(data: releaseStatement.data) {
                        self.selectedFileURL = url
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
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
