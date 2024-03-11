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
        StrengthIndicator(value: "0", label: "No contractions felt in muscle"),
        StrengthIndicator(value: "1", label: "Tendon becomes prominent or feeble contraction felt in the muscle, but no visible movement of the part."),
        StrengthIndicator(value: "2-", label: "Move through partial range of motion"),
        StrengthIndicator(value: "2", label: "Moves through the complete range of motion"),
        StrengthIndicator(value: "2+", label: "Moves through the partial range of motion"),
        StrengthIndicator(value: "3-", label: "Gradual release from test position"),
        StrengthIndicator(value: "3", label: "Holds test position (no added pressure)"),
        StrengthIndicator(value: "3+", label: "Holds test position against slight pressure"),
        StrengthIndicator(value: "4-", label: "Holds test position against slight to moderate pressure"),
        StrengthIndicator(value: "4", label: "Holds test position against moderate pressure"),
        StrengthIndicator(value: "4+", label: "Holds test position against moderate to strong pressure"),
        StrengthIndicator(value: "5", label: "Holds test positiion against strong pressure")
    ]
    var body: some View {
        Menu {
            ForEach(strengthIndicators) { strengthIndicator in
                Button {
                    value = strengthIndicator.value
                } label: {
                    Text(strengthIndicator.value + "\t" + strengthIndicator.label)
                }
            }
        } label: {
            Text(value)
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
