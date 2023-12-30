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
        
        func addChangeRecord(_ change: PastChangeRidingLessonPlan, modelContext: ModelContext) {
            pastChanges.append(change)
            try? modelContext.save()
        }
        
        func revertToProperties(_ properties: RidingLessonProperties, fileName: String, modelContext: ModelContext) {
            self.properties = properties
            self.medicalRecordFile.fileName = fileName
            try? modelContext.save()
        }
        
        @Attribute(.unique) var id: UUID = UUID()
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
        var changeDescription: String
        var author: String
        var date: Date
        
        init(properties: RidingLessonProperties, fileName: String, title: String, changeDescription: String, author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.title = title
            self.changeDescription = changeDescription
            self.author = author
            self.date = date
        }
    }
}


//struct RevertChangeView<Record: ChangeRecordable & Revertible>: View where Record.ChangeType: SnapshotChange, Record.PropertiesType == Record.ChangeType.PropertiesType {
//    @Binding var record: Record
//
//    var body: some View {
//        List(record.pastChanges, id: \.date) { change in
//            Text(change.title)
//            Button("Revert to this Version") {
//                record.revertToProperties(change, fileName: change.fileName, modelContext: modelContext)
//            }
//        }
//    }
//}

protocol ChangeRecordable {
    associatedtype ChangeType
    var pastChanges: [ChangeType] { get set }
    func addChangeRecord(_ change: ChangeType, modelContext: ModelContext)
}


protocol Revertible {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get set }
    mutating func revertToProperties(_ properties: PropertiesType, fileName: String, modelContext: ModelContext)
}

protocol SnapshotChange {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get }
    var fileName: String { get }
    var title: String { get }
    var changeDescription: String { get }
    var author: String { get }
    var date: Date { get }

    init(properties: PropertiesType, fileName: String, title: String, changeDescription: String, author: String, date: Date)
}


protocol ResettableProperties {
    init()
    init(other: Self)
}
