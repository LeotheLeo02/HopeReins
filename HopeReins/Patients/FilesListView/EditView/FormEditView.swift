//
//  FormEditView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/16/23.
//

import SwiftUI
import SwiftData

struct FormEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Binding var file: MedicalRecordFile?
    @State var isEditable: Bool
    var user: User
    var patient: Patient
    var files: [MedicalRecordFile]
    var body: some View {
        VStack {
            if let file = file {
                DynamicFormView(uiManagement: UIManagement(modifiedProperties: file.properties, record: file, username: user.username, patient: patient, isAdding: false, modelContext: modelContext), files: files)
                    .frame(minWidth: 1000, minHeight: 500)
            }
        }
        .navigationTitle(file?.properties["File Name"]?.stringValue ?? "")
        .environment(\.isEditable, isEditable)
    }
    
    private func determineFormType(from file: MedicalRecordFile) -> FormType? {
        if let ridingType = RidingFormType(rawValue: file.fileType) {
            return .riding(ridingType)
        } else if let physicalType = PhysicalTherapyFormType(rawValue: file.fileType) {
            return .physicalTherapy(physicalType)
        }
        else {
            return nil
        }
    }
}
