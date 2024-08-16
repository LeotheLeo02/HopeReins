//
//  PatientSearch.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/19/23.
//

import Foundation

struct PatientSearchCriteria {
    var name: String?
    var mrn: Int?
}

extension PatientsView {
    
    func lastName(from fileName: String) -> String {
        let components = fileName.split(separator: " ")
        return components.last.map(String.init) ?? ""
    }

    var filteredPatients: [Patient] {
        let filtered = patients.filter { patient in
            var matches = true

            if let name = parseSearchText(searchQuery).name {
                matches = matches && patient.personalFile.properties["File Name"]!.stringValue.localizedCaseInsensitiveContains(name)
            }

            if let mrn = parseSearchText(searchQuery).mrn {
                matches = matches && patient.personalFile.properties["MRN Number"]!.stringValue.description.contains("\(mrn)")
            }

            return matches
        }

        return filtered.sorted {
            lastName(from: $0.personalFile.properties["File Name"]!.stringValue) <
            lastName(from: $1.personalFile.properties["File Name"]!.stringValue)
        }
    }

    private func parseSearchText(_ searchText: String) -> PatientSearchCriteria {
        var criteria = PatientSearchCriteria()

        let components = searchText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for component in components {
            if criteria.mrn == nil, let mrn = Int(component) {
                criteria.mrn = mrn
                continue
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
        guard !searchQuery.isEmpty else { return [] }
        
        let lowercasedSearchText = searchQuery.lowercased()
        var suggestions = Set<String>()
        
        suggestions.formUnion(patients
            .map { $0.personalFile.properties["File Name"]!.stringValue}
            .filter{ $0.lowercased().contains(lowercasedSearchText)}
        )
        
        suggestions.formUnion(patients
            .map { $0.personalFile.properties["MRN Number"]!.stringValue}
            .filter{ $0.lowercased().contains(lowercasedSearchText)}
        )
        
        
        return Array(suggestions)
    }

}
