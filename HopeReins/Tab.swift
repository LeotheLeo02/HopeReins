//
//  Tab.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/21/23.
//

import Foundation

enum Tab: String, CaseIterable {
    case Home
    case AllPatients = "All Patients"
    case Scheduler
    case Media
    
    var imageName: String {
        switch self {
        case .Home:
            return "house"
        case .AllPatients:
            return "person.2"
        case .Scheduler:
            return "calendar"
        case .Media:
            return "photo"
        }
    }
}
