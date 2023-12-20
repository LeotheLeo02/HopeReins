//
//  UploadFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData

extension HopeReinsSchemaV2 {
    
    @Model final class UploadFile {
        @Relationship(deleteRule: .cascade)
        var medicalRecordFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var pastChanges: [FileChange] = [FileChange]()
        @Relationship(deleteRule: .cascade)
        var properties: UploadFileProperties

        
        init(medicalRecordFile: MedicalRecordFile, properties: UploadFileProperties) {
            self.medicalRecordFile = medicalRecordFile
            self.properties = properties
        }
    }
    
    @Model final class UploadFileProperties {
        public var id = UUID()
        var data: Data
        
        
        init(id: UUID = UUID(), data: Data) {
            self.id = id
            self.data = data
        }
        
        init() {
            self.id = UUID()
            self.data = .init()
        }
    }
    
    @Model class FileChange {
        var properties: UploadFileProperties
        var reason: String
        var date: Date
        var author: String
        var title: String
    
        init(properties: UploadFileProperties, reason: String, date: Date, author: String, title: String) {
            self.properties = properties
            self.reason = reason
            self.date = date
            self.author = author
            self.title = title
        }
    }
}
