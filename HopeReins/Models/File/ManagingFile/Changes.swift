//
//  Changes.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation
import SwiftData


extension MedicalRecordFile {

    func addPastChanges(reason: String, changes: [ChangeDescription], author: String, modelContext: ModelContext) {
        let newVersion = Version(date: Date.now, reason: reason, author: author)
        var groupedDescriptions = [String: String]()
        var actualValues = [String: String]()

        for change in changes {
            let changeDescription = "\(change.displayName): \(change.oldValue)"
            // Update the description for the change
            if let existing = groupedDescriptions[change.id] {
                groupedDescriptions[change.id] = "\(existing)\n\(changeDescription)"
            } else {
                groupedDescriptions[change.id] = changeDescription
            }
            // Update the actual value for the change
            actualValues[change.id] = change.actualValue
        }

        let newChanges = groupedDescriptions.map { id, description in
            PastChange(fieldID: id, type: "String", propertyChange: actualValues[id] ?? "", displayName: description)
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

    
    func convertToCodableValue(type: String, propertyChange: String) -> CodableValue {
        switch type {
        case "String":
            return .string(propertyChange)
        case "Data":
            guard let data = propertyChange.data(using: .utf8) else { return .string("") }
            return .data(data)
        case "Date":
            guard let date = DateFormatter().date(from: propertyChange) else { return .string("") }
            return .date(date)
        default:
            return .string("")
        }
    }
    
    
    func revertToPastChange(fieldId: String?, version: Version, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        if revertToAll {
            version.changes.forEach { change in
                self.properties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
            }
        } else if let fieldId = fieldId {
            for change in version.changes where change.fieldID == fieldId {
                self.properties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
                version.changes.removeAll { $0 == change }
                modelContext.delete(change)
            }
            
            return version.changes.isEmpty
        }
        
        try? modelContext.save()
        return false
    }
    
    
}
