//
//  MedicalRecordFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import SwiftData
import Foundation

extension HopeReinsSchemaV2 {
    
    @Model final class MedicalRecordFile {
        public var id = UUID()
        var patient: Patient
        var fileName: String
        var fileType: String
        var digitalSignature: DigitalSignature
        var isDead: Bool = false
        
        init(id: UUID = UUID(), patient: Patient, fileName: String, fileType: String, digitalSignature: DigitalSignature) {
            self.id = id
            self.patient = patient
            self.fileName = fileName
            self.fileType = fileType
            self.digitalSignature = digitalSignature
        }
        
        init(file: MedicalRecordFile) {
            self.id = file.id
            self.patient = file.patient
            self.fileName = file.fileName
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
        
        func modified() {
            modification = FileModification.edited.rawValue
            dateModified = .now
        }
    }
}
