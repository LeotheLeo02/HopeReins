//
//  UIManagement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI
import SwiftData

class UIManagement: ObservableObject {
    
    let treatmentsLabels: [String] = ["Balance Training", "Gait Training", "Therapeutic Activity", "Coordination Activities", "Sensory Processing", "ADL Training", "Praxis Activities", "Bilateral Integration Activities", "Proximal Stabalization Training", "Neuromuscular Re-Education", "HEP Training", "Developmental Skills", "Motor Control Training", "Equipment Assessment/Training", "Hippotherapy", "Therapeutic Exercise", "Postural Alignment Training"]
    
    let problemsLabels: [String] = ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"]
    
    @Published var modifiedProperties: [String : CodableValue]
    @Published var dynamicUIElements: [FormSection] = []
    @Published var errorMessage: String = ""
    @Published var record: MedicalRecordFile
    @Published var isIncrementalFileType: PhysicalTherapyFormType?
    @Published var isRevaluation: Bool = false
    @Published var username: String
    @Published var patient: Patient?
    @Published var isAdding: Bool
    @Published var isEntry: Bool = false
    var changeDescriptions: [DetailedChange] {
        if !isAdding && !isEntry {
            return self.compareStringValues()
        }
        return []
    }
    var modelContext: ModelContext
    
    
    init(modifiedProperties: [String : CodableValue], record: MedicalRecordFile, username: String, patient: Patient?, isAdding: Bool, modelContext: ModelContext) {
        self.modifiedProperties = modifiedProperties
        self.record = record
        self.username = username
        self.patient = patient
        self.isAdding = isAdding
        self.isEntry = isAdding
        self.modelContext = modelContext
        self.dynamicUIElements = getUIElements()
        if isRevaluation && isAdding {
            self.updateGoalsFromLatestRecord(modelContext: modelContext)
        }
    }
    func refreshUI() {
        self.dynamicUIElements = getUIElements()
    }
    
    func updateGoalsFromLatestRecord(modelContext: ModelContext) {
        let reEvaluationRawValue = PhysicalTherapyFormType.reEvaluation.rawValue
        let pocRawValue = PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue
        
        var fetchRequest = FetchDescriptor<MedicalRecordFile>(
            predicate: #Predicate { record in
                (record.fileType == reEvaluationRawValue) || (record.fileType == pocRawValue) && (record.isDead == false)
            },
            sortBy: [SortDescriptor(\.addedSignature?.dateModified, order: .reverse)]
        )
        fetchRequest.fetchLimit = 1
        
    
        if let latestRecord = try? modelContext.fetch(fetchRequest).first {
            modifiedProperties["TE Short Term Goals"] = latestRecord.properties["TE Short Term Goals"]
            modifiedProperties["TE Long Term Goals"] = latestRecord.properties["TE Long Term Goals"]
        }
    }
    
    
    func validateRequiredFields() {
        let requiredFieldsFilled = dynamicUIElements.allSatisfy { section in
            section.elements.allSatisfy { element in
                switch element {
                case .textField(let title, _, let isRequired):
                    return !isRequired || (modifiedProperties[title]?.stringValue.isEmpty == false)
                case .fileUploadButton(let title, _, let isRequired):
                    return !isRequired || (modifiedProperties[title]?.dataValue != nil)
                default:
                    return true
                }
            }
        }
        
        if requiredFieldsFilled {
            addFileAutomatically()
        }
    }
    
    private func addFileAutomatically() {
        if !isAdding {
            return
        }
        
        errorMessage = ""
        
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
        
        isAdding = false
    }
    
//    func addFile(modelContext: ModelContext) {
//        let requiredFields = dynamicUIElements.flatMap { section in
//            section.elements.compactMap { element -> String? in
//                switch element {
//                case .textField(let title, _, let isRequired):
//                    if isRequired && modifiedProperties[title]?.stringValue.isEmpty == true {
//                        return title
//                    }
//                case .fileUploadButton(let title, _, let isRequired):
//                    if isRequired && modifiedProperties[title]?.dataValue == nil {
//                        return title
//                    }
//                default:
//                    break
//                }
//                return nil
//            }
//        }
//        
//        if !requiredFields.isEmpty {
//            errorMessage = "The following required fields are missing: \(requiredFields.joined(separator: ", "))"
//            return
//        }
//        
//        errorMessage = ""
//        
//        record.setUpSignature(addedBy: username, modelContext: modelContext)
//        if isIncrementalFileType != nil {
//            setIncrementalFileName(modelContext: modelContext)
//        }
//        record.properties = modifiedProperties
//        if patient == nil {
//            let newPatient = Patient(personalFile: record)
//            modelContext.insert(newPatient)
//            newPatient.files.append(record)
//        } else {
//            patient!.files.append(record)
//        }
//        modelContext.insert(record)
//       try? modelContext.save()
//    }
    
    func setIncrementalFileName(modelContext: ModelContext) {
        if let incrementalRawValue = isIncrementalFileType?.rawValue {
            if let patientId = patient?.id {
                let descriptor = FetchDescriptor<MedicalRecordFile>(predicate: #Predicate { $0.fileType == incrementalRawValue && $0.patient?.id == patientId})
                let count = (try? modelContext.fetchCount(descriptor)) ?? 0
                modifiedProperties["File Name"] = "\(incrementalRawValue) \(count+1)".codableValue
            }
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
            isIncrementalFileType = .reEvaluation
            isRevaluation = true
            return getReEvaluation()
        case PhysicalTherapyFormType.dailyNote.rawValue:
            isIncrementalFileType = .dailyNote
            return getDailyNote()
        default:
            return []
        }
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


extension UIManagement {
    private func compareStringValues() -> [DetailedChange] {
        var changes = [DetailedChange]()
        
        for (key, oldValue) in self.record.properties {
            if let newValue = modifiedProperties[key], oldValue != newValue {
                let actualValue: CodableValue = oldValue
                
                if let formSection = dynamicUIElements.first(where: { formSection in
                        formSection.elements.contains(where: { element in
                            let wrappedElement  = DynamicUIElementWrapper(element: element)
                            return wrappedElement.id == key
                        })
                    }), let dynamicUIElement = formSection.elements.first(where: { element in
                        let wrappedElement  = DynamicUIElementWrapper(element: element)
                        return wrappedElement.id == key
                    })
                {
                    changes += dynamicUIElement.compare(key: key, oldValue: oldValue, newValue: newValue, actualValue: oldValue)
                }
              }
            }
        return changes
    }
}
