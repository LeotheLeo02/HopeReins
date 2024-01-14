//
//  ChangeRecordable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/29/23.
//

import Foundation
import SwiftData

protocol ChangeRecordable {
    associatedtype PropertiesType: Reflectable
    associatedtype ChangeType: SnapshotChange where ChangeType.PropertiesType == PropertiesType
    var pastChanges: [ChangeType] { get set }
    
    func addChangeRecord(_ change: ChangeType, modelContext: ModelContext)
}
