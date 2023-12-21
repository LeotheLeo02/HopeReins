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
        
        init (otherLessonProperties: RidingLessonProperties) {
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
