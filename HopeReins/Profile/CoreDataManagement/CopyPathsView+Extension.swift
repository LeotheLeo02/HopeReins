//
//  MainView+Extension.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/16/23.
//

import SwiftUI

extension CopyPathsView {
    func copyCoreDataContainerPath() {
        let directoryURL = persistentStoreURL?.deletingLastPathComponent()
        var pathString = directoryURL?.path ?? ""
        pathString.append("/")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(pathString, forType: .string)
    }
    
    func copyBackUpFolderPath(selectedURL: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        var pathString = selectedURL.path
        pathString.append("/")
        pasteboard.setString(pathString, forType: .string)
    }
}
