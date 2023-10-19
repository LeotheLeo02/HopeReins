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
                case .coverLetter:
                    CoverLetterView()
                case .updateCoverLetter:
                    Text("Update Cover Letter")
                case .ridingLessonPlan:
                    RidingLessonPlanView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    RidingFormView(rideFormType: .ridingLessonPlan)
}
