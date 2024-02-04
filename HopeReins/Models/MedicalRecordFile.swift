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



struct FormSection {
    let title: String
    let elements: [DynamicUIElement]
}

extension MedicalRecordFile {
    func getRidingLessonPlan() -> [FormSection] {
        let uiElements : [FormSection] = [
            FormSection(title: "Riding Lesson Plan", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .customView(title: "Instructor Name", viewProvider: {
                    AnyView(InstructorsMenu(instructorName: self.stringBinding(for: "Instructor Name")))
                }),
                .datePicker(title: "Date", hourAndMinute: false, binding: dateBinding(for: "Date")),
                .textField(title: "Objective", binding: stringBinding(for: "Objective")),
                .textField(title: "Preparation", binding: stringBinding(for: "Preparation")),
                .textField(title: "Content", binding: stringBinding(for: "Content")),
                .textField(title: "Summary", binding: stringBinding(for: "Summary")),
                .textField(title: "Goals", binding: stringBinding(for: "Goals"))
            ])
        ]
        return uiElements
    }
}

extension MedicalRecordFile {

    private func stringBinding(for key: String, defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: {
                if self.properties[key] == nil {
                    self.properties[key] = .string(defaultValue)
                }
                return self.properties[key]?.stringValue ?? defaultValue
            },
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

    
    func getEvaluation() -> [FormSection]{
        let uiElements: [FormSection] = [
            FormSection(title: "Personal Info", elements: [
                .textField(title: "Education Level:", binding: stringBinding(for: "Education Level")),
                .textField(title: "Extracurricular:", binding: stringBinding(for: "Extracurricular")),
                .textField(title: "Home Barrier:", binding: stringBinding(for: "Home Barrier")),
                .textField(title: "Past medical and/or rehab history:", binding: stringBinding(for: "Past Medical History")),
                .textField(title: "Surgical History:", binding: stringBinding(for: "Surgical History")),
                .textField(title: "Medications:", binding: stringBinding(for: "Medications")),
                .textField(title: "Vision:", binding: stringBinding(for: "Vision")),
                .textField(title: "Hearing:", binding: stringBinding(for: "Hearing")),
                .textField(title: "Speech/Communications:", binding: stringBinding(for: "Speech Communications")),
                .textField(title: "Seizures:", binding: stringBinding(for: "Seizures")),
            ]),
            FormSection(title: "A/Prom", elements: [
                .textField(title: "Upper Extremity:", binding: stringBinding(for: "A Upper Extremity")),
                .textField(title: "Lower Extremity:", binding: stringBinding(for: "A Lower Extremity")),
            ]),
            FormSection(title: "Strength", elements: [
                .textField(title: "Upper Extremities:", binding: stringBinding(for: "S Upper Extremity")),
                .textField(title: "Lower Extremities:", binding: stringBinding(for: "S Lower Extremity")),
                .textField(title: "Trunk Musculature:", binding: stringBinding(for: "Trunk Musculature")),
                .leRomTable(title: "LE Strength and ROM Table:", combinedString: stringBinding(for: "LE Strength and ROM Table:")),
                .singleSelectDescription(titles: ["Pain"], labels: ["No", "Yes"], combinedString: stringBinding(for: "Pain"), isDescription: true)
            ]),
            FormSection(title: "Neurological Functioning", elements: [
                .singleSelectDescription(titles: ["Tone"], labels: ["WNL", "Hypotonic", "Fluctuating", "NT"], combinedString: stringBinding(for: "Tone"), isDescription: true),
                .singleSelectDescription(titles: ["Sensation"], labels: ["WNL", "Hyposensitive", "Hypersensitive", "Absent", "NT"], combinedString: stringBinding(for: "Sensation"), isDescription: true),
                .singleSelectDescription(titles: ["Reflexes"], labels: ["WNL", "Hyporesponse", "Hyperresponse", "Deficits", "NT"], combinedString: stringBinding(for: "Reflexes"), isDescription: true),
                .singleSelectDescription(titles: ["Protective Extension", "Righting", "Equilibrium", "Praxis"], labels: ["WNL", "Deficient", "Emerging", "Absent", "NT"], combinedString: stringBinding(for: "Protective Extension to Praxis"), isDescription: true),
                .textField(title: "Notes:", binding: stringBinding(for: "Neurological Notes")),
                .textField(title: "Toileting", binding: stringBinding(for: "Toileting")),
            ]),
            FormSection(title: "Coordination", elements: [
                .singleSelectDescription(titles: ["Upper Extremities", "Lower Extremities"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "Coordination Extremities"), isDescription: true),
                .textField(title: "Notes", binding: stringBinding(for: "Coordination Notes")),
                .singleSelectDescription(titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "Endurance"), isDescription: true)
            ]),
            FormSection(title: "Endurance", elements: [
                .singleSelectDescription(titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "Endurance"), isDescription: true)
            ]),
            FormSection(title: "Balance", elements: [
                .singleSelectDescription(titles: ["Sit Static", "Sit Dynamic", "Stance Static", "Stance Dynamic"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "Balance"), isDescription: true),
                .textField(title: "Notes", binding: stringBinding(for: "Balance Notes"))
            ]),
            FormSection(title: "Current Equipment", elements: [
                .multiSelectWithTitle(combinedString: stringBinding(for: "Current Equipment"), labels: ["Orthotics", "Wheelchair", "Bath Equipment", "Glasses", "Augmentative Communication Device", "Walking Device", "Training Aids", "Other"], title: "Current Equipment")
            ]),
            FormSection(title: "Mobility", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "Locomotion"), labels: ["Ambulation", "Non-Mobile", "Wheel Chair"], title: "Locomotion"),
                .multiSelectWithTitle(combinedString: stringBinding(for: "Assistance & Distance"), labels: ["Independent", "Supervision for safety", "Minimal", "Maximal", "SBA", "CGA", "Moderate", "Dependent"], title: "Assistance & Distance"),
                .singleSelectDescription(titles: ["Level", "Ramp", "Curb", "Stairs", "Uneven terrain"], labels: ["Independent", "SBA", "CGA", "Min", "Mod", "Max"], combinedString: stringBinding(for: "Surfaces"), isDescription: true),
                .textField(title: "Gait Deviations", binding: stringBinding(for: "Gait Deviations")),
                .textField(title: "Wheelchair Skills", binding: stringBinding(for: "Wheelchair Skills"))
            ]),
            FormSection(title: "Transfers", elements: [
                .textField(title: "Supine to Sit", binding: stringBinding(for: "Supine to Sit")),
                .textField(title: "Sit to Stand", binding: stringBinding(for: "Sit to Stand")),
                .textField(title: "Stand pivot", binding: stringBinding(for: "Stand pivot")),
                .textField(title: "Floor to stand", binding: stringBinding(for: "Floor to stand")),
                .textField(title: "Bed mobility", binding: stringBinding(for: "Bed mobility")),
                .textField(title: "Army Crawling", binding: stringBinding(for: "Army Crawling")),
                .textField(title: "Creeping", binding: stringBinding(for: "Creeping"))
            ]),
            FormSection(title: "Transitions", elements: [
                .textField(title: "Supine/prone", binding: stringBinding(for: "Supined/prone")),
                .textField(title: "Quadruped", binding: stringBinding(for: "Quadruped")),
                .textField(title: "Tall kneel", binding: stringBinding(for: "Tall kneel")),
                .textField(title: "Half kneel", binding: stringBinding(for: "Half kneel")),
                .textField(title: "Side Sitting", binding: stringBinding(for: "Side Sitting")),
                .textField(title: "Tailor sitting", binding: stringBinding(for: "Tailor sitting")),
                .textField(title: "Other", binding: stringBinding(for: "Transitions Other"))
            ]),
            FormSection(title: "Posture/Body Mechanics/Ergonomics", elements: [
                .singleSelectDescription(titles: ["Posture/Body Mechanics/Ergonomics"], labels: ["WNL", "Patient demonstrated the following deviations"], combinedString: stringBinding(for: "Posture/Body Mechanics/Ergonomics"), isDescription: true)
            ]),
            FormSection(title: "Gross Motor Developmental Status", elements: [
                .textField(title: "Chronological Age", binding: stringBinding(for: "Chronological Age")),
                .textField(title: "Approximate Developmental Age", binding: stringBinding(for: "Approximate Developmental Age")),
                .textField(title: "Special Testing/Standardized Testing", binding: stringBinding(for: "Special Testing/Standardized Testing"))
            ]),
            FormSection(title: "Primary Problems/Deficits Include", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "Primary Problems/Deficits Include"), labels: ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"], title: "Primary Problems/Deficits Include")
            ])
        ]

        return uiElements
    }
}
