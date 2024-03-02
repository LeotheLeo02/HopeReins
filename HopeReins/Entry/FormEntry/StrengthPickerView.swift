//
//  RestrictedNumberField'.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

struct StrengthIndicator: Identifiable {
    var id: UUID = UUID()
    var value: String
    var label: String
}

struct StrengthPickerView: View {
    @Binding var value: String
    @State var strengthIndicators: [StrengthIndicator] =
    [
        StrengthIndicator(value: "0", label: "0 No contractions felt in muscle"),
        StrengthIndicator(value: "1", label: "1 Tendon becomes prominent or feeble contraction felt in the muscle, but no visible movement of the part."),
        StrengthIndicator(value: "2-", label: "2- Move through partial range of motion"),
        StrengthIndicator(value: "2", label: "2 Moves through the complete range of motion"),
        StrengthIndicator(value: "2+", label: "2+ Moves through the partial range of motion"),
        StrengthIndicator(value: "3-", label: "3- Gradual release from test position"),
        StrengthIndicator(value: "3", label: "3 Holds test position (no added pressure)"),
        StrengthIndicator(value: "3+", label: "3+ Holds test position against slight pressure"),
        StrengthIndicator(value: "4-", label: "4- Holds test position against slight to moderate pressure"),
        StrengthIndicator(value: "4", label: "4 Holds test position against moderate pressure"),
        StrengthIndicator(value: "4+", label: "4+ Holds test position against moderate to strong pressure"),
        StrengthIndicator(value: "5", label: "5 Holds test positiion against strong pressure")
    ]
    var body: some View {
        Picker("", selection: $value) {
            ForEach(strengthIndicators) { strengthIndicator in
                Text(strengthIndicator.label)
                    .id(strengthIndicator.value)
            }
        }
    }
}

struct PreviewView: View {
    @State var selection: String = ""
    var body: some View {
        StrengthPickerView(value: $selection)
    }
}

#Preview {
    PreviewView()
}
