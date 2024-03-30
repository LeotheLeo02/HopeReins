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
    var isRequired: Bool
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PropertyHeader(title: title)
                if isRequired {
                    Text("*")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
            }
            TextField("", text: $text, axis: .vertical)
                .padding(.bottom)
                .labelsHidden()
                .disabled(!isEditable)
        }
    }
}


struct IsEditableKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var isEditable: Bool {
        get { self[IsEditableKey.self] }
        set { self[IsEditableKey.self] = newValue }
    }
}
