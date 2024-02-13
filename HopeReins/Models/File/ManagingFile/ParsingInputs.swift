//
//  ParsingInputs.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

extension MedicalRecordFile {
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


}
