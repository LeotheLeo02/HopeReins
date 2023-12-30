//
//  UploadFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData

extension HopeReinsSchemaV2 {
    
    @Model final class UploadFile: Revertible, ChangeRecordable {
        func revertToProperties(_ properties: UploadFileProperties, fileName: String, modelContext: ModelContext) {
            self.properties = properties
            self.medicalRecordFile.fileName = fileName
            try? modelContext.save()
        }
        
        typealias PropertiesType = UploadFileProperties
        
        func addChangeRecord(_ change: FileChange, modelContext: ModelContext) {
            pastChanges.append(change)
            try? modelContext.save()
        }
        
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
    
    @Model final class UploadFileProperties: Reflectable, ResettableProperties {
        public var id = UUID()
        var data: Data
        
        
        init(id: UUID = UUID(), data: Data) {
            self.id = id
            self.data = data
        }
        
        init (other: UploadFileProperties) {
            self.data = other.data
            self.id = other.id
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
    
    @Model final class FileChange: SnapshotChange {
        typealias PropertiesType = UploadFileProperties
        var properties: UploadFileProperties
        var fileName: String
        var changeDescription: String
        var title: String
        var author: String
        var date: Date
    
        
        init(properties: UploadFileProperties, fileName: String, title: String, changeDescription: String, author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.changeDescription = changeDescription
            self.title = title
            self.author = author
            self.date = date
        }
    }
}
