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
    @Published var username: String
    @Published var patient: Patient?
    
    let treatmentsLabels: [String] = ["Balance Training", "Gait Training", "Therapeutic Activity", "Coordination Activities", "Sensory Processing", "ADL Training", "Praxis Activities", "Bilateral Integration Activities", "Proximal Stabalization Training", "Neuromuscular Re-Education", "HEP Training", "Developmental Skills", "Motor Control Training", "Equipment Assessment/Training", "Hippotherapy", "Therapeutic Exercise", "Postural Alignment Training"]
    
    let problemsLabels: [String] = ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"]
    
    init(modifiedProperties: [String : CodableValue], record: MedicalRecordFile, username: String, patient: Patient?) {
        self.modifiedProperties = modifiedProperties
        self.record = record
        self.username = username
        self.patient = patient
        self.dynamicUIElements = getUIElements()
    }
    
    func addFile(modelContext: ModelContext) {
        let newDigitalSig = DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now)
        modelContext.insert(newDigitalSig)
        record.digitalSignature = newDigitalSig
        newDigitalSig.created(by: username)
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
    
    
    //TODO: Fix Inconvienence of showing different changes that are all the same via combined string...
    func revertToPastChange(fieldId: String?, version: Version, revertToAll: Bool, modelContext: ModelContext) -> Bool {
        if revertToAll {
            version.changes.forEach { change in
                self.modifiedProperties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
            }
        } else if let fieldId = fieldId {
            for change in version.changes where change.fieldID == fieldId {
                self.modifiedProperties[change.fieldID] = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)
                version.changes.removeAll { $0 == change }
                modelContext.delete(change)
            }
            
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
        
        for dynamicUIElement in dynamicUIElements {
//            for element in dynamicUIElement.elements {
//                switch element {
//                case .textField(let title, let binding):
//                    <#code#>
//                case .datePicker(let title, let hourAndMinute, let binding):
//                    <#code#>
//                case .numberField(let title, let binding):
//                    <#code#>
//                case .sectionHeader(let title):
//                    <#code#>
//                case .strengthTable(let title, let combinedString):
//                    <#code#>
//                case .singleSelectDescription(let title, let titles, let labels, let combinedString):
//                    <#code#>
//                case .multiSelectWithTitle(let combinedString, let labels, let title):
//                    <#code#>
//                case .multiSelectOthers(let combinedString, let labels, let title):
//                    <#code#>
//                case .dailyNoteTable(let title, let combinedString):
//                    <#code#>
//                case .fileUploadButton(let title, let dataValue):
//                    <#code#>
//                case .physicalTherapyFillIn(let title, let combinedString):
//                    <#code#>
//                case .reEvalFillin(let title, let combinedString):
//                    <#code#>
//                case .dailyNoteFillin(let title, let combinedString):
//                    <#code#>
//                case .textEntries(let title, let combinedString):
//                    <#code#>
//                }
//            }
        }
    }
    
    
    func getUIElements() -> [FormSection] {
        if isUploadFile(fileType: record.fileType) {
            return getUploadFile()
        }
        if record.fileType == "Patient" {
            return getPatientFile()
        }

        if let type = RidingFormType(rawValue: record.fileType) {
            switch type {
            case .ridingLessonPlan:
                return getRidingLessonPlan()
            default:
                return []
            }
        }

        if let type = PhysicalTherapyFormType(rawValue: record.fileType) {
            switch type {
            case .evaluation:
                return getEvaluation()
            case .physicalTherapyPlanOfCare:
                isIncrementalFileType = .physicalTherapyPlanOfCare
                return getPhysicalTherapyPlanOfCare()
            case .reEvaluation:
                return getReEvaluation()
            case .dailyNote:
                isIncrementalFileType = .dailyNote
                return getDailyNote()
            default:
                return []
            }
        }

        return []
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
        guard let data = Data(base64Encoded: propertyChange) else { return .string("") }
        return .data(data)
    case "Date":
        guard let date = DateFormatter().date(from: propertyChange) else { return .string("") }
        return .date(date)
    default:
        return .string("")
    }
}
