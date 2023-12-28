//
//  BasicTextField.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

struct BasicTextField: View {
    var title: String
    var textFieldHint: String {
        return title.replacingOccurrences(of: ":", with: "...").lowercased()
    }
    @Binding var text: String
    var body: some View {
        CustomSectionHeader(title: title)
        TextField(textFieldHint, text: $text, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .padding(.bottom)
    }
}
