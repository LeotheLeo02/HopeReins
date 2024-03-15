//
//  FileModification.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

enum FileModification: String, Codable {
    case added = "Created"
    case edited = "Modified"
    case deleted = "Deleted"
}
