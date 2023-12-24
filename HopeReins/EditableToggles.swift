//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct FakeView: View {
    @State var boolString: String = "NT: Lebron James"
    var body: some View {
        VStack {
            SingleSelectLastDescription(combinedString: $boolString, title: "Static", labels: ["Normal", "Good", "Fair", "Poor", "NT"])
        }
        .padding()
    }
}

#Preview {
    FakeView()
}
