//
//  DegreeField.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

struct DegreeField: View {
    var range: ClosedRange<Double> = 0...360
    @Binding var degree: Double

    var body: some View {
        HStack {
            TextField("Degrees", value: Binding(
                get: { self.degree },
                set: {
                    self.degree = min(max($0, range.lowerBound), range.upperBound)
                }
            ), format: .number)
            Text("°")
        }
    }
}
