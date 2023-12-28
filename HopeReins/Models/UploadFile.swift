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
    
    @Model final class UploadFileProperties: Reflectable {
        public var id = UUID()
        var data: Data
        
        
        init(id: UUID = UUID(), data: Data) {
            self.id = id
            self.data = data
        }
        
        init (otherProperties: UploadFileProperties) {
            self.data = otherProperties.data
            self.id = otherProperties.id
        }
        
        init() {
            self.id = UUID()
            self.data = .init()
        }
        
        func toDictionary() -> [String : Any] {
            return [
                "data": data,
            ]
        }
    }
    
    @Model class FileChange {
        var properties: UploadFileProperties
        var fileName: String
        var changeDescription: String
        var title: String
        var author: String
        var date: Date
    
        
        init(properties: UploadFileProperties, fileName: String, changeDescription: String, title: String, author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.changeDescription = changeDescription
            self.title = title
            self.author = author
            self.date = date
        }
    }
}
