//
//  RestrictedNumberField.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 3/2/24.
//

import SwiftUI

struct RestrictedNumberField: View {
    var range: ClosedRange<Int>
    @Binding var number: Int

    var body: some View {
        TextField("Number", value: Binding(
            get: { self.number },
            set: {
                self.number = min(max($0, range.lowerBound), range.upperBound)
            }
        ), format: .number)
    }
}
