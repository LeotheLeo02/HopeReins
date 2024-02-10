//
//  Reflectable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI
import SwiftData


struct ChangeDescription: Hashable {
    var displayName: String?
    var id: String
    var oldValue: CodableValue
    var value: CodableValue
    var actualValue: CodableValue
}
