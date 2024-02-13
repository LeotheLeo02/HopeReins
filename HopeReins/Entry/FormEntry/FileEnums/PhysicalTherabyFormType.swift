//
//  PhysicalTherabyFormType.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

enum PhysicalTherabyFormType: String, CaseIterable, Hashable {
    case evaluation = "Evaluation"
    case dailyNote = "Daily Note"
    case reEvaluation = "Re-Evaluation"
    case medicalForm = "Medical Form"
    case missedVisit = "Missed Visit"
    case referral = "Physicians Referral"
}
