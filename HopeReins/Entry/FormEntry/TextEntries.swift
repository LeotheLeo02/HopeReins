//
//  TextEntries.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 3/12/24.
//

import SwiftUI

struct Entry: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var value: String
}

import SwiftUI

struct TextEntries: View {
    @Environment(\.isEditable) var isEditable
    @State private var entries: [Entry] = []
    @Binding var combinedString: String
    var title: String
    
    init(combinedString: Binding<String>, title: String) {
        self._combinedString = combinedString
        self.title = title
        self.entries = self.decodeString(combinedString.wrappedValue)
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .padding(.top)
                Spacer()
                if isEditable {
                    plusMinusButtons()
                }
            }
            .foregroundStyle(.gray)
            Divider()
            if entries.isEmpty {
                Text("No \(title)")
                    .foregroundStyle(.gray)
                    .bold()
            } else {
                ForEach(entries.indices, id: \.self) { index in
                    HStack {
                        TextEntry(entry: $entries[index]) {
                            updateCombinedString()
                        }
                    }
                }
            }
        }
        .onChange(of: combinedString) { newValue in
            self.entries = self.decodeString(newValue)
        }
    }
    
    func addEntry() {
        let newIndex = entries.count + 1
        let newEntry = Entry(title: "Goal \(newIndex)", value: "")
        entries.append(newEntry)
        updateCombinedString()
    }
    
    func deleteEntry() {
        entries.removeLast()
        updateCombinedString()
    }
    
    func updateCombinedString() {
        let validEntries = entries.filter { !$0.value.isEmpty }
        combinedString = validEntries.map { "\($0.title):\($0.value)" }.joined(separator: "|")
    }
    
    func decodeString(_ string: String) -> [Entry] {
        if string.isEmpty {
            return []
        } else {
            return string.components(separatedBy: "|").map {
                let parts = $0.components(separatedBy: ":")
                return Entry(title: parts[0], value: parts.count > 1 ? parts[1] : "")
            }
        }
    }
    
    @ViewBuilder
    private func plusMinusButtons() -> some View {
        Button(action: {
            addEntry()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.gray)
        })
        .buttonStyle(.borderless)
        Button(action: {
            deleteEntry()
        }, label: {
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.gray)
        })
        .buttonStyle(.borderless)
        .disabled(entries.isEmpty)
    }
}

struct TextEntry: View {
    @Environment(\.isEditable) var isEditable
    @FocusState var isFocused: Bool
    @Binding var entry: Entry
    var updateParentCombinedString: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            PropertyHeader(title: entry.title)
            if !isEditable {
                Text(entry.value)
                    .foregroundStyle(.gray)
            } else {
                TextField("", text: $entry.value, axis: .vertical)
                    .padding(.bottom)
                    .labelsHidden()
                    .focused($isFocused)
            }
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: entry.value) { _ in
            updateParentCombinedString()
        }
    }
}
