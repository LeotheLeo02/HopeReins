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

import SwiftUI
struct EditablePropertyView<T: Equatable>: View {
    @Binding var value: T
    let propertyName: String
    
    var body: some View {
        if case let boolValue as Bool = value { } else {
            CustomSectionHeader(title: propertyName)
        }
        switch value {
        case is String:
            TextField(propertyName, text: $value as! Binding<String>)
        case is Date:
            DatePicker(propertyName, selection: $value as! Binding<Date>)
        case is Bool:
            Toggle(isOn: $value as! Binding<Bool>, label: {
                Text(propertyName)
            })
        default:
            Text("Unsupported property type")
        }
    }
}

struct RidingLessonView: View {
    @Binding var instructorName: String
    @Binding var date: Date

    var body: some View {
        Form {
            EditablePropertyView(value: $instructorName, propertyName: "Instructor Name")
            EditablePropertyView(value: $date, propertyName: "Date")
            // ... other properties
        }
    }
}
