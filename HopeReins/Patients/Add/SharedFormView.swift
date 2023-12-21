//
//  SharedFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/27/23.
//

import SwiftUI

struct SharedFormView: View {
    var patient: Patient
    var user: User
    var ridingFormType: RidingFormType?
    var physicalTherabyFormType: PhysicalTherabyFormType?
    var body: some View {
        VStack {
            FileUploadView( ridingFormType: ridingFormType, phyiscalFormType: physicalTherabyFormType, patient: patient, user: user)
        }
        .padding()
    }
}

