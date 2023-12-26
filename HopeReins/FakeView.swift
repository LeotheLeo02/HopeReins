//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct FakeView: View {
    @State var combinedString: String = "Knee Flexion//10//20//30//40//Knee Extension//15//25//35//45"
    
    var body: some View {
        LeRomTable(combinedString: $combinedString)
    }
}

