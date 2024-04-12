//
//  DynamicUIElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI


public var defaultLEROMLables: [String] = ["Knee Flexion", "Knee Extension", "Hip Flexion", "Hip Extension", "Hip Abduction", "Hip Internal Rot.", "Hip External Rot", "Ankle Dorsifl.", "Ankle Plantar"]

public var defaultUELabels: [String] = ["Shoulder Elevation (in scapular pain)", "Shoulder Abduction", "Shoulder Extension", "Shoulder Internal Rotation", "Shoulder External Rotation", "Elbow Flexion", "Elbow Extension", "Wrist Flection", "Wrist Extension", "Wrist Pronation"]


struct DynamicElementView: View {
    @Environment(\.isEditable) var isEditable
    @State var wrappedElement: DynamicUIElement
    @State var change: PastChange?
    var body: some View {
        VStack(alignment: .leading) {
            switch wrappedElement {
            case .textField(let title, let binding, let isRequired):
                BasicTextField(title: title, isRequired: isRequired, text: bindingForChange(type: String.self, originalBinding: binding))
            case .datePicker(let title, let hourAndMinute, let binding):
                DateSelection(title: title, hourAndMinute: hourAndMinute, date: bindingForChange(type: Date.self, originalBinding: binding))
            case .numberField(let title, let binding):
                TextField(title, value: bindingForChange(type: Int.self, originalBinding: binding), formatter: NumberFormatter())
            case .sectionHeader(let title):
                SectionHeader(title: title)
            case .singleSelectDescription(title: let title, titles: let titles, labels: let labels, combinedString: let combinedString):
                SingleSelectLastDescription(combinedString: bindingForChange(type: String.self, originalBinding: combinedString), titles: titles, labels: labels)
            case .multiSelectWithTitle(combinedString: let combinedString, labels: let labels, title: let title):
                MultiSelectWithTitle(boolString: bindingForChange(type: String.self, originalBinding: combinedString), labels: labels, title: title)
            case .multiSelectOthers(combinedString: let combinedString, labels: let labels, title: let title):
                MultiSelectOthers(boolString: bindingForChange(type: String.self, originalBinding: combinedString), labels: labels, title: title)
            case .strengthTable(title: let title, combinedString: let combinedString):
                if change != nil {
                    OriginalValueView(id: change!.fieldID, value: change!.propertyChange, displayName: change!.displayName)
                } else {
                    StrengthTable(combinedString: combinedString, customLabels: title.contains("LE") ?  defaultLEROMLables : defaultUELabels)
                }
            case .dailyNoteTable(_, let combinedString):
                if change != nil {
                    OriginalValueView(id: change!.fieldID, value: change!.propertyChange, displayName: change!.displayName)
                } else {
                    DailyNoteTable(combinedString: combinedString)
                }
            case .fileUploadButton(title: let title, dataValue: let dataValue):
                PropertyHeader(title: title)
                FileUploadButton(fileData: (change != nil) ? .constant(convertToCodableValue(type: change!.type, propertyChange: change!.propertyChange).dataValue) :  dataValue)
            case .physicalTherapyFillIn(title: let title, combinedString: let combinedString):
                RecommendedPhysicalTherapyFillIn(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .reEvalFillin(title: let title, combinedString: let combinedString):
                ReEvalFillInInput(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .dailyNoteFillin(title: let title, combinedString: let combinedString):
                DailyNoteFillIn(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .textEntries(title: let title, combinedString: let combinedString):
                TextEntries(combinedString: bindingForChange(type: String.self, originalBinding: combinedString), title: title)
            }
        }
        .environment(\.isEditable, isEditable && change == nil)
    }
}

enum DynamicUIElement: Hashable {
    case textField(title: String, binding: Binding<String>, isRequired: Bool = false)
    case datePicker(title: String, hourAndMinute: Bool, binding: Binding<Date>)
    case numberField(title: String, binding: Binding<Int>)
    case sectionHeader(title: String)
    case strengthTable(title: String, combinedString: Binding<String>)
    case singleSelectDescription(title: String, titles: [String], labels: [String], combinedString: Binding<String>)
    case multiSelectWithTitle(combinedString: Binding<String>, labels: [String], title: String)
    case multiSelectOthers(combinedString: Binding<String>, labels: [String], title: String)
    case dailyNoteTable(title: String, combinedString: Binding<String>)
    case fileUploadButton(title: String, dataValue: Binding<Data?>)
    case physicalTherapyFillIn(title: String, combinedString: Binding<String>)
    case reEvalFillin(title: String, combinedString: Binding<String>)
    case dailyNoteFillin(title: String, combinedString: Binding<String>)
    case textEntries(title: String, combinedString: Binding<String>)
    
    static func == (lhs: DynamicUIElement, rhs: DynamicUIElement) -> Bool {
           switch (lhs, rhs) {
           case let (.textField(title1, _, _), .textField(title2, _, _)),
                let (.numberField(title1, _), .numberField(title2, _)):
               return title1 == title2
           case (.sectionHeader(let title1), .sectionHeader(let title2)):
               return title1 == title2
           default:
               return false
           }
    }
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .textField(let title, _, _),
                .numberField(let title, _),
                .sectionHeader(let title),
                .strengthTable(let title, _),
                .dailyNoteTable(let title, _),
                .fileUploadButton(let title, _),
                .physicalTherapyFillIn(let title, _),
                .reEvalFillin(let title, _),
                .dailyNoteFillin(let title, _),
                .textEntries(title: let title, _):
            hasher.combine(title)
        case .singleSelectDescription(_,let titles, let labels, _):
            hasher.combine(titles)
            hasher.combine(labels)
        case .datePicker(title: let title, _, _):
            hasher.combine(title)
        case .multiSelectWithTitle(_, let labels, let title):
            hasher.combine(labels)
            hasher.combine(title)
        case .multiSelectOthers(_, let labels, let title):
            hasher.combine(labels)
            hasher.combine(title)
        }
    }
}



struct DynamicUIElementWrapper: Hashable {
    let id: String
    let element: DynamicUIElement

    init(element: DynamicUIElement) {
        switch element {
        case .textField(let title, _, _),
             .numberField(let title, _),
             .sectionHeader(let title),
             .datePicker(let title, _, _),
             .multiSelectWithTitle(_, _, let title),
             .multiSelectOthers(_, _, let title),
             .strengthTable(let title, _),
             .dailyNoteTable(let title, _),
             .singleSelectDescription(let title,_, _, _),
             .fileUploadButton(let title, _),
             .physicalTherapyFillIn(let title, _),
             .reEvalFillin(let title, _),
             .dailyNoteFillin(let title, _),
             .textEntries(let title, _):
            self.id = title
        }
        self.element = element
    }
}

extension DynamicElementView {
    func bindingForChange<T>(type: T.Type, originalBinding: Binding<T>) -> Binding<T> {
        guard let change = change else {
            return originalBinding
        }

        let convertedValue = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)

        switch T.self {
        case is String.Type:
            return .constant(convertedValue.stringValue as! T)
        case is Date.Type:
            return .constant(convertedValue.dateValue as! T)
        case is Int.Type:
            return .constant(convertedValue.intValue as! T)
        default:
            return originalBinding
        }
    }
}


extension DynamicUIElement {
    func compare(key: String, oldValue: CodableValue, newValue: CodableValue, actualValue: CodableValue) -> [DetailedChange] {
        switch self {
        case .textField(let title, _, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .datePicker(let title, _, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .strengthTable(_, _):
            return self.compareLETable(key: key, tableType: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        case .singleSelectDescription(_, _, _, _):
            return self.compareSingleSelection(key: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        case .multiSelectWithTitle(_, _, _):
           return self.compareMultiSelectWithTitle(key: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        case .multiSelectOthers(_, _, _):
            return self.compareMultiSelectOthers(key: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        case .dailyNoteTable(_, _):
            return self.compareAndDescribeChangesDailyNote(key: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        case .fileUploadButton(let title, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .physicalTherapyFillIn(let title, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .reEvalFillin(let title, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .dailyNoteFillin(let title, _):
            return [DetailedChange(label: title, id: key, oldValue: oldValue, newValue: newValue, actualValue: actualValue)]
        case .textEntries(_, _):
            return self.compareTextEntries(key: key, oldCombinedString: oldValue.stringValue, newCombinedString: newValue.stringValue, actualValue: actualValue)
        default:
            return []
        }
    }
}

extension DynamicUIElement {
    
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
    
    public func textEntriesParse(combinedString: String) -> [LabelValue] {
        var labelValues = [LabelValue]()
        let components = combinedString.components(separatedBy: "|")
        
        for component in components {
            let parts = component.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
            guard parts.count == 2 else { continue }
            
            let label = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            
            labelValues.append(LabelValue(label: label, value: value))
        }
        
        return labelValues
    }
}

extension DynamicUIElement {
    
    func compareAndDescribeChangesDailyNote(key: String, oldCombinedString: String, newCombinedString: String, actualValue: CodableValue) -> [DetailedChange] {
        let defaultTable = createDefaultDailyNoteTable()
        let oldLabelValues = oldCombinedString.isEmpty ? defaultTable : decodeDailyNote(oldCombinedString)
        let newLabelValues = newCombinedString.isEmpty ? defaultTable : decodeDailyNote(newCombinedString)
        
        var changes = [DetailedChange]()
        let oldDataDict = Dictionary(uniqueKeysWithValues: oldLabelValues.map { ($0.label, $0) })
        let newDataDict = Dictionary(uniqueKeysWithValues: newLabelValues.map { ($0.label, $0) })
        
        // Define the specific order of labels
        let labelOrder = ["PTNEUR15", "THERA15", "PTGAIT15", "THEREX", "MANUAL"]
        
        // Process changes for the labels in the specific order
        for label in labelOrder {
            if let newLabelValue = newDataDict[label], let oldLabelValue = oldDataDict[label] {
                if oldLabelValue.value != newLabelValue.value {
                    changes.append(DetailedChange(label: label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
                }
            } else if let newLabelValue = newDataDict[label] {
                changes.append(DetailedChange(label: label, id: key, oldValue: "Not Indicated".codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
            } else if let oldLabelValue = oldDataDict[label] {
                changes.append(DetailedChange(label: label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: "Deleted".codableValue, actualValue: actualValue))
            }
        }
        
        // Process changes for the added rows
        for (label, newLabelValue) in newDataDict {
            if !labelOrder.contains(label) {
                if let oldLabelValue = oldDataDict[label] {
                    if oldLabelValue.value != newLabelValue.value {
                        changes.append(DetailedChange(label: label, id: key, oldValue: oldLabelValue.value.codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
                    }
                } else {
                    changes.append(DetailedChange(label: label, id: key, oldValue: "Not Indicated".codableValue, newValue: newLabelValue.value.codableValue, actualValue: actualValue))
                }
            }
        }
        
        // Process deleted rows
        for (oldLabel, oldLabelValue) in oldDataDict {
            if !labelOrder.contains(oldLabel) && newDataDict[oldLabel] == nil {
                changes.append(DetailedChange(label: oldLabel, id: key, oldValue: oldLabelValue.value.codableValue, newValue: "Deleted".codableValue, actualValue: actualValue))
            }
        }
        
        return changes
    }
    
    func createDefaultDailyNoteTable() -> [LabelValue] {
        let labels = ["PTNEUR15", "THERA15", "PTGAIT15", "THEREX", "MANUAL"]
        
        var labelValues = [LabelValue]()
        
        for label in labels {
            let valueString = "# = ,\ncode = ,\ncpt = ,\nprocedure = "
            let labelValue = LabelValue(label: label, value: valueString)
            labelValues.append(labelValue)
        }
        return labelValues
    }

    func decodeDailyNote(_ combinedString: String) -> [LabelValue] {
        var labelValues: [LabelValue] = [LabelValue]()
        let entries = combinedString.components(separatedBy: "//")
        print(entries)

        
        var index = 0
        while index < entries.count {
            var valueString = ""
            let number = entries[index]
            let code = entries[index + 1]
            let cpt = entries[index + 2]
            let procedure = entries[index + 3]
            valueString = "# = \(number),\ncode = \(code),\ncpt = \(cpt),\nprocedure = \(procedure)"
            index += 4
            
            let labelValue = LabelValue(label: code, value: valueString)
            labelValues.append(labelValue)
        }
        
        return labelValues
        
    }
}


extension DynamicUIElement {
    
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

}

extension DynamicUIElement {
    
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
}


extension DynamicUIElement {
    
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
    
    func createDefaultTable(with labels: [String]) -> [LabelValue] {
        var labelValues = [LabelValue]()

        // Iterate over each label provided in the array
        for label in labels {
            let valueString = "MMT R = ,\nMMT L = ,\nA/PROM (R) (No Pain) = ,\nA/PROM (L) (No Pain) = "
            let labelValue = LabelValue(label: label, value: valueString)
            labelValues.append(labelValue)
        }

        return labelValues
    }

    
    public func parseLeRomTable(_ combinedString: String) -> [LabelValue] {
        let entries = combinedString.components(separatedBy: "//")
        var labelValues = [LabelValue]()

        var index = 0
        while index < entries.count {
            let label = entries[index]
            var valueString = ""
            let value1 = entries[index + 1]
            let value2 = entries[index + 2]
            let isPain1 = entries[index + 3]
            let value4 = entries[index + 4]
            let isPain2 = entries[index + 5]
            let value6 = entries[index + 6]
            valueString = "MMT R = \(value1),\nMMT L = \(value2),\nA/PROM (R) (\(Bool(isPain1)! ? "Has Pain" : "No Pain")) = \(value4),\nA/PROM (L) (\(Bool(isPain2)! ? "Has Pain" : "No Pain")) = \(value6)"
            index += 7
            
            let labelValue = LabelValue(label: label, value: valueString)
            labelValues.append(labelValue)
        }
        
        return labelValues
    }
}


extension DynamicUIElement {
    
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
}
