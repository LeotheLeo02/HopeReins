//
//  MultiSelectWithTitle.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI
import Combine

// TODO: Debug AttributeGraph Cycle issue...
struct MultiSelectWithTitle: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var boolString: String
    @State private var toggleElements: [ToggleWithTitle] = []
    var labels: [String]
    var title: String

    private var updateStringPublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(boolString: Binding<String>, labels: [String], title: String) {
        self._boolString = boolString
        self.labels = labels
        self.title = title
        self._toggleElements = State(initialValue: getToggleWithTitles())

        // Debounce updates to reduce frequency
        updateStringPublisher
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [self] in
                self.updateString()
            }
            .store(in: &cancellables)
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 300)),
    ]
    
    var body: some View {
        PropertyHeader(title: title)
        LazyVGrid(columns: columns, content: {
                ForEach(toggleElements.indices, id: \.self) { index in
                    DescriptionView(boolString: $boolString, toggleElement: $toggleElements[index], index: index, coordinator: Coordinator(self))
                        .environment(\.isEditable, isEditable)
                }
        })
        .onReceive(updateStringPublisher) { _ in
            self.updateString()
        }
        
        .onChange(of: toggleElements, { oldValue, newValue in
            self.updateString()
        })

        .padding()
    }
    

    
    func updateString() {
        DispatchQueue.main.async {
            let nonDefaultElements = toggleElements.filter { !$0.description.isEmpty }
            
            if nonDefaultElements.isEmpty {
                // If all elements are at their default (i.e., descriptions are empty), set boolString to empty
                boolString = ""
            } else {
                // Construct the boolString only with elements that are not at their default state
                boolString = nonDefaultElements.map { "\($0.title): \($0.description)" }.joined(separator: "\\")
                print(boolString)
            }
        }
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
    @FocusState var textIsFocused: Bool
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
                .disabled(!isEditable)
        }
    }

    func isTrueToggle() -> Bool {
        return !toggleElement.description.isEmpty
    }
}
