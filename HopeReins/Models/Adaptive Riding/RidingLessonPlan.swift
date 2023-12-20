//
//  RidingLesson.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData

extension HopeReinsSchemaV2 {
    
    @Model final class RidingLessonPlan {
        @Relationship(deleteRule: .cascade)
        var medicalRecordFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var pastChanges: [PastChangeRidingLessonPlan] = [PastChangeRidingLessonPlan]()
        @Relationship(deleteRule: .cascade)
        var properties: RidingLessonProperties
        
        init(medicalRecordFile: MedicalRecordFile, properties: RidingLessonProperties) {
            self.medicalRecordFile = medicalRecordFile
            self.properties = properties
        }
        
    }
    
    @Model final class RidingLessonProperties {
        var instructorName: String
        var date: Date
        var objective: String
        var preparation: String
        var content: String
        var summary: String
        var goals: String
        
        init () {
            self.instructorName = ""
            self.date = .now
            self.objective = ""
            self.preparation = ""
            self.content = ""
            self.summary = ""
            self.goals = ""
        }
        
        init(initialProperties: InitialProperties) {
            self.instructorName = initialProperties.instructorName
            self.date = initialProperties.date
            self.objective = initialProperties.objective
            self.preparation = initialProperties.preparation
            self.content = initialProperties.content
            self.summary = initialProperties.summary
            self.goals = initialProperties.goals
        }
    }
    
    @Model final class PastChangeRidingLessonPlan {
        var properties: RidingLessonProperties
        var fileName: String
        var changeDescription: String
        var reason: String
        var author: String
        var date: Date
        
        init(properties: RidingLessonProperties, fileName: String, changeDescription: String, reason: String, author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.changeDescription = changeDescription
            self.reason = reason
            self.author = author
            self.date = date
        }
    }
}
