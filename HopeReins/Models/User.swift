//
//  User.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/20/23.
//

import SwiftData
import Foundation

extension HopeReinsSchemaV2 {
    
    @Model final class User {
        var username: String
        var password: String
        var isLoggedIn: Bool = true
        
        init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }
}
