//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct FakeView: View {
    @State var boolString: String = "30mins /wk x forever"
    var body: some View {
        VStack {
            RecommendedPhysicalTherabyFillIn(combinedString: $boolString)
        }
        .padding()
    }
}

