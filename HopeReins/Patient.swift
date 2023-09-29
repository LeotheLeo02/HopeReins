//
//  Patient.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/27/23.
//

import SwiftData
import Foundation

@Model final class Patient {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
