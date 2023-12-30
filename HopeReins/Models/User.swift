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
        var isAdmin: Bool
        var isLoggedIn: Bool = false
        
        init(username: String, password: String, isAdmin: Bool = false) {
            self.username = username
            self.password = password
            self.isAdmin = isAdmin
        }
    }
}
