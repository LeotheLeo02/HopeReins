//
//  FormAddView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/27/23.
//

import SwiftUI

struct FormAddView: View {
    @Binding var selectedSpecificForm: FormType?
    var patient: Patient
    var user: User
    
    var body: some View {
        Group {
            if let formType = selectedSpecificForm {
                dynamicFormView(for: formType)
            } else {
                Text("No Selected Form Type")
            }
        }
    }
    
    private func dynamicFormView(for formType: FormType) -> some View {
        let fileType: String
        switch formType {
        case .riding(let ridingType):
            fileType = ridingType.rawValue
        case .physicalTherapy(let therapyType):
            fileType = therapyType.rawValue
        }
        
        let record = MedicalRecordFile(patient: patient, fileType: fileType)
        
        return DynamicFormView(uiManagement: UIManagement(modifiedProperties: record.properties, record: record), isAdding: true, username: user.username)
    }
}

