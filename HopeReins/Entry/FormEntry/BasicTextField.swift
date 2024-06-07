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


struct BasicTextEditor: View {
    @Environment(\.isEditable) var isEditable: Bool
    var title: String
    var isRequired: Bool
    @Binding var mainText: String
    @State var editableText: String = ""
    
    init(title: String, isRequired: Bool, mainText: Binding<String>) {
        self.title = title
        self.isRequired = isRequired
        self._mainText = mainText
        self._editableText = State(initialValue: mainText.wrappedValue)
    }
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
            LargeTextField(text: $editableText)
                .environment(\.isEditable, isEditable)
                .padding(.bottom)
        
        }
        .onChange(of: editableText) { 
            mainText = editableText
        }
        .onChange(of: mainText) {
            editableText = mainText
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
