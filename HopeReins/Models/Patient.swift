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
        var personalFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var files: [MedicalRecordFile] = [MedicalRecordFile]()
        
        init(id: UUID = UUID(), personalFile: MedicalRecordFile) {
            self.id = id
            self.personalFile = personalFile
        }
        
    }
}
