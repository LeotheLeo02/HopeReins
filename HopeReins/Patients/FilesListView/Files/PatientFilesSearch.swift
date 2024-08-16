//
//  PatientFilesSearch.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/19/23.
//

import SwiftUI

extension PatientFilesListView {
    var filteredFiles: [MedicalRecordFile] {
        if searchText.isEmpty {
            return files.filter { $0.fileType != "Patient" }
        } else {
            let criteria = parseSearchText(searchText)
            return files.filter { file in
                var matches = true
                
                // Exclude files with fileType = "Patient"
                if file.fileType == "Patient" {
                    return false
                }
                
                // Check if the file name matches
                if let name = criteria.name {
                    matches = matches && file.properties["File Name"]!.stringValue.localizedCaseInsensitiveContains(name)
                }
                
                // Check if the file date matches
                if let date = criteria.date {
                    let fileDate = getFileDate(file)
                    matches = matches && Calendar.current.isDate(fileDate, inSameDayAs: date)
                }
                
                // Check if the file type matches
                if let fileType = criteria.fileType {
                    matches = matches && file.fileType.localizedStandardContains(fileType)
                }
                
                return matches
            }
        }
    }
    
    private func getFileDate(_ file: MedicalRecordFile) -> Date {
        if let dateOfServiceString = file.properties["Date of Service"]?.stringValue,
           let formattedDate = formatPerformedDateWithDate(from: dateOfServiceString) {
            return formattedDate
        } else {
            return file.addedSignature!.dateModified
        }
    }
    
    private func formatPerformedDateWithDate(from combinedString: String) -> Date? {
        let onDateRegex = try! NSRegularExpression(pattern: "On (\\d{4}-\\d{2}-\\d{2})")
        
        if let onDateMatch = onDateRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            let onDateString = String(combinedString[Range(onDateMatch.range(at: 1), in: combinedString)!])
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return dateFormatter.date(from: onDateString)
        }
        
        return nil
    }
    
    
    private func parseSearchText(_ searchText: String) -> SearchCriteria {
        var criteria = SearchCriteria()
        
        let physicalTherapyTypes = PhysicalTherapyFormType.allCases.map { $0.rawValue.lowercased() }
        let ridingTypes = RidingFormType.allCases.map { $0.rawValue.lowercased() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        let components = searchText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        for component in components {
            let lowercasedComponent = component.lowercased()
            if criteria.date == nil, let date = dateFormatter.date(from: component) {
                criteria.date = date
                continue
            }
            
            if criteria.fileType == nil {
                if physicalTherapyTypes.contains(lowercasedComponent) {
                    criteria.fileType = component
                    continue
                } else if ridingTypes.contains(lowercasedComponent) {
                    criteria.fileType = component
                    continue
                }
            }
            
            if criteria.name == nil {
                criteria.name = component
            } else {
                criteria.name = "\(criteria.name!) \(component)"
            }
        }
        
        return criteria
    }
    
    var searchSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        
        let lowercasedSearchText = searchText.lowercased()
        var suggestions = Set<String>()
        
        suggestions.formUnion(files
            .filter { $0.fileType != "Patient" } // Filter out files with fileType = "Patient"
            .map { $0.properties["File Name"]!.stringValue }
            .filter { $0.lowercased().contains(lowercasedSearchText) })
        
        suggestions.formUnion(files
            .filter { $0.fileType != "Patient" } // Filter out files with fileType = "Patient"
            .map { $0.fileType }
            .filter { $0.lowercased().contains(lowercasedSearchText) })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        suggestions.formUnion(
            files
                .filter { $0.fileType != "Patient" }
                .map { file in
                    // Try to extract and format "Date of Service"
                    if let dateOfServiceString = file.properties["Date of Service"]?.stringValue,
                       let formattedDate = formatPerformedDateFromString(from: dateOfServiceString) {
                        return formattedDate
                    } else {
                        return dateFormatter.string(from: file.addedSignature!.dateModified)
                    }
                }
                .filter { $0.contains(searchText) }
        )
        
        return Array(suggestions)
        
    }
    

}
