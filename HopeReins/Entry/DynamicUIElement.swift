//
//  DynamicUIElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct DynamicElementView: View {
    @State var wrappedElement: DynamicUIElement
    @State var change: PastChange?
    var body: some View {
        VStack(alignment: .leading) {
            switch wrappedElement {
            case .textField(let title, let binding):
                BasicTextField(title: title, text: bindingForChange(type: String.self, originalBinding: binding))
            case .datePicker(let title, let hourAndMinute, let binding):
                DateSelection(title: title, hourAndMinute: hourAndMinute, date: bindingForChange(type: Date.self, originalBinding: binding))
            case .numberField(let title, let binding):
                TextField(title, value: bindingForChange(type: Int.self, originalBinding: binding), formatter: NumberFormatter())
            case .sectionHeader(let title):
                SectionHeader(title: title)
            case .singleSelectDescription(title: let title, titles: let titles, labels: let labels, combinedString: let combinedString):
                SingleSelectLastDescription(combinedString: bindingForChange(type: String.self, originalBinding: combinedString), titles: titles, labels: labels)
            case .multiSelectWithTitle(combinedString: let combinedString, labels: let labels, title: let title):
                MultiSelectWithTitle(boolString: bindingForChange(type: String.self, originalBinding: combinedString), labels: labels, title: title)
            case .multiSelectOthers(combinedString: let combinedString, labels: let labels, title: let title):
                MultiSelectOthers(boolString: bindingForChange(type: String.self, originalBinding: combinedString), labels: labels, title: title)
            case .strengthTable(title: let title, combinedString: let combinedString):
                if change != nil {
                    OriginalValueView(id: change!.fieldID, value: change!.propertyChange, displayName: change!.displayName)
                } else {
                    StrengthTable(combinedString: combinedString, customLabels: title.contains("LE") ?  defaultLEROMLables : defaultUELabels)
                }
            case .dailyNoteTable(let title, let combinedString):
                if change != nil {
                    OriginalValueView(id: change!.fieldID, value: change!.propertyChange, displayName: change!.displayName)
                } else {
                    DailyNoteTable(combinedString: combinedString)
                }
            case .fileUploadButton(title: let title, dataValue: let dataValue):
                PropertyHeader(title: title)
                FileUploadButton(fileData: (change != nil) ? .constant(convertToCodableValue(type: change!.type, propertyChange: change!.propertyChange).dataValue) :  dataValue)
            case .physicalTherapyFillIn(title: let title, combinedString: let combinedString):
                RecommendedPhysicalTherapyFillIn(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .reEvalFillin(title: let title, combinedString: let combinedString):
                ReEvalFillInInput(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .dailyNoteFillin(title: let title, combinedString: let combinedString):
                DailyNoteFillIn(combinedString: bindingForChange(type: String.self, originalBinding: combinedString))
            case .textEntries(title: let title, combinedString: let combinedString):
                TextEntries(combinedString: bindingForChange(type: String.self, originalBinding: combinedString), title: title)
            }
        }
        .environment(\.isEditable, (change == nil))
    }
}

enum DynamicUIElement: Hashable {
    case textField(title: String, binding: Binding<String>)
    case datePicker(title: String, hourAndMinute: Bool, binding: Binding<Date>)
    case numberField(title: String, binding: Binding<Int>)
    case sectionHeader(title: String)
    case strengthTable(title: String, combinedString: Binding<String>)
    case singleSelectDescription(title: String, titles: [String], labels: [String], combinedString: Binding<String>)
    case multiSelectWithTitle(combinedString: Binding<String>, labels: [String], title: String)
    case multiSelectOthers(combinedString: Binding<String>, labels: [String], title: String)
    case dailyNoteTable(title: String, combinedString: Binding<String>)
    case fileUploadButton(title: String, dataValue: Binding<Data?>)
    case physicalTherapyFillIn(title: String, combinedString: Binding<String>)
    case reEvalFillin(title: String, combinedString: Binding<String>)
    case dailyNoteFillin(title: String, combinedString: Binding<String>)
    case textEntries(title: String, combinedString: Binding<String>)
    
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
                .physicalTherapyFillIn(let title, _),
                .reEvalFillin(let title, _),
                .dailyNoteFillin(let title, _),
                .textEntries(title: let title, _):
            hasher.combine(title)
        case .singleSelectDescription(_,let titles, let labels, _):
            hasher.combine(titles)
            hasher.combine(labels)
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
             .singleSelectDescription(let title,_, _, _),
             .fileUploadButton(let title, _),
             .physicalTherapyFillIn(let title, _),
             .reEvalFillin(let title, _),
             .dailyNoteFillin(let title, _),
             .textEntries(let title, _):
            self.id = title
        }
        self.element = element
    }
}

extension DynamicElementView {
    func bindingForChange<T>(type: T.Type, originalBinding: Binding<T>) -> Binding<T> {
        guard let change = change else {
            return originalBinding
        }

        let convertedValue = convertToCodableValue(type: change.type, propertyChange: change.propertyChange)

        switch T.self {
        case is String.Type:
            return .constant(convertedValue.stringValue as! T)
        case is Date.Type:
            return .constant(convertedValue.dateValue as! T)
        case is Int.Type:
            return .constant(convertedValue.intValue as! T)
        default:
            return originalBinding
        }
    }
}
