//
//  BasicTextField.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

struct BasicTextField: View {
    @Environment(\.isEditable) var isEditable: Bool
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
            .labelsHidden()
            .disabled(!isEditable)
    }
}


struct IsEditableKey: EnvironmentKey {
    static let defaultValue: Bool = true  // default value is editable
}

extension EnvironmentValues {
    var isEditable: Bool {
        get { self[IsEditableKey.self] }
        set { self[IsEditableKey.self] = newValue }
    }
}
