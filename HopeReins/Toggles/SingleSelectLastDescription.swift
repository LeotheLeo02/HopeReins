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
    }
    
    private func updateCombinedString() {
        var isAllDefault = true
        
        // Construct combinedString from the current selections and descriptions
        let combinedComponents = titles.compactMap { title -> String? in
            guard let selection = selections[title] else { return nil }

            // Check if the current selection is the default value
            let isDefaultSelection = selection == labels.first

            var component: String? = nil
            if !isDefaultSelection || (selection == labels.last && descriptions[title]?.isEmpty == false) {
                // Construct component only if it's not default
                component = "\(title)::\(selection)"
                if selection == labels.last, let description = descriptions[title], !description.isEmpty {
                    component! += "~~\(description)"
                }
                isAllDefault = false  // Found at least one non-default value
            }

            return component
        }

        if isAllDefault {
            combinedString = ""
        } else {
            combinedString = combinedComponents.joined(separator: ", ")
        }

        print("Combined String: \(combinedString)")
    }



    private func parseCombinedString() {
        let titleComponents = combinedString.components(separatedBy: ", ")
        selections.removeAll()
        descriptions.removeAll()

        for component in titleComponents {
            let titleAndRest = component.split(separator: "::", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
            if titleAndRest.count == 2, let title = titles.first(where: { titleAndRest[0].contains($0) }) {
                let selectionAndDescription = titleAndRest[1].split(separator: "~~", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let selection = selectionAndDescription[0]
                selections[title] = selection
                
                if selectionAndDescription.count > 1 {
                    let description = selectionAndDescription[1]
                    descriptions[title] = description
                }
            }
        }
    }

}
