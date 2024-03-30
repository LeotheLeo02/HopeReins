//
//  RevertingChanges.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 3/30/24.
//

import SwiftUI
import SwiftData

extension UIManagement {
    
    func revertToVersion(selectedVersion: Version?, modelContext: ModelContext) {
        record.revertToPastChange(fieldId: nil, version: selectedVersion!, revertToAll: true, modelContext: modelContext)
        modifiedProperties = record.properties
    }
    
    
    func revertToPastVersion(selectedVersion: Version?, selectedFieldChange: String?, change: PastChange, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        var isLastChange: Bool = false
        if  revertToPastChange(fieldId: selectedFieldChange, version: selectedVersion!, revertToAll: revertToAll, modelContext: modelContext) {
            record.versions.removeAll{ $0 == selectedVersion! }
            modelContext.delete(selectedVersion!)
            isLastChange = true
        }
        record.properties = modifiedProperties
        
        return isLastChange
    }
    
    
    func revertToPastChange(fieldId: String?, version: Version, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        if revertToAll {
            version.changes.forEach { change in
                self.modifiedProperties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
            }
        } else if let fieldId = fieldId, let change = version.changes.first(where: { $0.fieldID == fieldId }) {
            self.modifiedProperties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
            version.changes.removeAll { $0 == change }
            modelContext.delete(change)
            try? modelContext.save()
            return version.changes.isEmpty
        }
        
        try? modelContext.save()
        return false
    }
}
