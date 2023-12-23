//
//  EditableToggles.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/22/23.
//

import SwiftUI

struct MultiSelectOther: View {
    @State var otherString: String = ""
    @Binding var boolString: String
    var labels: [String]
    var title: String
    var body: some View {
        HStack {
            Text(title)
                .bold()
            ForEach(labels, id: \.self) { label in
                HStack {
                    Button(action: {
                        toggle(input: label)
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(isTrueToggle(input: label) ? .blue : .gray)
                                .opacity(isTrueToggle(input: label)  ? 1.0 : 0.5)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    if isTrueToggle(input: label)  {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                    })
                    .buttonStyle(.plain)
                    Text(label)
                }
                .padding()
            }
            HStack {
                TextField("Other...", text: $otherString)
                Spacer()
                Button(action: {
                    boolString.append("*\(otherString)*")
                    otherString = ""
                }, label: {
                    Image(systemName: "plus")
                })
            }
            ForEach(getOtherElements(), id: \.self) { otherObject in
                HStack {
                    Button(action: {
                        boolString = boolString.replacingOccurrences(of: otherObject, with: "")
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.blue)
                                .opacity(1.0)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                }
                        }
                    })
                    .buttonStyle(.plain)
                    Text(otherObject)
                }
            }
        }
    }
    func getOtherElements() -> [String] {
        let regex = try! NSRegularExpression(pattern: "\\*([^*]+)\\*", options: [])
        let matches = regex.matches(in: boolString, options: [], range: NSRange(boolString.startIndex..., in: boolString))

        var elements = [String]()
        for match in matches {
            let range = Range(match.range, in: boolString)!
            let element = String(boolString[range])

            let trimmedElement = element.dropFirst().dropLast()
            elements.append(String(trimmedElement))
        }
        return elements
    }
    func isTrueToggle(input: String) -> Bool {
        return boolString.contains(input)
    }
    func toggle(input: String) {
        if isTrueToggle(input: input) {
            boolString = boolString.replacingOccurrences(of: input, with: "")
        } else {
            boolString.append(input)
        }
    }
}


struct FakeView: View {
    @State var boolString: String = "Lebron James:\\Bob Parker: He was amazing"
    var body: some View {
        VStack {
            MultiSelectWithTitle(boolString: $boolString, labels: ["Lebron James", "Bob Parker"], title: "Current Equipment")
        }
        .padding()
    }
}

#Preview {
    FakeView()
}


import SwiftUI

struct MultiSelectWithTitle: View {
    @Binding var boolString: String
    @State private var toggleElements: [ToggleWithTitle] = []
    var labels: [String]
    var title: String

    init(boolString: Binding<String>, labels: [String], title: String) {
        self._boolString = boolString
        self.labels = labels
        self.title = title
        self._toggleElements = State(initialValue: getToggleWithTitles())
    }

    var body: some View {
        VStack(alignment: .leading) {
            CustomSectionHeader(title: title)
            ForEach(toggleElements.indices, id: \.self) { index in
                DescriptionView(boolString: $boolString, toggleElement: $toggleElements[index], index: index, coordinator: Coordinator(self))
            }
        }
        .onChange(of: toggleElements) { _ in
            updateString()
        }
        .padding()
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
        return separatedElements
    }
    
    func updateString() {
        boolString = toggleElements.map { "\($0.title): \($0.description)" }.joined(separator: "\\")
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
            TextField("Description", text: $toggleElement.description)
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

