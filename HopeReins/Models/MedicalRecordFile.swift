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
        
        init(id: UUID = UUID(), patient: Patient, fileName: String, fileType: String, digitalSignature: DigitalSignature) {
            self.id = id
            self.patient = patient
            self.fileName = fileName
            self.fileType = fileType
            self.digitalSignature = digitalSignature
        }
    }
    
    
    @Model class DigitalSignature {
        var author: String
        var dateAdded: Date
        
        init(author: String, dateAdded: Date) {
            self.author = author
            self.dateAdded = dateAdded
        }
    }
}
