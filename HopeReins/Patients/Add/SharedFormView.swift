//
//  SharedFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/27/23.
//

import SwiftUI

struct SharedFormView: View {
    var patient: Patient
    var ridingFormType: RidingFormType?
    var physicalTherabyFormType: PhysicalTherabyFormType?
    var body: some View {
        VStack {
            ReleaseStatementView(ridingFormType: ridingFormType, phyiscalFormType: physicalTherabyFormType, patient: patient)
        }
    }
}

