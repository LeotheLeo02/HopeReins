//
//  CodableValue.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/27/24.
//

import Foundation

extension CodableValue {
    enum CodingKeys: String, CodingKey {
        
        case int, string, double, bool, date, data
    }
}
public enum CodableValue: Codable, Equatable, Hashable {
    case int(Int)
    case string(String)
    case double(Double)
    case bool(Bool)
    case date(Date)
    case data(Data)
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringValue = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .string(stringValue)
        } else if let intValue = try container.decodeIfPresent(Int.self, forKey: .int) {
            self = .int(intValue)
        } else if let dataValue = try container.decodeIfPresent(Data.self, forKey: .data) {
            self = .data(dataValue)
        } else if let dateValue = try container.decodeIfPresent(Date.self, forKey: .date) {
            self = .date(dateValue)
        } else {
            self = .double(try container.decode(Double.self, forKey: .double))
        }
    }
    
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .string(let value):
        try container.encode(value, forKey: .string)
      case .int(let value):
        try container.encode(value, forKey: .int)
      case .data(let value):
        try container.encode(value, forKey: .data)
      case .double(let value):
        try container.encode(value, forKey: .double)
      case .bool(let value):
          try container.encode(value, forKey: .bool)
      case .date(let value):
          try container.encode(value, forKey: .date)
      }
    }
    
    public static func == (lhs: CodableValue, rhs: CodableValue) -> Bool {
        switch (lhs, rhs) {
        case let (.int(l), .int(r)):
            return l == r
        case let (.string(l), .string(r)):
            return l == r
        case let (.double(l), .double(r)):
            return l == r
        case let (.bool(l), .bool(r)):
            return l == r
        case let (.date(l),  .date(r)):
            return l == r
        case let (.data(l), .data(r)):
            return l == r
        default:
            return false
        }
    }
}

extension CodableValue {
    var stringValue: String {
        get {
            if case .string(let value) = self { return value }
            if case .date(let date) = self { return date.formatted() }
            return ""
        }
        set { self = .string(newValue) }
    }

    var intValue: Int {
        get {
            if case .int(let value) = self { return value }
            return 0
        }
        set { self = .int(newValue) }
    }
    
    var dataValue: Data {
        get {
            if case .data(let value) = self { return value }
            return .init()
        }
        set { self = .data(newValue) }
    }

    var dateValue: Date {
        get {
            if case .date(let date) = self {
                return date
            }
            return .init()
        }
        set { self = .date(newValue)}
    }
}
