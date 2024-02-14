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
        var isDead: Bool = false
        
        init(id: UUID = UUID(), fileType: String) {
            self.id = id
            self.fileType = fileType
            self.digitalSignature = digitalSignature
        }
        
        init(file: MedicalRecordFile) {
            self.id = file.id
            self.fileType = file.fileType
            self.digitalSignature = file.digitalSignature
        }
    }
    
    
    @Model class DigitalSignature {
        var author: String
        var modification: String
        var dateModified: Date
        
        init(author: String, modification: String, dateModified: Date) {
            self.author = author
            self.modification = modification
            self.dateModified = dateModified
        }
        
        func modified(by _: String) {
            modification = FileModification.edited.rawValue
            dateModified = .now
        }
        
        func created(by _: String) {
            modification = FileModification.added.rawValue
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
