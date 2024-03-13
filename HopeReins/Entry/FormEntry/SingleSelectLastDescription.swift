//
//  SingleSelectLastDescription.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct SingleSelectLastDescription: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var selections: [String: String] = [:]
    @State private var descriptions: [String: String] = [:]
    var titles: [String]
    var labels: [String]
    
    init(combinedString: Binding<String>, titles: [String], labels: [String]) {
        self._combinedString = combinedString
        self.titles = titles
        self.labels = labels
        parseCombinedString()
        
    }
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                VStack(alignment: .leading) {
                    PropertyHeader(title: title)
                    Picker(title, selection: Binding(
                        get: { self.selections[title] ?? "Not Indicated" },
                        set: { newValue in
                            self.selections[title] = newValue
                            self.updateCombinedString()
                        }
                    )) {
                        ForEach(labels, id: \.self) { label in
                            Text(label).tag(label)
                        }
                    }
                    .labelsHidden()
                    .disabled(!isEditable)
                    
                    if self.selections[title] != "Not Indicated" {
                        TextField("Description...", text: Binding(
                            get: { self.descriptions[title] ?? "" },
                            set: { newValue in
                                self.descriptions[title] = newValue
                                self.updateCombinedString()
                            }
                        ), axis: .vertical)
                        .disabled(!isEditable)
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
    }
    
    private func updateCombinedString() {
        var components: [String] = []
        for title in titles {
            guard let selection = selections[title] else { continue }
            var component = "\(title)::\(selection)"
            if let description = descriptions[title] {
                component += "~~\(description)"
            } else if selection == "Not Indicated" {
                continue
            }
            components.append(component)
        }
        combinedString = components.joined(separator: ", ")
    }
    
    private func parseCombinedString() {
        let titleComponents = combinedString.isEmpty ? [] : combinedString.components(separatedBy: ", ")
        selections.removeAll()
        descriptions.removeAll()
        titles.forEach { title in
            selections[title] = "Not Indicated"
        }
        for component in titleComponents {
            let titleAndRest = component.split(separator: "::", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
            if titleAndRest.count == 2, let title = titles.first(where: { titleAndRest[0].contains($0) }) {
                let selectionAndDescription = titleAndRest[1].split(separator: "~~", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let selection = selectionAndDescription[0]
                if labels.contains(selection) {
                    selections[title] = selection
                }
                if selectionAndDescription.count > 1 {
                    let description = selectionAndDescription[1]
                    descriptions[title] = description
                }
            }
        }
    }
}
