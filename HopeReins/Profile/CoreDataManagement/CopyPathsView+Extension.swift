//
//  MainView+Extension.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/16/23.
//

import SwiftUI
import SwiftData
import CryptoKit

extension CopyPathsView {
    func copyCoreDataContainerPath() {
        if let configuration = modelContext.container.configurations.first {
            let pathString = configuration.url.absoluteString
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(pathString, forType: .string)
        }
    }
    
    func copyBackUpFolderPath(selectedURL: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        var pathString = selectedURL.path
        pathString.append("/")
        pasteboard.setString(pathString, forType: .string)
    }
    
    func decryptBackup(atUrl url: URL, withKey key: SymmetricKey) throws -> Data {
        let encryptedData = try Data(contentsOf: url)
        let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
        return try ChaChaPoly.open(sealedBox, using: key)
    }
    
    func loadFromKeychain(for account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    func replaceCoreDataFile() {
        let keyAccount = "com.HopeReins.encryptionKey"
        var encryptionKey: SymmetricKey?
        if let encryptionKeyData = loadFromKeychain(for: keyAccount) {
            encryptionKey = SymmetricKey(data: encryptionKeyData)
            print("Key is found! \(encryptionKeyData.description)")

            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.title = "Select a CoreData File Directory"

            if openPanel.runModal() == .OK, let selectedURL = openPanel.urls.first {
                let fileManager = FileManager.default
                do {
                    let contents = try fileManager.contentsOfDirectory(at: selectedURL, includingPropertiesForKeys: nil, options: [])
                    modelContext.container.deleteAllData()
                    for fileURL in contents {
                        let fileName = fileURL.lastPathComponent
                        if fileName.hasSuffix(".encrypted") {
                            let decryptedData = try decryptBackup(atUrl: fileURL, withKey: encryptionKey!)
                            
                            let originalFileName = String(fileName.dropLast(10))
                            
                            let destinationURL = modelContext.container.configurations.first?.url.deletingLastPathComponent().appendingPathComponent(originalFileName)
                            try? fileManager.removeItem(at: destinationURL!)
                            try decryptedData.write(to: destinationURL!, options: .atomic)
                        }
                    }
                    print("Core Data files replaced successfully.")
                } catch {
                    print("Error processing files: \(error)")
                }
            }
        }
    }



}
