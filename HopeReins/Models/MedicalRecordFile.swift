//
//  MedicalRecordFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import SwiftData
import Foundation
import SwiftUI

extension HopeReinsSchemaV2 {
    
    @Model final class MedicalRecordFile {
        public var id = UUID()
        var properties: [String: CodableValue] = [:]
        @Relationship(deleteRule: .cascade)
        var pastChanges: [PastChange] = []
        var patient: Patient
        var fileType: String
        var digitalSignature: DigitalSignature?
        var isDead: Bool = false
        
        init(id: UUID = UUID(), patient: Patient, fileType: String) {
            self.id = id
            self.patient = patient
            self.fileType = fileType
            self.digitalSignature = digitalSignature
        }
        
        init(file: MedicalRecordFile) {
            self.id = file.id
            self.patient = file.patient
            self.fileType = file.fileType
            self.digitalSignature = file.digitalSignature
        }
    }
    
    
    @Model class DigitalSignature {
        var author: String
        var modification: String
        var dateModified: Date
        
        init(author: String, modification: String, dateModified: Date) {
            self.author = author
            self.modification = modification
            self.dateModified = dateModified
        }
        
        func modified(by _: String) {
            modification = FileModification.edited.rawValue
            dateModified = .now
        }
        
        func created(by _: String) {
            modification = FileModification.added.rawValue
            dateModified = .now
        }
    }
}


extension MedicalRecordFile {
    func compareProperties(with other: [String: CodableValue]) -> [ChangeDescription] {
        var changes = [ChangeDescription]()

        for (key, newValue) in self.properties {
            if let oldValue = other[key], newValue != oldValue {
                changes.append(ChangeDescription(id: key, oldValue: oldValue, value: newValue))
            }
        }
        
        return changes
    }
    
    func addPastChanges(reason: String, changes: [ChangeDescription], author: String, modelContext: ModelContext) {
        let codableChanges = changes.reduce(into: [String: CodableValue]()) { result, change in
            result[change.id] = change.oldValue
        }


        let newChange = PastChange(date: Date.now, reason: reason, propertyChanges: codableChanges, author: author)
        self.pastChanges.append(newChange)

        try? modelContext.transaction {
            modelContext.insert(newChange)
            updateProperties(changes: changes, author: author, modelContext: modelContext)
        }
    }

    
    func updateProperties(changes: [ChangeDescription], author: String, modelContext: ModelContext) {
        changes.forEach { change in
            self.properties[change.id] = change.value
        }

        self.digitalSignature?.modified(by: author)
        try? modelContext.save()
    }

    
    func revertToPastChange(fieldId: String?, pastChange: PastChange, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        if revertToAll {
            pastChange.propertyChanges.forEach { id, value in
                self.properties[id] = value
            }
            self.pastChanges.removeAll { $0 == pastChange }
            modelContext.delete(pastChange)
        } else if let fieldId = fieldId, let value = pastChange.propertyChanges[fieldId] {
            self.properties[fieldId] = value
            pastChange.propertyChanges.removeValue(forKey: fieldId)
            return pastChange.propertyChanges.isEmpty
        }

        try? modelContext.save()
        return false
    }


}


extension MedicalRecordFile {
    func getRidingLessonPlan() -> [DynamicUIElement] {
        let uiElements : [DynamicUIElement] = [
            .textField(title: "File Name", binding: stringBinding(for: "File Name")),
            .customView(title: "Instructor Name", viewProvider: {
                AnyView(InstructorsMenu(instructorName: self.stringBinding(for: "Instructor Name")))
            }),
            .datePicker(title: "Date", hourAndMinute: false, binding: dateBinding(for: "Date")),
            .textField(title: "Objective", binding: stringBinding(for: "Objective")),
            .textField(title: "Preparation", binding: stringBinding(for: "Preparation")),
            .textField(title: "Content", binding: stringBinding(for: "Content")),
            .textField(title: "Summary", binding: stringBinding(for: "Summary")),
            .textField(title: "Goals", binding: stringBinding(for: "Goals")),
        ]
        return uiElements
    }
}

extension MedicalRecordFile {

    private func stringBinding(for key: String, defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: { self.properties[key]?.stringValue ?? defaultValue },
            set: { self.properties[key] = .string($0) }
        )
    }

    private func intBinding(for key: String, defaultValue: Int = 0) -> Binding<Int> {
        Binding<Int>(
            get: { self.properties[key]?.intValue ?? defaultValue },
            set: { self.properties[key] = .int($0) }
        )
    }

    private func dataBinding(for key: String, defaultValue: Data = .init()) -> Binding<Data> {
        Binding<Data>(
            get: { self.properties[key]?.dataValue ?? defaultValue },
            set: { self.properties[key] = .data($0) }
        )
    }
    
    private func dateBinding(for key: String, defaultValue: Date = .now) -> Binding<Date> {
        Binding<Date>(
            get: { self.properties[key]?.dateValue ?? defaultValue },
            set: { self.properties[key] = .date($0) }
        )
    }
}
