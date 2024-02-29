//
//  ComparingChanges.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

public var defaultLEROMLables: [String] = ["Knee Flexion", "Knee Extension", "Hip Flexion", "Hip Extension", "Hip Abduction", "Hip Internal Rot.", "Hip External Rot", "Ankle Dorsifl.", "Ankle Plantar", "Other"]

public var defaultUELabels: [String] = ["Shoulder Elevation (in scapular pain)", "Shoulder Abduction", "Shoulder Extension", "Shoulder Internal Rotation", "Shoulder External Rotation", "Elbow Flexion", "Elbow Extension", "Wrist Flection", "Wrist Extension", "Wrist Pronation", "Other"]

extension MedicalRecordFile {
    
    
    func compareProperties(with other: [String: CodableValue]) -> [ChangeDescription] {
        var changes = [ChangeDescription]()
        
        for (key, oldValue) in self.properties {
            if let newValue = other[key], oldValue != newValue {
                switch oldValue {
                case .string(_):
                    if key.contains("SS") {
                        for change in compareSingleSelection(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                            
                            changes.append(ChangeDescription(displayName: change.label,id: key, oldValue: CodableValue.string(change.oldValue), value: CodableValue.string(change.newValue), actualValue: CodableValue.string(oldValue.stringValue)))
                        }
                    } else if key.contains("Table") {
                        for change in compareLETable(tableType: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                            changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: CodableValue.string(change.oldValue), value: CodableValue.string(change.newValue), actualValue: CodableValue.string(oldValue.stringValue)))
                        }
                    } else if key.contains("MSO") {
                        for change in compareMultiSelectOthers(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                            changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: CodableValue.string(change.oldValue), value: CodableValue.string(change.newValue), actualValue: CodableValue.string(oldValue.stringValue)))
                        }
                    } else if key.contains("MST") {
                        for change in compareMultiSelectWithTitle(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                            changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: CodableValue.string(change.oldValue), value: CodableValue.string(change.newValue), actualValue: CodableValue.string(oldValue.stringValue)))
                        }
                    } else {
                        changes.append(ChangeDescription(displayName: "", id: key, oldValue: CodableValue.string(oldValue.stringValue), value: CodableValue.string(newValue.stringValue), actualValue: CodableValue.string(oldValue.stringValue)))
                    }
                case .data(let data):
                    changes.append(ChangeDescription(displayName: key, id: key, oldValue: CodableValue.data(oldValue.dataValue), value: CodableValue.data(newValue.dataValue), actualValue: CodableValue.data(oldValue.dataValue)))
                case .int(_):
                    print("Int")
                case .double(_):
                    print("Double")
                case .bool(_):
                    print("Bool")
                case .date(_):
                    print("Date")
                }
            }
        }
        return changes
    }
    
    
    
    
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
    
    
    
    func createDefaultTable(with labels: [String]) -> [LabelValue] {
        var labelValues = [LabelValue]()

        // Iterate over each label provided in the array
        for label in labels {
            let valueString = "MMT R = 1, MMT L = 1, A/PROM (R) = 0.0, A/PROM (L) = 0.0"
            let labelValue = LabelValue(label: label, value: valueString)
            labelValues.append(labelValue)
        }

        return labelValues
    }

    
    
    func compareLETable(tableType: String, oldCombinedString: String, newCombinedString: String) -> [DetailedChange] {
        // TODO: Add other as last row
        var defaultTable: [LabelValue] = []
        if tableType.contains("LE") {
            defaultTable = createDefaultTable(with: defaultLEROMLables)
        } else if tableType.contains("UE") {
            defaultTable = createDefaultTable(with: defaultUELabels)
        }
        let oldLabelValues = oldCombinedString.isEmpty ? defaultTable : parseLeRomTable(oldCombinedString)
        let newLabelValues = newCombinedString.isEmpty ? defaultTable :  parseLeRomTable(newCombinedString)
        
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
                changes.append(DetailedChange(label: newLabelValue.label, oldValue: oldValue ?? "Not Indicated", newValue: newValue))
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
    
}
