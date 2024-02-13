//
//  RidingLesson.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//
import SwiftData
import SwiftUI

extension HopeReinsSchemaV2 {
    @Model final class PastChange {
        var fieldID: String = ""
        var type: String = ""
        var displayName: String = ""
        var propertyChange: String = ""

        init (fieldID: String, type: String, propertyChange: String, displayName: String) {
            self.fieldID = fieldID
            self.type = type
            self.propertyChange = propertyChange
            self.displayName = displayName
        }

    }
    
    @Model final class Version {
        var date: Date = Date.now
        var reason: String = ""
        var author: String = ""
        var changes: [PastChange] = []
        
        init(date: Date, reason: String, author: String) {
            self.date = date
            self.reason = reason
            self.author = author
        }
    }
    
}
