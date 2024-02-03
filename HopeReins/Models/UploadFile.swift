//
//  UploadFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData
import SwiftUI

extension HopeReinsSchemaV2 {
    
//    @Model final class UploadFile: Reflectable {
//        func getDynamicUIElements() -> [DynamicUIElement] {
//            return []
//        }
//        
//        var properties: [String : CodableValue]
//        var pastChanges: [PastChange] = []
//        var medicalRecordFile: MedicalRecordFile
////        @Relationship(deleteRule: .cascade)
////        var properties: UploadFileProperties
//
//        
//        init(medicalRecordFile: MedicalRecordFile, properties: [String: CodableValue]) {
//            self.medicalRecordFile = medicalRecordFile
//            self.properties = properties
//        }
////        
////        func revertToProperties(fileName: String, modelContext: ModelContext) {
////            self.medicalRecordFile.fileName = fileName
////            self.medicalRecordFile.digitalSignature.modified()
////            try? modelContext.save()
////        }
//        
//    }
//    
//    @Model final class UploadFileProperties: Reflectable, ResettableProperties, DynamicUIRepresentable {
//        var properties: [String : CodableValue] = [:]
//        
//        var pastChanges: [PastChange] = []
//        
//        func getDynamicUIElements() -> [DynamicUIElement] {
//            return [ .customView(title: "Data", viewProvider: {
//                AnyView(FileUploadButton(fileData: Binding( get: { self.data }, set: { self.data = $0 })))
//            })]
//        }
//        
//        public var id = UUID()
//        var data: Data
//        
//        
//        init(id: UUID = UUID(), data: Data) {
//            self.id = id
//            self.data = data
//        }
//        
//        init (other: UploadFileProperties) {
//            self.data = other.data
//            self.id = other.id
//        }
//        
//        init() {
//            self.id = UUID()
//            self.data = .init()
//        }
//        
//        func toDictionary() -> [String : Any] {
//            return [
//                "data": data,
//            ]
//        }
//    }
    
    @Model final class FileChange {
        
        init() {
            
        }
//        var id: UUID = UUID()
//        
//        typealias PropertiesType = UploadFileProperties
//        var properties: UploadFileProperties
//        var fileName: String
//        var changeDescriptions: [String]
//        var title: String
//        var author: String
//        var date: Date
//    
//        
//        init(properties: UploadFileProperties, fileName: String, title: String, changeDescriptions: [String], author: String, date: Date) {
//            self.properties = properties
//            self.fileName = fileName
//            self.changeDescriptions = changeDescriptions
//            self.title = title
//            self.author = author
//            self.date = date
//        }
    }
}
