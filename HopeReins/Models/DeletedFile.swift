//
//  DeletedFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/31/23.
//

import SwiftData
import Foundation


extension HopeReinsSchemaV2 {
    
    @Model final class DeletedFile {
        public var id = UUID()
        var file: MedicalRecordFile
        
        init(id: UUID = UUID(), file: MedicalRecordFile) {
            self.id = id
            self.file = file
        }
    }
    
}
