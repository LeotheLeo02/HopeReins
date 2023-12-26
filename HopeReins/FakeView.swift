//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct FakeView: View {
    @State var combinedString: String = ""
    
    var body: some View {
        LeRomTable(combinedString: $combinedString)
    }
}

