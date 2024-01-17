//
//  Reflectable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

protocol Reflectable {
    func toDictionary() -> [String: Any]
    func compareProperties(with other: Reflectable) -> [String]
}

extension Reflectable {
    func compareProperties(with other: Reflectable) -> [String] {
        let oldDict = self.toDictionary()
        let newDict = other.toDictionary()
        var changes = [String]()

        for (key, oldValue) in oldDict {
            if let newValue = newDict[key], "\(newValue)" != "\(oldValue)" {
                let changeDescription = key == "data" ? "Changed File Data" : "\(key) changed from \"\(oldValue)\" to \"\(newValue)\""
                changes.append(changeDescription)
            }
        }
        
        return changes
    }
}

