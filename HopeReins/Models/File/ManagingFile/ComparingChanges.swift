//
//  ComparingChanges.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

public var defaultLEROMLables: [String] = ["Knee Flexion", "Knee Extension", "Hip Flexion", "Hip Extension", "Hip Abduction", "Hip Internal Rot.", "Hip External Rot", "Ankle Dorsifl.", "Ankle Plantar"]

public var defaultUELabels: [String] = ["Shoulder Elevation (in scapular pain)", "Shoulder Abduction", "Shoulder Extension", "Shoulder Internal Rotation", "Shoulder External Rotation", "Elbow Flexion", "Elbow Extension", "Wrist Flection", "Wrist Extension", "Wrist Pronation"]

extension MedicalRecordFile {
    
//    func compareProperties(with other: [String: CodableValue]) -> [ChangeDescription] {
//        var changes = [ChangeDescription]()
//        
//        for (key, oldValue) in self.properties {
//            if let newValue = other[key], oldValue != newValue {
//                let cleanedKey = cleanKey(key)
//                let actualValue: CodableValue = .string(oldValue)
//                
//                switch (oldValue, newValue) {
//                case (.string(let oldStringValue), .string(let newStringValue)):
//                    let detailedChanges = compareStringValues(key: key, oldValue: oldStringValue, newValue: newStringValue)
//                    changes.append(contentsOf: detailedChanges)
//                    
//                    
//                case (.data(let oldDataValue), .data(let newDataValue)):
//                    if oldDataValue != newDataValue {
//                        changes.append(ChangeDescription(displayName: cleanedKey, id: key, oldValue: oldDataValue.codableValue, value: newDataValue.codableValue, actualValue: oldValue))
//                    }
//                    
//                default:
//                    break
//                }
//            }
//        }
//        
//        return changes
//    }
    
    
    private func cleanKey(_ key: String) -> String {
        if key.contains("SS") {
            return key.replacingOccurrences(of: "SS", with: "").trimmingCharacters(in: .whitespaces)
        } else if key.contains("TE") {
            return key.replacingOccurrences(of: "TE", with: "").trimmingCharacters(in: .whitespaces)
        } else if key.contains("Table") {
            return key.replacingOccurrences(of: "Table", with: "").trimmingCharacters(in: .whitespaces)
        } else if key.contains("MSO") {
            return key.replacingOccurrences(of: "MSO", with: "").trimmingCharacters(in: .whitespaces)
        } else if key.contains("MST") {
            return key.replacingOccurrences(of: "MST", with: "").trimmingCharacters(in: .whitespaces)
        } else if key.contains("DAT") {
            return key.replacingOccurrences(of: "DAT", with: "").trimmingCharacters(in: .whitespaces)
        } else {
            return key
        }
    }
    

    
    func compareAndDescribeChangesDailyNote(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
        let oldTableData = decodeDailyNote(oldCombinedString)
        let newTableData = decodeDailyNote(newCombinedString)
        
        var changes: [DetailedChange] = []
        
        for oldTableDatum in oldTableData {
            for newTableDatum in newTableData {
                if oldTableDatum.value != newTableDatum.value {
                    changes.append(DetailedChange(label: oldTableDatum.label, id: key, oldValue: oldTableDatum.value.codableValue, newValue: newTableDatum.value.codableValue, actualValue: actualValue))
                }
            }
        }
        
        return changes
    }
    
    
    
    func createDefaultTable(with labels: [String]) -> [LabelValue] {
        var labelValues = [LabelValue]()

        // Iterate over each label provided in the array
        for label in labels {
            let valueString = "MMT R = , MMT L = , A/PROM (R) (exists pain = false) = , A/PROM (L) (exists pain = false) = "
            let labelValue = LabelValue(label: label, value: valueString)
            labelValues.append(labelValue)
        }

        return labelValues
    }

    
    func compareLETable(key: String, tableType: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
        var defaultTable: [LabelValue] = []
        
        if tableType.contains("LE") {
            defaultTable = createDefaultTable(with: defaultLEROMLables)
        } else if tableType.contains("UE") {
            defaultTable = createDefaultTable(with: defaultUELabels)
        }
        
        let oldLabelValues = oldCombinedString.isEmpty ? defaultTable : parseLeRomTable(oldCombinedString)
        let newLabelValues = newCombinedString.isEmpty ? defaultTable : parseLeRomTable(newCombinedString)
        
        var changes = [DetailedChange]()
        
        // Create dictionaries for easier access
        let oldDataDict = Dictionary(uniqueKeysWithValues: oldLabelValues.map { ($0.label, $0) })
        let newDataDict = Dictionary(uniqueKeysWithValues: newLabelValues.map { ($0.label, $0) })
        
        // Check for added or modified rows
        for (label, newLabelValue) in newDataDict {
            if let oldLabelValue = oldDataDict[label] {
                if oldLabelValue.value != newLabelValue.value {
                    changes.append(DetailedChange(label: label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
                }
            } else {
                changes.append(DetailedChange(label: label, id: key, oldValue: "Not Indicated".codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
            }
        }
        
        // Check for removed rows
        for (oldLabel, oldLabelValue) in oldDataDict {
            if newDataDict[oldLabel] == nil {
                changes.append(DetailedChange(label: oldLabel, id: key, oldValue: oldLabelValue.value.codableValue, newValue: "Deleted".codableValue, actualValue: actualValue))
            }
        }
        
        return changes
    }
    
    func compareMultiSelectWithTitle(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
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
                let change = DetailedChange(label: newEntry.label, id: key, oldValue: (oldValue ?? "False").codableValue, newValue: (newEntry.value.isEmpty ? "True" : newEntry.value).codableValue, actualValue: actualValue)
                changes.append(change)
            }
        }
        
        // Check for removals
        for oldEntry in oldData {
            if newDict[oldEntry.label] == nil {
                let change = DetailedChange(label: oldEntry.label, id: key, oldValue: oldEntry.value.codableValue, newValue: "False".codableValue, actualValue: actualValue)
                changes.append(change)
            }
        }
        
        return changes
    }
    
    func compareSingleSelection(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
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
                changes.append(DetailedChange(label: newLabelValue.label, id: key, oldValue: (oldValue ?? "Not Indicated").codableValue, newValue: newValue.codableValue, actualValue: actualValue))
            }
        }
        
        // Optionally, handle labels that were removed in the new data
        for oldLabelValue in oldData {
            if newDataDict[oldLabelValue.label] == nil {
                // If a label in old data does not exist in new data
                changes.append(DetailedChange(label: oldLabelValue.label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: "".codableValue, actualValue: actualValue))
            }
        }
        
        return changes
    }
    
    func compareTextEntries(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
        let oldData = textEntriesParse(combinedString: oldCombinedString)
        let newData = textEntriesParse(combinedString: newCombinedString)
        
        var changes = [DetailedChange]()
        
        // Create dictionaries for quick lookup
        let oldDataDict = Dictionary(uniqueKeysWithValues: oldData.map { ($0.label, $0.value) })
        let newDataDict = Dictionary(uniqueKeysWithValues: newData.map { ($0.label, $0.value) })
        
        for newLabelValue in newData {
            let oldValue = oldDataDict[newLabelValue.label]
            let newValue = newLabelValue.value
            
            if oldValue != newValue {
                // If the value has changed or the label is new
                changes.append(DetailedChange(label: newLabelValue.label, id: key, oldValue: (oldValue ?? "").codableValue, newValue: newValue.codableValue, actualValue: actualValue))
            }
        }
        
        // Handle labels that were removed in the new data
        for oldLabelValue in oldData {
            if newDataDict[oldLabelValue.label] == nil {
                // If a label in old data does not exist in new data
                changes.append(DetailedChange(label: oldLabelValue.label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: "".codableValue, actualValue: actualValue))
            }
        }
        
        return changes
    }
    
    
    func compareMultiSelectOthers(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
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
                let change = DetailedChange(label: newEntry.label, id: key, oldValue: (oldValue ?? "None").codableValue, newValue: newEntry.value.codableValue, actualValue: actualValue)
                changes.append(change)
            }
        }
        
        // Check for removals
        for oldEntry in oldData {
            if newDict[oldEntry.label] == nil {
                let change = DetailedChange(label: oldEntry.label, id: key, oldValue: oldEntry.value.codableValue, newValue: "Removed".codableValue, actualValue: actualValue)
                changes.append(change)
            }
        }
        
        return changes
    }
    
    
    func compareDailyNoteTable(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
        var oldTableData = decodeDailyNoteTable(oldCombinedString)
        let newTableData = decodeDailyNoteTable(newCombinedString)
        
        let initialTableData: [DailyNoteTableCell] = [
            DailyNoteTableCell(number: 1, code: "PTNEUR15", cpt: "97112", procedire: "PT NEUROMUSCULAR RE_ED 15 MIN"),
            DailyNoteTableCell(number: 1, code: "THERA15", cpt: "97530", procedire: "PT_THEREPEUTIC ACTCTY 15 MIN "),
            DailyNoteTableCell(number: 1, code: "PTGAIT15", cpt: "97116", procedire: "PT GAIT TRAINING 15 MIN"),
            DailyNoteTableCell(number: 1, code: "THEREX", cpt: "97110", procedire: "PT-THEREAPEUTIC EXERCISE 15 MIN"),
            DailyNoteTableCell(number: 1, code: "MANUAL", cpt: "97140", procedire: "PT-MANUAL THERAPY")
        ]
        
        var changes: [DetailedChange] = []
        
        // Compare the old and new table data and identify changes
        if oldTableData.isEmpty {
            oldTableData = initialTableData
        }
        for (index, oldEntry) in oldTableData.enumerated() {
            if index < newTableData.count {
                let newEntry = newTableData[index]
                
                // Check if any field within the table cell has changed
                if oldEntry.number != newEntry.number {
                    changes.append(DetailedChange(label: oldEntry.code, id: key, oldValue: oldEntry.number.description.codableValue, newValue: newEntry.number.description.codableValue, actualValue: actualValue))
                }
            }
        }
        return changes
    }
    
    func decodeDailyNoteTable(_ combinedString: String) -> [DailyNoteTableCell] {
        var tableData: [DailyNoteTableCell] = []
        
        // Define the default initial table data
        let initialTableData: [DailyNoteTableCell] = [
            DailyNoteTableCell(number: 1, code: "PTNEUR15", cpt: "97112", procedire: "PT NEUROMUSCULAR RE_ED 15 MIN"),
            DailyNoteTableCell(number: 1, code: "THERA15", cpt: "97530", procedire: "PT_THEREPEUTIC ACTCTY 15 MIN "),
            DailyNoteTableCell(number: 1, code: "PTGAIT15", cpt: "97116", procedire: "PT GAIT TRAINING 15 MIN"),
            DailyNoteTableCell(number: 1, code: "THEREX", cpt: "97110", procedire: "PT-THEREAPEUTIC EXERCISE 15 MIN"),
            DailyNoteTableCell(number: 1, code: "MANUAL", cpt: "97140", procedire: "PT-MANUAL THERAPY")
        ]
        
        // Split the combined string into the number components using the delimiter "//"
        let numbers = combinedString.split(separator: "//").compactMap { Int($0) }
        
        for  (index, number) in numbers.enumerated()  {
            var currentTableData = initialTableData[index]
            currentTableData.number = number
            tableData.append(currentTableData)
        }
        
        return tableData
    }

    
}
