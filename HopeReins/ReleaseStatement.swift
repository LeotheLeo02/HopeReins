//
//  ReleaseStatement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/7/23.
//

import Foundation
import SwiftData

@Model final class ReleaseStatement {
    var id = UUID()
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
}
