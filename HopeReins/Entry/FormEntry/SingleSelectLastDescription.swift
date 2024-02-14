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
    

    var lastDescription: Bool
    var titles: [String]
    var labels: [String]
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                VStack(alignment: .leading) {
                    PropertyHeader(title: title)
                    Picker(title, selection: Binding(
                        get: { self.selections[title] ?? self.labels.first! },
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

                    
                    if lastDescription && selections[title] == labels.last {
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
        .onAppear {
            self.parseCombinedString()
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

            if selection == labels.last, let description = descriptions[title], !description.isEmpty {
                component += "~~\(description)"
            } else if selection == "Not Indicated" {
                // Skip adding "Not Indicated" to combinedString if it's not meant to be explicitly saved
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
            selections[title] = "Not Indicated" // Default to "Not Indicated"
        }

        for component in titleComponents {
            let titleAndRest = component.split(separator: "::", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
            if titleAndRest.count == 2, let title = titles.first(where: { titleAndRest[0].contains($0) }) {
                let selectionAndDescription = titleAndRest[1].split(separator: "~~", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let selection = selectionAndDescription[0]
                
                // Only update the selection if it's a valid label
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
