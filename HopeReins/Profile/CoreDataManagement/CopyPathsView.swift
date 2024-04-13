//
//  ContentView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import CoreData

struct CopyPathsView: View {
    @Environment(\.modelContext) var modelContext
    var body: some View {
        VStack(alignment: .leading) {
            Text("Configure Backup Operations:")
                .bold()
            Button {
                copyCoreDataContainerPath()
            } label: {
                Label("Copy CoreData Container Path", systemImage: "doc.on.doc")
            }
            Button {
                let openPanel = NSOpenPanel()
                openPanel.canChooseFiles = false
                openPanel.canChooseDirectories = true
                openPanel.allowsMultipleSelection = false
                openPanel.title = "Select a Folder"
                
                if openPanel.runModal() == .OK, let selectedURL = openPanel.urls.first {
                    copyBackUpFolderPath(selectedURL: selectedURL)
                }
            } label: {
                Label("Select and Copy Backup Folder Path", systemImage: "folder.fill")
            }
            Button {
                replaceCoreDataFile()
            } label: {
                Label("Select and Replace CoreData File", systemImage: "arrow.right.arrow.left.square")
            }
        }
        .padding()
    }
}

