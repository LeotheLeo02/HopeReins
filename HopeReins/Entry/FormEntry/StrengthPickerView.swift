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
        StrengthIndicator(value: "1", label: "No visible or palpable contraction"),
        StrengthIndicator(value: "2.", label: "(Trace) Visible or palpable contraction, but no ROM"),
        StrengthIndicator(value: "2-", label: "(Poor-) Partial ROM, gravity eliminated"),
        StrengthIndicator(value: "3.", label: "(Poor) Full ROM, gravity eliminated"),
        StrengthIndicator(value: "2+", label: "(Poor+) Slight resistance in gravity eliminated OR <1/2 range against gravity"),
        StrengthIndicator(value: "3-", label: "(Fair-)>1/2 but < full ROM, against gravity"),
        StrengthIndicator(value: "4.", label: "(Fair) Full ROM against gravity"),
        StrengthIndicator(value: "3+", label: "(Fair+) Full ROM against gravity, slight resistance"),
        StrengthIndicator(value: "4-", label: "(Good-) Full ROM against gravity, mild resistance"),
        StrengthIndicator(value: "5.", label: "(Good) Full ROM against gravity, moderate resistance"),
        StrengthIndicator(value: "4+", label: "(Good+) Full ROM against gravity, almost full resistance"),
        StrengthIndicator(value: "5", label: "(Normal Maximal resistance")
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
