//
//  SingleSelectLastDescription.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/24/23.
//

import SwiftUI

struct SingleSelectLastDescription: View {
    @Binding var combinedString: String
    @State var otherString: String = ""
    @State var boolString: String = ""
    var lastDescription: Bool
    var title: String
    var labels: [String]
    init(combinedString: Binding<String>, lastDescription: Bool, title: String, labels: [String]) {
        self._combinedString = combinedString
        self.lastDescription = lastDescription
        self.title = title
        self.labels = labels
    }
    var body: some View {
        Picker(selection: $boolString) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .tag(labels[index])
            }
        } label: {
            Text(title)
        }
        .onChange(of: boolString) { oldValue, newValue in
            if oldValue == labels.last! {
                otherString = ""
            }
            combinedString = boolString
        }
        .onAppear {
            getStrings()
        }
        if labels.last! == boolString && lastDescription {
            TextField("Description...", text: $otherString)
                .onChange(of: otherString) { oldValue, newValue in
                    if !otherString.isEmpty {
                        combinedString = "*\(boolString):\(otherString)*"
                    } else {
                        combinedString = ""
                    }
                }
        }
    }
    func getStrings() {
        let components = combinedString.components(separatedBy: ":")
        print(components)
        if components.count == 2 {
            let title = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let description = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            boolString = title
            otherString = description
        } else {
            print("Warning: Element '\(combinedString)' does not have the expected format (title:description).")
        }
    }

}


struct DateSelection: View {
    var title: String
    var hourAndMinute: Bool
    @Binding var date: Date
    var body: some View {
        VStack(alignment: .leading) {
            CustomSectionHeader(title: title)
            if hourAndMinute {
                DatePicker("", selection: $date)
            } else {
                DatePicker("", selection: $date, displayedComponents: .date)
            }
        }
        .padding()
    }
}

#Preview {
    FakeView()
}
