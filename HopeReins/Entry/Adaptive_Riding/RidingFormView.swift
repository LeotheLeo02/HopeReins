//
//  RidingFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct RidingFormView: View {
    var rideFormType: RidingFormType
    var body: some View {
        Form {
            VStack {
                switch rideFormType {
                case .releaseStatement:
                    ReleaseStatementView()
                case .ridingLessonPlan:
                    RidingLessonPlanView()
                case .yearlyReview:
                    Text("Yearly Review")
                case .medicalForm:
                    Text("Medical Form")
                case .missedVisit:
                    Text("Missed Visit")
                }
            }
            .padding()
        }
    }
}

#Preview {
    RidingFormView(rideFormType: .ridingLessonPlan)
}
