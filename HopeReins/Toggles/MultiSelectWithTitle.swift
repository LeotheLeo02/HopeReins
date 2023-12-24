//
//  MultiSelectWithTitle.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct MultiSelectWithTitle: View {
    @Binding var boolString: String
    @State private var toggleElements: [ToggleWithTitle] = []
    var labels: [String]
    var title: String
    let columns = [
        GridItem(.adaptive(minimum: 300)),
        GridItem(.adaptive(minimum: 300)),
        GridItem(.adaptive(minimum: 300)),
        GridItem(.adaptive(minimum: 300)),
    ]
    init(boolString: Binding<String>, labels: [String], title: String) {
        self._boolString = boolString
        self.labels = labels
        self.title = title
        self._toggleElements = State(initialValue: getToggleWithTitles())
    }
    
    var body: some View {
        CustomSectionHeader(title: title)
        LazyVGrid(columns: columns, content: {
                ForEach(toggleElements.indices, id: \.self) { index in
                    DescriptionView(boolString: $boolString, toggleElement: $toggleElements[index], index: index, coordinator: Coordinator(self))
                }
        })
        .onChange(of: toggleElements) { _ in
            updateString()
        }
        .padding()
    }
    

    
    func updateString() {
        boolString = toggleElements.map { "\($0.title): \($0.description)" }.joined(separator: "\\")
    }
    func getToggleWithTitles() -> [ToggleWithTitle] {
        let elements = boolString.components(separatedBy: "\\")
        var separatedElements: [ToggleWithTitle] = []
        
        
        for element in elements {
            let components = element.components(separatedBy: ":")
            if components.count == 2 {
                let title = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let description = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                separatedElements.append(ToggleWithTitle(title: title, description: description, originalString: element))
            } else {
                print("Warning: Element '\(element)' does not have the expected format (title:description).")
            }
            
        }
        for label in labels {
            if !separatedElements.contains(where: { $0.title == label }) {
                separatedElements.append(ToggleWithTitle(title: label, description: "", originalString: label))
            }
        }
        
        return separatedElements
    }
    
    class Coordinator: NSObject {
        var parent: MultiSelectWithTitle
        
        init(_ parent: MultiSelectWithTitle) {
            self.parent = parent
        }
        
        func updateString(index: Int, newValue: String) {
            parent.toggleElements[index].description = newValue
        }
    }
}

struct ToggleWithTitle: Identifiable, Equatable{
    let id = UUID()
    var title: String
    var description: String
    var originalString: String
}



struct DescriptionView: View {
    @Binding var boolString: String
    @Binding var toggleElement: ToggleWithTitle
    var index: Int
    var coordinator: MultiSelectWithTitle.Coordinator

    var body: some View {
        HStack {
            Button(action: {
                if isTrueToggle() {
                    toggleElement.description = ""
                    coordinator.updateString(index: index, newValue: "")
                    print(boolString)
                } else {
                    toggleElement.description = "Say something..."
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(isTrueToggle() ? .blue : .gray)
                        .opacity(isTrueToggle() ? 1.0 : 0.8)
                        .frame(width: 20, height: 20)
                        .overlay {
                            if isTrueToggle() {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                }
            })
            .buttonStyle(.plain)
            Text(toggleElement.title)
            TextField("Description", text: $toggleElement.description, axis: .vertical)
                .onChange(of: toggleElement.description) { newValue in
                    coordinator.updateString(index: index, newValue: newValue)
                    print(boolString)
                }
        }
    }

    func isTrueToggle() -> Bool {
        return !toggleElement.description.isEmpty
    }
}
