//
//  ContentView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import CoreData

struct CopyPathsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var persistentStoreURL: URL? {
        PersistenceController.shared.persistentStoreURL
    }

    var body: some View {
        VStack {
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
        }
        .padding()
    }
}

struct CopyDataPathsView_Previews: PreviewProvider {
    static var previews: some View {
        CopyPathsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
