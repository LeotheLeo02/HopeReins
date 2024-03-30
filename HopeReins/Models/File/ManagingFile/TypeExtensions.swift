//
//  ParsingInputs.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import Foundation

extension String {
    var codableValue: CodableValue {
        return CodableValue.string(self)
    }
}
extension Data {
    var codableValue: CodableValue {
        return CodableValue.data(self)
    }
}

extension Int {
    var codableValue: CodableValue {
        return CodableValue.int(self)
    }
}


extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
