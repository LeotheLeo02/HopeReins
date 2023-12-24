//
//  MultiSelectOthers.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

#Preview {
    FakeView()
}

struct MultiSelectOthers: View {
    @State var otherString: String = ""
    @Binding var boolString: String
    var labels: [String]
    var title: String
    let columns = [
        GridItem(.adaptive(minimum: 200)),
        GridItem(.adaptive(minimum: 200)),
         GridItem(.adaptive(minimum: 200)),
         GridItem(.adaptive(minimum: 200)),
    ]
    var body: some View {
        ScrollView {
            Text(title)
                .bold()
            LazyVGrid(columns: columns, content: {
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
                HStack {
                    TextField("Other...", text: $otherString, axis: .vertical)
                    Spacer()
                    Button(action: {
                        boolString.append("*\(otherString)*")
                        otherString = ""
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            })
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
