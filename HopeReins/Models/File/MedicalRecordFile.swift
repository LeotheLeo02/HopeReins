//
//  MedicalRecordFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import SwiftData
import Foundation
import SwiftUI

extension HopeReinsSchemaV2 {
    
    @Model final class MedicalRecordFile {
        public var id = UUID()
        var properties: [String: CodableValue] = [:]
        @Relationship(deleteRule: .cascade)
        var versions: [Version] = []
        var patient: Patient?
        var fileType: String
        var digitalSignature: DigitalSignature?
        var addedSignature: DigitalSignature?
        var isDead: Bool = false
        
        init(id: UUID = UUID(), fileType: String) {
            self.id = id
            self.fileType = fileType
        }
        
        func setUpSignature(addedBy username: String, modelContext: ModelContext) {
            let modificationSig = DigitalSignature(author: username)
            let addedSig = DigitalSignature(author: username)
            modelContext.insert(modificationSig)
            modelContext.insert(addedSig)
            self.digitalSignature = modificationSig
            self.addedSignature = addedSig
        }
    }
    
    
    @Model class DigitalSignature {
        var author: String
        var modification: FileModification = FileModification.added
        var dateModified: Date = Date.now
        
        init(author: String) {
            self.author = author
            dateModified = .now
        }
        
        func modified(by _: String) {
            modification = .edited
            dateModified = .now
        }
        
    }
}


struct FormSection {
    let title: String
    let elements: [DynamicUIElement]
}

extension Data {
    func toBase64String() -> String {
        return self.base64EncodedString()
    }
}

extension String {
    func fromBase64String() -> Data? {
        return Data(base64Encoded: self)
    }
}
