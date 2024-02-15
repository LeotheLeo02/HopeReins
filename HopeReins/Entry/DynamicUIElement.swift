//
//  DynamicUIElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct DynamicElementView: View {
    @State var wrappedElement: DynamicUIElement
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
        case .singleSelectDescription(title: let title, titles: let titles, labels: let labels, combinedString: let combinedString, isDescription: let isDescription):
            SingleSelectLastDescription(combinedString: combinedString, lastDescription: isDescription, titles: titles, labels: labels)
        case .multiSelectWithTitle(combinedString: let combinedString, labels: let labels, title: let title):
            MultiSelectWithTitle(boolString: combinedString, labels: labels, title: title)
        case .multiSelectOthers(combinedString: let combinedString, labels: let labels, title: let title):
            MultiSelectOthers(boolString: combinedString, labels: labels, title: title)
        case .strengthTable(title: let title, combinedString: let combinedString):
            StrengthTable(combinedString: combinedString, customLabels: title.contains("LE") ?  defaultLEROMLables : defaultUELabels)
        case .dailyNoteTable(let title, let combinedString):
            DailyNoteTable(combinedString: combinedString)
        case .fileUploadButton(title: let title, dataValue: let dataValue):
            PropertyHeader(title: title)
            FileUploadButton(fileData: dataValue)
        case .physicalTherabyFillIn(title: let title, combinedString: let combinedString):
            RecommendedPhysicalTherabyFillIn(combinedString: combinedString)
        }
    }
}

enum DynamicUIElement: Hashable {
    case textField(title: String, binding: Binding<String>)
    case datePicker(title: String, hourAndMinute: Bool, binding: Binding<Date>)
    case numberField(title: String, binding: Binding<Int>)
    case sectionHeader(title: String)
    case strengthTable(title: String, combinedString: Binding<String>)
    case singleSelectDescription(title: String, titles: [String], labels: [String], combinedString: Binding<String>, isDescription: Bool)
    case multiSelectWithTitle(combinedString: Binding<String>, labels: [String], title: String)
    case multiSelectOthers(combinedString: Binding<String>, labels: [String], title: String)
    case dailyNoteTable(title: String, combinedString: Binding<String>)
    case fileUploadButton(title: String, dataValue: Binding<Data?>)
    case physicalTherabyFillIn(title: String, combinedString: Binding<String>)
    
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
                .strengthTable(let title, _),
                .dailyNoteTable(let title, _),
                .fileUploadButton(let title, _),
                .physicalTherabyFillIn(let title, _):
            hasher.combine(title)
        case .singleSelectDescription(_,let titles, let labels, _, let isDescription):
            hasher.combine(titles)
            hasher.combine(labels)
            hasher.combine(isDescription)
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
             .datePicker(let title, _, _),
             .multiSelectWithTitle(_, _, let title),
             .multiSelectOthers(_, _, let title),
             .strengthTable(let title, _),
             .dailyNoteTable(let title, _),
             .singleSelectDescription(let title,_, _, _, _),
             .fileUploadButton(let title, _),
             .physicalTherabyFillIn(let title, _):
            self.id = title
        }
        self.element = element
    }
}
