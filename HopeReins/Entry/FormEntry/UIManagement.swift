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
    
    // Checks for any changes if not adding
    var changeDescriptions: [DetailedChange] {
        if !isAdding {
            return self.compareProperties()
        }
        return []
    }
    
    // Checks if all required properties are filled
    var isFileComplete: Bool {
        dynamicUIElements.allSatisfy { section in
            section.elements.allSatisfy { element in
                switch element {
                case .textField(let title, _, let isRequired):
                    return !isRequired || !(modifiedProperties[title]?.stringValue.isEmpty ?? true)
                case .fileUploadButton(let title, _, let isRequired):
                    return !isRequired || (modifiedProperties[title]?.dataValue.isEmpty == false)
                default:
                    return true
                }
            }
        }
    }
    
    // Checks if all properties are unchanged
    var isEmptyNewFile: Bool {
        !modifiedProperties.contains { !$0.value.isInitialValue }
    }

    var modelContext: ModelContext
    
    
    init(modifiedProperties: [String : CodableValue], record: MedicalRecordFile, username: String, patient: Patient?, isAdding: Bool, modelContext: ModelContext) {
        self.modifiedProperties = modifiedProperties
        self.record = record
        self.username = username
        self.patient = patient
        self.isAdding = isAdding
        self.modelContext = modelContext
        self.dynamicUIElements = getUIElements()
    }
    
    func refreshUI() {
        self.dynamicUIElements = getUIElements()
    }
    
    func addFile() {
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
    }
    
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
        var sections: [FormSection] = []
        
        switch record.fileType {
        case _ where isUploadFile(fileType: record.fileType):
            sections = getUploadFile()
        case "Patient":
            sections = getPatientFile()
        case RidingFormType.ridingLessonPlan.rawValue:
            sections = getRidingLessonPlan()
        case PhysicalTherapyFormType.evaluation.rawValue:
            sections = getEvaluation()
        case PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue:
            isIncrementalFileType = .physicalTherapyPlanOfCare
            sections = getPhysicalTherapyPlanOfCare()
        case PhysicalTherapyFormType.reEvaluation.rawValue:
            isIncrementalFileType = .reEvaluation
            isRevaluation = true
            sections = getReEvaluation()
        case PhysicalTherapyFormType.dailyNote.rawValue:
            isIncrementalFileType = .dailyNote
            sections = getDailyNote()
        case PhysicalTherapyFormType.missedVisit.rawValue:
            isIncrementalFileType = .missedVisit
            sections = getMissedVisit()
        case PhysicalTherapyFormType.discharge.rawValue:
            sections = getDischargeNote()
        default:
            sections = []
        }
        
        return getServiceDateProperty() + sections
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
    private func compareProperties() -> [DetailedChange] {
        var changes = [DetailedChange]()
        
        for (key, oldValue) in self.record.properties {
            if let newValue = modifiedProperties[key], oldValue != newValue && !oldValue.isInitialValue {
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
