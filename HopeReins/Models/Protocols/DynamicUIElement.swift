//
//  DynamicUIElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct DynamicElementView: View {
    let wrappedElement: DynamicUIElement
    var body: some View {
        switch wrappedElement {
        case .textField(let title, let binding):
            BasicTextField(title: title, text: binding)
        case .datePicker(let title, let hourAndMinute, let binding):
            DateSelection(title: title, hourAndMinute: hourAndMinute, date: binding)
        case .numberField(let title, let binding):
            TextField(title, value: binding, formatter: NumberFormatter())
        case .sectionHeader(let title):
            CustomSectionHeader(title: title)
        case .customView(title: let title, viewProvider: let viewProvider):
            viewProvider()
        case .singleSelectDescription(titles: let titles, labels: let labels, combinedString: let combinedString, isDescription: let isDescription):
            SingleSelectLastDescription(combinedString: combinedString, lastDescription: isDescription, titles: titles, labels: labels)
        }
    }
}

enum DynamicUIElement: Hashable {
    case textField(title: String, binding: Binding<String>)
    case datePicker(title: String, hourAndMinute: Bool, binding: Binding<Date>)
    case numberField(title: String, binding: Binding<Int>)
    case sectionHeader(title: String)
    case singleSelectDescription(titles: [String], labels: [String], combinedString: Binding<String>, isDescription: Bool)
    case customView(title: String, viewProvider: () -> AnyView)
    
    static func == (lhs: DynamicUIElement, rhs: DynamicUIElement) -> Bool {
           switch (lhs, rhs) {
           case let (.textField(title1, _), .textField(title2, _)),
                let (.numberField(title1, _), .numberField(title2, _)):
               return title1 == title2
           case (.sectionHeader(let title1), .sectionHeader(let title2)):
               return title1 == title2
           default:
               return false
           }
    }
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .textField(let title, _),
                .numberField(let title, _),
                .sectionHeader(let title):
            hasher.combine(title)
        case .singleSelectDescription(let titles, let labels, _, let isDescription):
            hasher.combine(titles)
            hasher.combine(labels)
            hasher.combine(isDescription)
        case .customView(let title, _):
            hasher.combine(title)
        case .datePicker(title: let title, _, _):
            hasher.combine(title)
        }
    }
}



struct DynamicUIElementWrapper: Hashable {
    let id: String
    let element: DynamicUIElement

    init(element: DynamicUIElement) {
        switch element {
        case .textField(let title, _),
             .numberField(let title, _),
             .sectionHeader(let title),
             .customView(let title, _),
             .datePicker(let title, _, _):
            self.id = title
        case .singleSelectDescription(let titles, _, _, _):
            self.id = titles.joined(separator: "-")
        }
        self.element = element
    }
}
