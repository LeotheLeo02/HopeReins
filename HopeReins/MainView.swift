//
//  ContentView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var persistentStoreURL: URL? {
        PersistenceController.shared.persistentStoreURL
    }

    var body: some View {
        VStack {
            Text("Configure Backup Operations:")
                    .bold()
            Button {
                let directoryURL = persistentStoreURL?.deletingLastPathComponent()
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(directoryURL?.path ?? "", forType: .string)
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
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(selectedURL.path, forType: .string)
                }
            } label: {
                Label("Select and Copy Backup Folder Path", systemImage: "folder.fill")
            }
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
