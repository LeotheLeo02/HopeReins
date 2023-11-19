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
    var filteredPatients: [Patient] {
        if searchQuery.isEmpty {
            return patients
        } else {
            let criteria = parseSearchText(searchQuery)
            return patients.filter { patient in
                var matches = true

                if let name = criteria.name {
                    matches = matches && patient.name.localizedCaseInsensitiveContains(name)
                }

                if let mrn = criteria.mrn {
                    matches = matches && patient.mrn == mrn
                }

                return matches
            }
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

}
