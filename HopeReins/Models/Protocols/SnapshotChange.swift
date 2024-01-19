//
//  SnapshotChange.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation
import SwiftData

protocol SnapshotChange: Identifiable {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get }
    var id: UUID { get }
    var fileName: String { get }
    var persistentModelID: PersistentIdentifier { get }
    var title: String { get }
    var changeDescriptions: [String] { get }
    var author: String { get }
    var date: Date { get }

    init(properties: PropertiesType, fileName: String, title: String, changeDescriptions: [String], author: String, date: Date)
}
