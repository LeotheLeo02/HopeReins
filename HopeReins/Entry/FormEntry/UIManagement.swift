//
//  UIManagement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI
import SwiftData

class UIManagement: ObservableObject {
    @Published var modifiedProperties: [String : CodableValue]
    @Published var dynamicUIElements: [FormSection] = []
    @Published var record: MedicalRecordFile
    @Published var isIncrementalFileType: PhysicalTherapyFormType?
    @Published var isRevaluation: Bool = false
    @Published var username: String
    @Published var patient: Patient?
    @Published var isAdding: Bool
    
    let treatmentsLabels: [String] = ["Balance Training", "Gait Training", "Therapeutic Activity", "Coordination Activities", "Sensory Processing", "ADL Training", "Praxis Activities", "Bilateral Integration Activities", "Proximal Stabalization Training", "Neuromuscular Re-Education", "HEP Training", "Developmental Skills", "Motor Control Training", "Equipment Assessment/Training", "Hippotherapy", "Therapeutic Exercise", "Postural Alignment Training"]
    
    let problemsLabels: [String] = ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"]
    
    init(modifiedProperties: [String : CodableValue], record: MedicalRecordFile, username: String, patient: Patient?, isAdding: Bool, modelContext: ModelContext) {
        self.modifiedProperties = modifiedProperties
        self.record = record
        self.username = username
        self.patient = patient
        self.isAdding = isAdding
        self.dynamicUIElements = getUIElements()
        if isRevaluation && isAdding {
            self.updateGoalsFromLatestRecord(modelContext: modelContext)
        }
    }
    
    func updateGoalsFromLatestRecord(modelContext: ModelContext) {
        let reEvaluationRawValue = PhysicalTherapyFormType.reEvaluation.rawValue
        let pocRawValue = PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue
        
        var fetchRequest = FetchDescriptor<MedicalRecordFile>(
            predicate: #Predicate { record in
                (record.fileType == reEvaluationRawValue) || (record.fileType == pocRawValue)
            },
            sortBy: [SortDescriptor(\.digitalSignature?.dateModified, order: .reverse)]
        )
        fetchRequest.fetchLimit = 1
        
        if let latestRecord = try? modelContext.fetch(fetchRequest).first {
            modifiedProperties["TE Short Term Goals"] = latestRecord.properties["TE Short Term Goals"]
            modifiedProperties["TE Long Term Goals"] = latestRecord.properties["TE Long Term Goals"]
        }
    }
    
    func addFile(modelContext: ModelContext) {
        record.setUpSignature(addedBy: username, modelContext: modelContext)
        if isIncrementalFileType != nil {
            setIncrementalFileName(modelContext: modelContext)
        }
        record.properties = modifiedProperties
        if patient == nil {
            let newPatient = Patient(personalFile: record)
            modelContext.insert(newPatient)
            newPatient.files.append(record)
        } else {
            patient!.files.append(record)
        }
        modelContext.insert(record)
       try? modelContext.save()
    }
    
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
    
    func setIncrementalFileName(modelContext: ModelContext) {
        if let incrementalRawValue = isIncrementalFileType?.rawValue {
            let descriptor = FetchDescriptor<MedicalRecordFile>(predicate: #Predicate { $0.fileType == incrementalRawValue })
            let count = (try? modelContext.fetchCount(descriptor)) ?? 0
            modifiedProperties["File Name"] = "\(incrementalRawValue) \(count)".codableValue
        }
        
    }
    
    
    func getUIElements() -> [FormSection] {
        switch record.fileType {
        case _ where isUploadFile(fileType: record.fileType):
            return getUploadFile()
        case "Patient":
            return getPatientFile()
        case RidingFormType.ridingLessonPlan.rawValue:
            return getRidingLessonPlan()
        case PhysicalTherapyFormType.evaluation.rawValue:
            return getEvaluation()
        case PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue:
            isIncrementalFileType = .physicalTherapyPlanOfCare
            return getPhysicalTherapyPlanOfCare()
        case PhysicalTherapyFormType.reEvaluation.rawValue:
            isRevaluation = true
            return getReEvaluation()
        case PhysicalTherapyFormType.dailyNote.rawValue:
            isIncrementalFileType = .dailyNote
            return getDailyNote()
        default:
            return []
        }
    }
    
    func stringBinding(for key: String, defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: {
                if self.modifiedProperties[key] == nil {
                    self.modifiedProperties[key] = .string(defaultValue)
                }
                return self.modifiedProperties[key]?.stringValue ?? defaultValue
            },
            set: { self.modifiedProperties[key] = .string($0) }
        )
    }

    func intBinding(for key: String, defaultValue: Int = 0) -> Binding<Int> {
        Binding<Int>(
            get: {
                if self.modifiedProperties[key] == nil {
                    self.modifiedProperties[key] = .int(defaultValue)
                }
                return self.modifiedProperties[key]?.intValue ?? defaultValue
            },
            set: { self.modifiedProperties[key] = .int($0) }
        )
    }


    func dataBinding(for key: String, defaultValue: Data = .init()) -> Binding<Data?> {
        Binding<Data?>(
            get: {
                if self.modifiedProperties[key] == nil {
                    self.modifiedProperties[key] = .data(defaultValue)
                }
                return self.modifiedProperties[key]?.dataValue ?? defaultValue
            },
            set: { self.modifiedProperties[key] = .data($0!) }
        )
    }


    
    func dateBinding(for key: String, defaultValue: Date = .now) -> Binding<Date> {
        Binding<Date>(
            get: {
                if self.modifiedProperties[key] == nil {
                    self.modifiedProperties[key] = .date(defaultValue)
                }
                return self.modifiedProperties[key]?.dateValue ?? defaultValue
            },
            set: { self.modifiedProperties[key] = .date($0) }
        )
    }

}

public func convertToCodableValue(type: String, propertyChange: String) -> CodableValue {
    switch type {
    case "String":
        return .string(propertyChange)
    case "Data":
        return .data(Data(base64Encoded: propertyChange) ?? .init())
    case "Date":
        return .date(DateFormatter().date(from: propertyChange) ?? .now)
    default:
        return .string("")
    }
}
