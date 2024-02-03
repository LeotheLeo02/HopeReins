//
//  Patient.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import SwiftData
import Foundation

extension HopeReinsSchemaV2 {
    @Model class Patient {
        public var id = UUID()
        var name: String
        var mrn: Int
        var dateOfBirth: Date
        // var personalFile: MedicalRecordFile
        
        @Relationship(deleteRule: .cascade)
        var files = [MedicalRecordFile]()
        
        init(name: String, mrn: Int, dateOfBirth: Date) {
            self.name = name
            self.mrn = mrn
            self.dateOfBirth = dateOfBirth
        }
    }
}
