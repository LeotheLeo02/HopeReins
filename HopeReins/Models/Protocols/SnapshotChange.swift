//
//  SnapshotChange.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation

protocol SnapshotChange {
    associatedtype PropertiesType: ResettableProperties
    var properties: PropertiesType { get }
    var fileName: String { get }
    var title: String { get }
    var changeDescription: String { get }
    var author: String { get }
    var date: Date { get }

    init(properties: PropertiesType, fileName: String, title: String, changeDescription: String, author: String, date: Date)
}
