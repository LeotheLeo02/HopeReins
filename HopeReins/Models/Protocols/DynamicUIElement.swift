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
            SectionHeader(title: title)
        case .customView(title: let title, viewProvider: let viewProvider):
            PropertyHeader(title: title)
            viewProvider()
        case .singleSelectDescription(title: let title, titles: let titles, labels: let labels, combinedString: let combinedString, isDescription: let isDescription):
            SingleSelectLastDescription(combinedString: combinedString, lastDescription: isDescription, titles: titles, labels: labels)
        case .multiSelectWithTitle(combinedString: let combinedString, labels: let labels, title: let title):
            MultiSelectWithTitle(boolString: combinedString, labels: labels, title: title)
        case .multiSelectOthers(combinedString: let combinedString, labels: let labels, title: let title):
            MultiSelectOthers(boolString: combinedString, labels: labels, title: title)
        case .leRomTable(title: let title, combinedString: let combinedString):
            LeRomTable(combinedString: combinedString)
        case .dailyNoteTable(let title, let combinedString):
            DailyNoteTable(combinedString: combinedString)
        }
    }
}

enum DynamicUIElement: Hashable {
    case textField(title: String, binding: Binding<String>)
    case datePicker(title: String, hourAndMinute: Bool, binding: Binding<Date>)
    case numberField(title: String, binding: Binding<Int>)
    case sectionHeader(title: String)
    case leRomTable(title: String, combinedString: Binding<String>)
    case singleSelectDescription(title: String, titles: [String], labels: [String], combinedString: Binding<String>, isDescription: Bool)
    case multiSelectWithTitle(combinedString: Binding<String>, labels: [String], title: String)
    case multiSelectOthers(combinedString: Binding<String>, labels: [String], title: String)
    case customView(title: String, viewProvider: () -> AnyView)
    case dailyNoteTable(title: String, combinedString: Binding<String>)
    
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
                .sectionHeader(let title),
                .leRomTable(let title, _),
                .dailyNoteTable(let title, _):
            hasher.combine(title)
        case .singleSelectDescription(_,let titles, let labels, _, let isDescription):
            hasher.combine(titles)
            hasher.combine(labels)
            hasher.combine(isDescription)
        case .customView(let title, _):
            hasher.combine(title)
        case .datePicker(title: let title, _, _):
            hasher.combine(title)
        case .multiSelectWithTitle(_, let labels, let title):
            hasher.combine(labels)
            hasher.combine(title)
        case .multiSelectOthers(_, let labels, let title):
            hasher.combine(labels)
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
             .datePicker(let title, _, _),
             .multiSelectWithTitle(_, _, let title),
             .multiSelectOthers(_, _, let title),
             .leRomTable(let title, _),
             .dailyNoteTable(let title, _),
             .singleSelectDescription(let title,_, _, _, _):
            self.id = title
        }
        self.element = element
    }
}

struct SectionHeader: View {
    var title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.gray)
            Divider()
        }
        .padding(.vertical)
    }
}
