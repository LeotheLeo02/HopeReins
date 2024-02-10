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
        var versions: [Version] = []
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


public struct LabelValue: Hashable {
    var label: String
    var value: String
}
struct DetailedChange {
    var label: String
    var oldValue: String
    var newValue: String
}



public func singleSelectionParse(combinedString: String) -> [LabelValue] {
    var labelValues = [LabelValue]()

    let components = combinedString.split(separator: ",").map(String.init)
    for component in components {
        let parts = component.split(separator: "::", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        guard parts.count >= 1 else { continue }

        let titlePart = parts[0].trimmingCharacters(in: .whitespaces)
        let selectionAndMaybeDescription = parts.count > 1 ? parts[1] : ""

        let selectionParts = selectionAndMaybeDescription.split(separator: "~~", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        if !selectionParts.isEmpty {
            let selection = selectionParts[0].trimmingCharacters(in: .whitespaces)
            let description = selectionParts.count > 1 ? String(selectionParts[1]) : ""

            // Construct the value string by concatenating selection and description if available
            let valueString = description.isEmpty ? selection : "\(selection) - \(description)"
            
            labelValues.append(LabelValue(label: titlePart, value: valueString))
        }
    }

    return labelValues
}

public func decodeMultiSelectWithTitle(boolString: String) -> [LabelValue] {
    let entries = boolString.components(separatedBy: "\\") // Split into entries by "\"
    var labelValues: [LabelValue] = []

    for entry in entries {
        let parts = entry.components(separatedBy: ":") // Split each entry into label and value
        if parts.count == 2 {
            let label = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            labelValues.append(LabelValue(label: label, value: value))
        }
    }

    return labelValues
}

func decodeDailyNote(_ combinedString: String) -> [LabelValue] {
    let stringComponents: [String] = ["PTNEUR15", "THERA15", "PTGAIT15", "THEREX", "MANUAL"]
    let components = combinedString.components(separatedBy: "//")
    var labels: [LabelValue] = []

    for (index, component) in components.enumerated() {
        if index < stringComponents.count {
            let label = stringComponents[index]
            labels.append(LabelValue(label: label, value: component))
        }
    }
    
    return labels
}

func decodeMultiSelectOthers(_ combinedString: String) -> [LabelValue] {
    // Split the combined string into components based on the "|" delimiter
    let components = combinedString.components(separatedBy: "|")
    
    var decodedData = [LabelValue]()
    
    for component in components {
        // Further split each component into label and value based on the ":" delimiter
        let parts = component.components(separatedBy: ":")
        
        if parts.count == 2 {
            let label = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            decodedData.append(LabelValue(label: label, value: value))
        } else if component.starts(with: "other:") {
            // Handle "other" inputs differently if needed
            let value = String(component.dropFirst("other:".count))
            decodedData.append(LabelValue(label: "Other", value: value))
        }
    }
    
    return decodedData
}


public func parseLeRomTable(_ combinedString: String) -> [LabelValue] {
    let entries = combinedString.components(separatedBy: "//")
    var labelValues = [LabelValue]()

    var index = 0
    while index < entries.count {
        let isPain = entries[index] == "true"
        let label = entries[index + 1]

        var valueString = ""
        if isPain {
            valueString = "Pain detected"
            index += 2
        } else {
            let value1 = entries[index + 2]
            let value2 = entries[index + 3]
            let value3 = entries[index + 4]
            let value4 = entries[index + 5]
            valueString = "MMT R = \(value1), MMT L = \(value2), A/PROM (R) = \(value3), A/PROM (L) = \(value4)"
            index += 6
        }

        let labelValue = LabelValue(label: label, value: valueString)
        labelValues.append(labelValue)
    }

    return labelValues
}



extension MedicalRecordFile {

    
    func compareAndDescribeChangesDailyNote(oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
         let oldTableData = decodeDailyNote(oldCombinedString)
         let newTableData = decodeDailyNote(newCombinedString)

         var changes: [DetailedChange] = []

        for oldTableDatum in oldTableData {
            for newTableDatum in newTableData {
                if oldTableDatum.value != newTableDatum.value {
                    changes.append(DetailedChange(label: oldTableDatum.label, oldValue: oldTableDatum.value, newValue: newTableDatum.value))
                }
            }
        }

         return changes
     }
    
    func createDefaultLETableData() -> [LabelValue] {
        let initialTableData: [TableCellData] = [
            TableCellData(label1: "Knee Flexion", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Knee Extension", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Hip Flexion", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Hip Extension", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Hip Abduction", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Hip Internal Rot.", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Hip External Rot.", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Ankle Dorsifl", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Ankle Plantar", value1: 1, value2: 1, value3: 0, value4: 0),
            TableCellData(label1: "Other", value1: 1, value2: 1, value3: 0, value4: 0)
        ]

        var labelValues = [LabelValue]()

        for cellData in initialTableData {
            let valueString = "MMT R = \(cellData.value1), MMT L = \(cellData.value2), A/PROM (R) = \(cellData.value3), A/PROM (L) = \(cellData.value4)"
            let labelValue = LabelValue(label: cellData.label1, value: valueString)
            labelValues.append(labelValue)
        }

        return labelValues
    }

    
     func compareLETable(oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
        let oldLabelValues = oldCombinedString.isEmpty ? createDefaultLETableData() : parseLeRomTable(oldCombinedString)
         let newLabelValues = newCombinedString.isEmpty ? createDefaultLETableData() :  parseLeRomTable(newCombinedString)

        var changes = [DetailedChange]()

        // Create dictionaries for easier access
        let oldDataDict = Dictionary(uniqueKeysWithValues: oldLabelValues.map { ($0.label, $0.value) })
        let newDataDict = Dictionary(uniqueKeysWithValues: newLabelValues.map { ($0.label, $0.value) })

        for (label, oldValue) in oldDataDict {
            if let newValue = newDataDict[label], newValue != oldValue {
                changes.append(DetailedChange(label: label, oldValue: oldValue, newValue: newValue))
            }
        }


        return changes
    }



    func compareProperties(with other: [String: CodableValue]) -> [ChangeDescription] {
        var changes = [ChangeDescription]()
        
        for (key, newValue) in self.properties {
            if let oldValue = other[key], newValue != oldValue {
                if key.contains("SS") {
                    for change in compareSingleSelection(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label,id: key, oldValue: .string(change.oldValue), value: .string(change.newValue), actualValue: oldValue))
                    }
                } else if key.contains("LE") {
                    for change in compareLETable(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: .string(change.oldValue), value: .string(change.newValue), actualValue: oldValue))
                    }
                } else if key.contains("MSO") {
                    for change in compareMultiSelectOthers(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: .string(change.oldValue), value: .string(change.newValue), actualValue: oldValue))
                    }
                } else if key.contains("MST") {
                    for change in compareMultiSelectWithTitle(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: .string(change.oldValue), value: .string(change.newValue), actualValue: oldValue))
                    }
                } else {
                    changes.append(ChangeDescription(id: key, oldValue: oldValue, value: newValue, actualValue: oldValue))
                }
            }
        }
        print(changes)
        return changes
    }
    


    


    func compareMultiSelectWithTitle(oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
        let oldData = decodeMultiSelectWithTitle(boolString: oldCombinedString)
        let newData = decodeMultiSelectWithTitle(boolString: newCombinedString)

        var changes = [DetailedChange]()

        // Convert oldData and newData to dictionaries for easier lookup
        let oldDict = Dictionary(uniqueKeysWithValues: oldData.map { ($0.label, $0.value) })
        let newDict = Dictionary(uniqueKeysWithValues: newData.map { ($0.label, $0.value) })

        // Check for changes and additions
        for newEntry in newData {
            let oldValue = oldDict[newEntry.label]
            if oldValue != newEntry.value {
                let change = DetailedChange(label: newEntry.label, oldValue: oldValue ?? "None", newValue: newEntry.value)
                changes.append(change)
            }
        }

        // Check for removals
        for oldEntry in oldData {
            if newDict[oldEntry.label] == nil {
                let change = DetailedChange(label: oldEntry.label, oldValue: oldEntry.value, newValue: "Removed")
                changes.append(change)
            }
        }

        return changes
    }

    func compareSingleSelection(oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
        let oldData = singleSelectionParse(combinedString: oldCombinedString)
        let newData = singleSelectionParse(combinedString: newCombinedString)

        var changes = [DetailedChange]()

        // Create dictionaries for quick lookup
        let oldDataDict = Dictionary(uniqueKeysWithValues: oldData.map { ($0.label, $0.value) })
        let newDataDict = Dictionary(uniqueKeysWithValues: newData.map { ($0.label, $0.value) })

        for newLabelValue in newData {
            let oldValue = oldDataDict[newLabelValue.label]
            let newValue = newLabelValue.value

            if oldValue != newValue {
                // If the value has changed or the label is new
                changes.append(DetailedChange(label: newLabelValue.label, oldValue: oldValue ?? "", newValue: newValue))
            }
        }

        // Optionally, handle labels that were removed in the new data
        for oldLabelValue in oldData {
            if newDataDict[oldLabelValue.label] == nil {
                // If a label in old data does not exist in new data
                changes.append(DetailedChange(label: oldLabelValue.label, oldValue: oldLabelValue.value, newValue: ""))
            }
        }

        return changes
    }

    
    func compareMultiSelectOthers(oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
        let oldData = decodeMultiSelectOthers(oldCombinedString)
        let newData = decodeMultiSelectOthers(newCombinedString)
        
        var changes = [DetailedChange]()
        
        // Convert oldData and newData to dictionaries for easier lookup
        let oldDict = Dictionary(uniqueKeysWithValues: oldData.map { ($0.label, $0.value) })
        let newDict = Dictionary(uniqueKeysWithValues: newData.map { ($0.label, $0.value) })
        
        // Check for changes and additions
        for newEntry in newData {
            let oldValue = oldDict[newEntry.label]
            if oldValue != newEntry.value {
                let change = DetailedChange(label: newEntry.label, oldValue: oldValue ?? "None", newValue: newEntry.value)
                changes.append(change)
            }
        }
        
        // Check for removals
        for oldEntry in oldData {
            if newDict[oldEntry.label] == nil {
                let change = DetailedChange(label: oldEntry.label, oldValue: oldEntry.value, newValue: "Removed")
                changes.append(change)
            }
        }
        
        return changes
    }
    

    
    func addPastChanges(reason: String, changes: [ChangeDescription], author: String, modelContext: ModelContext) {
        let newVersion = Version(date: Date.now, reason: reason, author: author)
        var newChanges: [PastChange] = []
        for change in changes {
            newChanges.append(PastChange(fieldID: change.id, type: "String", propertyChange: change.actualValue.stringValue, displayName: (change.displayName ?? "") + "\(change.oldValue.stringValue)"))
        }

        self.versions.append(newVersion)
       

        try? modelContext.transaction {
            modelContext.insert(newVersion)
            newVersion.changes = newChanges
            updateProperties(author: author, modelContext: modelContext)
        }
    }

    
    func updateProperties(author: String, modelContext: ModelContext) {
        self.digitalSignature?.modified(by: author)
        try? modelContext.save()
    }

    
    func revertToPastChange(fieldId: String?, version: Version, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        if revertToAll {
            version.changes.forEach { change in
                self.properties[change.fieldID] = CodableValue.string(change.propertyChange)
            }
            
            self.versions.removeAll { $0 == version }
            modelContext.delete(version)
        } else if let fieldId = fieldId {
            for change in version.changes {
                if change.fieldID == fieldId {
                    self.properties[change.fieldID] = CodableValue.string(change.propertyChange)
                    version.changes.removeAll { change in
                        return change == change
                    }
                    modelContext.delete(change)
                }
            }

            return version.changes.isEmpty
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
            FormSection(title: "File Name", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name"))
            ]),
            FormSection(title: "Personal Info", elements: [
                .textField(title: "Education Level", binding: stringBinding(for: "Education Level")),
                .textField(title: "Extracurricular", binding: stringBinding(for: "Extracurricular")),
                .textField(title: "Home Barrier", binding: stringBinding(for: "Home Barrier")),
                .textField(title: "Past medical and/or rehab history", binding: stringBinding(for: "Past medical and/or rehab history")),
                .textField(title: "Surgical History", binding: stringBinding(for: "Surgical History")),
                .textField(title: "Medications", binding: stringBinding(for: "Medications")),
                .textField(title: "Vision", binding: stringBinding(for: "Vision")),
                .textField(title: "Hearing", binding: stringBinding(for: "Hearing")),
                .textField(title: "Speech/Communications", binding: stringBinding(for: "Speech Communications")),
                .textField(title: "Seizures", binding: stringBinding(for: "Seizures")),
            ]),
            FormSection(title: "A/Prom", elements: [
                .textField(title: "A Upper Extremity", binding: stringBinding(for: "A Upper Extremity")),
                .textField(title: "A Lower Extremity", binding: stringBinding(for: "A Lower Extremity")),
            ]),
            FormSection(title: "Strength", elements: [
                .textField(title: "S Upper Extremities", binding: stringBinding(for: "S Upper Extremity")),
                .textField(title: "S Lower Extremities", binding: stringBinding(for: "S Lower Extremity")),
                .textField(title: "Trunk Musculature", binding: stringBinding(for: "Trunk Musculature")),
                .leRomTable(title: "LE Strength and ROM Table", combinedString: stringBinding(for: "LE Strength and ROM Table")),
                .singleSelectDescription(title: "SS Pain", titles: ["Pain"], labels: ["No", "Yes"], combinedString: stringBinding(for: "SS Pain"), isDescription: true)
            ]),
            FormSection(title: "Neurological Functioning", elements: [
                .singleSelectDescription(title: "SS Tone", titles: ["Tone"], labels: ["WNL", "Hypotonic", "Fluctuating", "NT"], combinedString: stringBinding(for: "SS Tone"), isDescription: true),
                .singleSelectDescription(title: "SS Sensation", titles: ["Sensation"], labels: ["WNL", "Hyposensitive", "Hypersensitive", "Absent", "NT"], combinedString: stringBinding(for: "SS Sensation"), isDescription: true),
                .singleSelectDescription(title: "SS Reflexes", titles: ["Reflexes"], labels: ["WNL", "Hyporesponse", "Hyperresponse", "Deficits", "NT"], combinedString: stringBinding(for: "SS Reflexes"), isDescription: true),
                .singleSelectDescription(title: "SS Protective to Praxis", titles: ["Protective Extension", "Righting", "Equilibrium", "Praxis"], labels: ["WNL", "Deficient", "Emerging", "Absent", "NT"], combinedString: stringBinding(for: "SS Protective to Praxis"), isDescription: true),
                .textField(title: "Neurological Notes", binding: stringBinding(for: "Neurological Notes")),
                .textField(title: "Toileting", binding: stringBinding(for: "Toileting")),
            ]),
            FormSection(title: "Coordination", elements: [
                .singleSelectDescription(title: "SS Coordination Extremities", titles: ["Upper Extremities", "Lower Extremities"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Coordination Extremities"), isDescription: true),
                .textField(title: "Coordination Notes", binding: stringBinding(for: "Coordination Notes")),
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Endurance", elements: [
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Balance", elements: [
                .singleSelectDescription(title: "SS Balance", titles: ["Sit Static", "Sit Dynamic", "Stance Static", "Stance Dynamic"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Balance"), isDescription: true),
                .textField(title: "Balance Notes", binding: stringBinding(for: "Balance Notes"))
            ]),
            FormSection(title: "Current Equipment", elements: [
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Current Equipment"), labels: ["Orthotics", "Wheelchair", "Bath Equipment", "Glasses", "Augmentative Communication Device", "Walking Device", "Training Aids", "Other"], title: "MST Current Equipment")
            ]),
            FormSection(title: "Mobility", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Locomotion"), labels: ["Ambulation", "Non-Mobile", "Wheel Chair"], title: "MSO Locomotion"),
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Assistance & Distance"), labels: ["Independent", "Supervision for safety", "Minimal", "Maximal", "SBA", "CGA", "Moderate", "Dependent"], title: "MST Assistance & Distance"),
                .singleSelectDescription(title: "SS Surfaces", titles: ["Level", "Ramp", "Curb", "Stairs", "Uneven terrain"], labels: ["Independent", "SBA", "CGA", "Min", "Mod", "Max"], combinedString: stringBinding(for: "SS Surfaces"), isDescription: true),
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
                .singleSelectDescription(title: "SS Posture/Body Mechanics/Ergonomics", titles: ["Posture/Body Mechanics/Ergonomics"], labels: ["WNL", "Patient demonstrated the following deviations"], combinedString: stringBinding(for: "SS Posture/Body Mechanics/Ergonomics"), isDescription: true)
            ]),
            FormSection(title: "Gross Motor Developmental Status", elements: [
                .textField(title: "Chronological Age", binding: stringBinding(for: "Chronological Age")),
                .textField(title: "Approximate Developmental Age", binding: stringBinding(for: "Approximate Developmental Age")),
                .textField(title: "Special Testing/Standardized Testing", binding: stringBinding(for: "Special Testing/Standardized Testing"))
            ]),
            FormSection(title: "Primary Problems/Deficits Include", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Primary Problems/Deficits Include"), labels: ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"], title: "MSO Primary Problems/Deficits Include")
            ]),
            FormSection(title: "Daily Note", elements: [
                .dailyNoteTable(title: "Daily Note", combinedString: stringBinding(for: "Daily Note"))
            ])

        ]

        return uiElements
    }
}
