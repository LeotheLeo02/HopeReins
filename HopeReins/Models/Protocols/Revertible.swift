//
//  Revertible.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation
import SwiftData

protocol Revertible {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get set }
    mutating func revertToProperties(_ properties: PropertiesType, fileName: String, modelContext: ModelContext)
}
