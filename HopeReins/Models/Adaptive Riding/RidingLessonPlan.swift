//
//  RidingLesson.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import Foundation
import SwiftData
import SwiftUI

extension HopeReinsSchemaV2 {
    @Model final class PastChange {
        var date: Date = Date.now
        var reason: String = ""
        var propertyChanges: [String: CodableValue] = [:]
        var author: String = ""
    

        init (date: Date, reason: String, propertyChanges: [String : CodableValue], author: String) {
            self.date = date
            self.reason = reason
            self.propertyChanges = propertyChanges
            self.author = author
        }

    }
    
}
