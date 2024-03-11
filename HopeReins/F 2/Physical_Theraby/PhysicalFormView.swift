//
//  PhysicalFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct PhysicalFormView: View {
    var physicalFormType: PhysicalTherabyFormType
    var body: some View {
        switch physicalFormType {
        case .evaluation:
            Text("Evaluation")
        case .dailyNote:
            Text("Daily Note")
        case .reEvaluation:
            Text("Re-Evaluation")
        case .medicalForm:
            Text("Medical Form")
        case .missedVisit:
            Text("Missed Visit")
        case .referral:
            Text("Referral")
        }
    }
}

#Preview {
    PhysicalFormView(physicalFormType: .evaluation)
}
