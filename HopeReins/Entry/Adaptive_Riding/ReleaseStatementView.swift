//
//  ReleaseStatementView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct ReleaseStatementView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedFileName: String? = nil
    @State private var selectedFileData: Data? = nil

    var body: some View {
        VStack(spacing: 20) {
            Button("Select File") {
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
            }
            
            if let name = selectedFileName, let data = selectedFileData {
                Text("Selected File: \(name)")
                Button("Save") {
                    let releaseStatement = ReleaseStatement(data: data)
                    modelContext.insert(releaseStatement)
                }
            }
        }
        .padding()
    }
}


#Preview {
    RidingFormView(rideFormType: .releaseStatement)
}
