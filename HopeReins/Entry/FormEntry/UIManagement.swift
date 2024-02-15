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
    @Published var username: String
    @Published var patient: Patient?
    
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
    
    
    func revertToPastVersion(selectedVersion: Version?, selectedFieldChange: String?, change: PastChange, modelContext: ModelContext) -> Bool {
        var isLastChange: Bool = false
        if  record.revertToPastChange(fieldId: selectedFieldChange, version: selectedVersion!, revertToAll: false, modelContext: modelContext) {
            record.versions.removeAll{ $0 == selectedVersion! }
            modelContext.delete(selectedVersion!)
            isLastChange = true
        }
        modifiedProperties[selectedFieldChange!] = CodableValue.string(change.propertyChange)
        record.properties[selectedFieldChange!] = CodableValue.string(change.propertyChange)
        return isLastChange
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

        if let type = PhysicalTherabyFormType(rawValue: record.fileType) {
            switch type {
            case .evaluation:
                return getEvaluation()
            case .physicalTherabyPlanOfCare:
                return getPhysicalTherabyPlanOfCare()
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
