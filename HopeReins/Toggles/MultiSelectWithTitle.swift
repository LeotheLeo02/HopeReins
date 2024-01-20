//
//  MultiSelectWithTitle.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct MultiSelectWithTitle: View {
    @Environment(\.isEditable) var isEditable: Bool
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
                        .environment(\.isEditable, isEditable)
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

        for label in labels {
            if let element = elements.first(where: { $0.hasPrefix("\(label):") }) {
                let components = element.components(separatedBy: ":")
                let description = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                separatedElements.append(ToggleWithTitle(title: label, description: description, originalString: element))
            } else {
                separatedElements.append(ToggleWithTitle(title: label, description: "", originalString: "\(label): "))
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
    @Environment(\.isEditable) var isEditable: Bool
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
                .textFieldStyle(.roundedBorder)
                .disabled(!isEditable)
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

struct FakeView: View {
    @State var boolString: String = ""
    var body: some View {
        ScrollView {
            VStack {
                SingleSelectLastDescription(combinedString: $boolString, lastDescription: true, title: "Level", labels: ["Independent", "SBA"])
            }
        }
    }
}

#Preview {
    FakeView()
        .frame(width: 500)
}
