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
        combinedString = titles.map { title -> String in
            if let selection = selections[title] {
                var titleString = "\(title)::\(selection)"
                if selection == labels.last, let description = descriptions[title], !description.isEmpty {
                    titleString += "~~\(description)"
                }
                return titleString
            }
            return ""
        }.joined(separator: ", ")
        print(combinedString)
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
