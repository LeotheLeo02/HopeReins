//
//  MultiSelectOthers.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct MultiSelectOthers: View {
    @Environment(\.isEditable) var isEditable: Bool
    @State var otherString: String = ""
    @Binding var boolString: String
    var labels: [String]
    var title: String
    let columns = [
        GridItem(.adaptive(minimum: 200)),
        GridItem(.adaptive(minimum: 200)),
        GridItem(.adaptive(minimum: 200))
    ]
    var body: some View {
        ScrollView {
            Text(title)
                .bold()
            LazyVGrid(columns: columns, content: {
                ForEach(labels, id: \.self) { label in
                    VStack(alignment: .leading) {
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
                            .disabled(!isEditable)
                            Text(label)
                                .frame(maxWidth: 200, alignment: .leading)
                        }
                    }
                }
                ForEach(getOtherElements(), id: \.self) { otherObject in
                    HStack {
                        Button(action: {
                            self.removeOtherString(otherObject)
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
                        .disabled(!isEditable)
                        Text(otherObject)
                    }
                }
                HStack {
                    TextField("Other...", text: $otherString, axis: .vertical)
                        .disabled(!isEditable)
                    Spacer()
                    Button(action: {
                        addOtherString()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .disabled(!isEditable)
                }
            })
        }
        .onChange(of: boolString) { oldValue, newValue in
            checkAndUpdateBoolString()
        }
    }
    
    private func checkAndUpdateBoolString() {
        let items = boolString.components(separatedBy: "|")
        let nonDefaultItems = items.filter { !$0.hasSuffix(":false") && !$0.hasPrefix("other:") && !$0.isEmpty }
        
       
        if nonDefaultItems.isEmpty && !boolString.contains("other:") {
            boolString = ""
        }
    }
    
    func addOtherString() {
        if !otherString.isEmpty {
            boolString += "|other:\(otherString)"
            otherString = "" // Clear the TextField
        }
    }

    func removeOtherString(_ other: String) {
        var items = boolString.components(separatedBy: "|")
        items.removeAll { $0 == "other:\(other)" }
        boolString = items.joined(separator: "|")
    }

    func getOtherElements() -> [String] {
        return boolString.components(separatedBy: "|")
            .filter { $0.starts(with: "other:") }
            .map { $0.replacingOccurrences(of: "other:", with: "") }
    }
    func isTrueToggle(input: String) -> Bool {
        // Check if the input is a standard label and is set to true
        if boolString.contains("\(input):true") {
            return true
        }
        
        if boolString.contains("other:\(input)") {
            return true
        }
        
        return false
    }

    func toggle(input: String) {
        var items = boolString.components(separatedBy: "|")
        if let index = items.firstIndex(where: { $0.starts(with: input) }) {
            let currentState = items[index].contains("true")
            items[index] = "\(input):\(currentState ? "false" : "true")"
        } else {
            items.append("\(input):true")
        }
        boolString = items.joined(separator: "|")
    }

}
