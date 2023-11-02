//
//  FormAddView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/27/23.
//

import SwiftUI

struct FormAddView: View {
    @Binding var selectedSpecificForm: String?
    var patient: Patient

    var body: some View {
        Group {
            if let ptForm = PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? "") {
                ptForm.view(for: patient, physicalTherabyFormType: PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? ""), ridingFormType: nil)
            } else if let ridingForm = RidingFormType(rawValue: selectedSpecificForm ?? "") {
                ridingForm.view(for: patient, physicalTherabyFormType: nil, ridingFormType: RidingFormType(rawValue: selectedSpecificForm ?? ""))
            } else {
                Text("Unknown form type")
            }
        }
    }
}


protocol FormSpecialGroup {
    func view(for patient: Patient, physicalTherabyFormType: PhysicalTherabyFormType?,  ridingFormType : RidingFormType?) -> AnyView
}

extension PhysicalTherabyFormType: FormSpecialGroup {
    func view(for patient: Patient, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .referral:
            return AnyView(SharedFormView(patient: patient, physicalTherabyFormType: self))
        // Handle other cases
        default:
            return AnyView(EmptyView())
        }
    }
}

extension RidingFormType: FormSpecialGroup {
    func view(for patient: Patient, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .releaseStatement, .coverLetter, .updateCoverLetter :
            return AnyView(SharedFormView(patient: patient, ridingFormType: self))
        case .ridingLessonPlan:
            return AnyView(RidingLessonPlanView(patient: patient))
        default:
            return AnyView(EmptyView())
        }
    }
}
