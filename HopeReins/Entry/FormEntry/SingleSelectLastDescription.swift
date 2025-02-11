//
//  SingleSelectLastDescription.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct SelectionDescription: Equatable {
    let title: String
    var selection: String
    var description: String
}

struct SingleSelectLastDescription: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var selectionsDescriptions: [SelectionDescription] = []
    var titles: [String]
    var labels: [String]
    
    init(combinedString: Binding<String>, titles: [String], labels: [String]) {
        self._combinedString = combinedString
        self.titles = titles
        self.labels = labels
        _selectionsDescriptions = State(initialValue: self.parseCombinedString(combinedString.wrappedValue, titles: titles))
    }
    
    var body: some View {
        VStack {
            ForEach($selectionsDescriptions, id: \.title) { $selectionDescription in
                VStack(alignment: .leading) {
                    PropertyHeader(title: selectionDescription.title)
                    Picker(selectionDescription.title, selection: $selectionDescription.selection) {
                        ForEach(labels, id: \.self) { label in
                            Text(label).tag(label)
                        }
                        if !selectionDescription.selection.isEmpty {
                            Text("None").tag("")
                        }
                    }
                    .labelsHidden()
                    .disabled(!isEditable)
                    .onChange(of: selectionDescription.selection) { _, newValue in
                            updateCombinedString()
                    }
                    if selectionDescription.selection != "" {
                        LargeTextField(text: $selectionDescription.description)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.windowBackground)
                .shadow(radius: 3)
        )
        
        .onChange(of: combinedString) { oldValue, newValue in
                self.selectionsDescriptions = self.parseCombinedString(combinedString, titles: titles)
        }
    }
    
    func parseCombinedString(_ combinedString: String, titles: [String]) -> [SelectionDescription] {
        var result: [SelectionDescription] = []
        let components = combinedString.components(separatedBy: ", ")
        for title in titles {
            if let component = components.first(where: { $0.hasPrefix("\(title)::") }) {
                let parts = component.split(separator: "~~", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let selection = parts[0].replacingOccurrences(of: "\(title)::", with: "")
                let description = parts.count > 1 ? parts[1] : ""
                result.append(SelectionDescription(title: title, selection: selection, description: description))
            } else {
                result.append(SelectionDescription(title: title, selection: "", description: ""))
            }
        }
        
        return result
    }
    
    private func updateCombinedString() {
        let components = selectionsDescriptions.map { "\($0.title)::\($0.selection)~~\($0.description)" }
        combinedString = components.joined(separator: ", ")
    }
}


struct LargeTextField: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var text: String
    var body: some View {
        VStack {
            if !isEditable {
                Text(text)
                    .frame(maxWidth: .infinity)
            } else {
                TextEditor(text: $text)
            }
        }
        .font(.body)
        .padding(5)
        .scrollContentBackground(.hidden)
        .background(.gray.opacity(0.15))
        .clipShape(.rect(cornerRadius: 8))
        .scrollClipDisabled()
        .multilineTextAlignment(.leading)
    }
}
