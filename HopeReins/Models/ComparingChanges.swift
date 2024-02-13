//
//  ComparingChanges.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

extension MedicalRecordFile {
    
    
    func compareProperties(with other: [String: CodableValue]) -> [ChangeDescription] {
        var changes = [ChangeDescription]()
        
        for (key, oldValue) in self.properties {
            if let newValue = other[key], oldValue != newValue {
                if key.contains("SS") {
                    for change in compareSingleSelection(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        
                        changes.append(ChangeDescription(displayName: change.label,id: key, oldValue: change.oldValue, value: change.newValue, actualValue: oldValue.stringValue))
                    }
                } else if key.contains("LE") {
                    for change in compareLETable(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: change.oldValue, value: change.newValue, actualValue: oldValue.stringValue))
                    }
                } else if key.contains("MSO") {
                    for change in compareMultiSelectOthers(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: change.oldValue, value: change.newValue, actualValue: oldValue.stringValue))
                    }
                } else if key.contains("MST") {
                    for change in compareMultiSelectWithTitle(oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue) {
                        changes.append(ChangeDescription(displayName: change.label, id: key, oldValue: change.oldValue, value: change.newValue, actualValue: oldValue.stringValue))
                    }
                } else {
                    changes.append(ChangeDescription(displayName: "", id: key, oldValue: oldValue.stringValue, value: newValue.stringValue, actualValue: oldValue.stringValue))
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
