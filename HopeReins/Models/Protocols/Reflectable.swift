//
//  Reflectable.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

protocol Reflectable {
    func toDictionary() -> [String: Any]
    static func compareProperties(old: Reflectable, new: Reflectable) -> [String]
}

extension Reflectable {
    static func compareProperties(old: Reflectable, new: Reflectable) -> [String] {
        let oldDict = old.toDictionary()
        let newDict = new.toDictionary()
        var changes = [String]()
        
        for (key, oldValue) in oldDict {
            if let newValue = newDict[key], "\(newValue)" != "\(oldValue)" {
                switch key {
                case "data":
                    changes.append("Changed File Data")
                default:
                    changes.append("\(key) changed from \"\(oldValue)\" to \"\(newValue)\"")
                }
            }
        }
        
        return changes
    }
}

