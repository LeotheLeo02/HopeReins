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
    var user: User

    var body: some View {
        Group {
            if let ptForm = PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? "") {
                ptForm.view(for: patient, user: user, physicalTherabyFormType: PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? ""), ridingFormType: nil)
            } else if let ridingForm = RidingFormType(rawValue: selectedSpecificForm ?? "") {
                ridingForm.view(for: patient, user: user, physicalTherabyFormType: nil, ridingFormType: RidingFormType(rawValue: selectedSpecificForm ?? ""))
            } else {
                Text("Unknown form type")
            }
        }
    }
}


protocol FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?,  ridingFormType : RidingFormType?) -> AnyView
}

extension PhysicalTherabyFormType: FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .referral:
            return AnyView(EditingView<UploadFile>(modifiedProperties: UploadFileProperties(), initialFileName: "", username: user.username, patient: patient, phyiscalFormType: self))
        // Handle other cases
        default:
            return AnyView(EmptyView())
        }
    }
}

extension RidingFormType: FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .releaseStatement, .coverLetter, .updateCoverLetter :
            return AnyView(EditingView<UploadFile>(modifiedProperties: UploadFileProperties(), initialFileName: "", username: user.username, patient: patient, ridingFormType: self))
        case .ridingLessonPlan:
            return AnyView(RidingLessonPlanView(username: user.username, patient: patient))
        default:
            return AnyView(EmptyView())
        }
    }
}

