//
//  EncodedFile.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 8/14/24.
//

import Foundation
import UniformTypeIdentifiers

struct EncodedFile: Codable {
    let data: Data
    let typeIdentifier: String
    
    init(data: Data, type: UTType) {
        self.data = data
        self.typeIdentifier = type.identifier
    }
    
    var fileType: UTType? {
        return UTType(typeIdentifier)
    }
}
