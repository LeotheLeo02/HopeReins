//
//  RidingLesson.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData
import SwiftUI

extension HopeReinsSchemaV2 {
    
    @Model final class RidingLessonPlan: Revertible, ChangeRecordable {
        typealias PropertiesType = RidingLessonProperties
        
        @Attribute(.unique) var id: UUID = UUID()
        var medicalRecordFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var pastChanges: [PastChangeRidingLessonPlan] = [PastChangeRidingLessonPlan]()
        @Relationship(deleteRule: .cascade)
        var properties: RidingLessonProperties
        
        init(medicalRecordFile: MedicalRecordFile, properties: RidingLessonProperties) {
            self.medicalRecordFile = medicalRecordFile
            self.properties = properties
        }
        
        func addChangeRecord(_ change: PastChangeRidingLessonPlan, modelContext: ModelContext) {
            pastChanges.append(change)
            self.medicalRecordFile.digitalSignature.modified()
            try? modelContext.save()
        }
        
        func revertToProperties(_ properties: RidingLessonProperties, fileName: String, modelContext: ModelContext) {
            self.properties = properties
            self.medicalRecordFile.fileName = fileName
            self.medicalRecordFile.digitalSignature.modified()
            try? modelContext.save()
        }
    }
    
    @Model final class RidingLessonProperties: Reflectable, ResettableProperties {
        @Attribute(.unique) var id: UUID = UUID()
        var instructorName: String
        var date: Date
        var objective: String
        var preparation: String
        var content: String
        var summary: String
        var goals: String
        
        init (other otherLessonProperties: RidingLessonProperties) {
            self.instructorName = otherLessonProperties.instructorName
            self.date = otherLessonProperties.date
            self.objective = otherLessonProperties.objective
            self.preparation = otherLessonProperties.preparation
            self.content = otherLessonProperties.content
            self.summary = otherLessonProperties.summary
            self.goals = otherLessonProperties.goals
        }
        
        init () {
            instructorName = ""
            date = .now
            objective = ""
            preparation = ""
            content = ""
            summary = ""
            goals = ""
        }
        
        func toDictionary() -> [String : Any] {
            return [
                "Instructor Name": instructorName,
                "Date": date,
                "Objective": objective,
                "Preparation": preparation,
                "Content": content,
                "Summary": summary,
                "Goals": goals
            ]
        }

    }
    
    @Model final class PastChangeRidingLessonPlan: SnapshotChange {
        typealias PropertiesType = RidingLessonProperties
        var properties: RidingLessonProperties
        var fileName: String
        var title: String
        var changeDescriptions: [String]
        var author: String
        var date: Date
        
        init(properties: RidingLessonProperties, fileName: String, title: String, changeDescriptions: [String], author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.title = title
            self.changeDescriptions = changeDescriptions
            self.author = author
            self.date = date
        }
    }
}

