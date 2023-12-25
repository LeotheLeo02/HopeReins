//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct FakeView: View {
    @State var boolString: String = ""
    var body: some View {
        VStack {
            MultiSelectWithTitle(boolString: $boolString, labels: ["Balance Training", "Gait Training", "Minimal"], title: "Treatment Received")
        }
        .padding()
    }
}

