//
//  DetailChange.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

struct DetailedChange: Hashable {
    var label: String
    var id: String
    var oldValue: CodableValue
    var newValue: CodableValue
    var actualValue: CodableValue
}
