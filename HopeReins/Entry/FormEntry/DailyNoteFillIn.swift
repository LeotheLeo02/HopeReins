//
//  DailyNoteFillIn.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI

struct DailyNoteFillIn: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var extractedOnDate: Date = .now
    @State private var extractedFromDate: Date = .now
    @State private var extractedToDate: Date = .now

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        return formatter
    }()

    private let onDateRegex = try! NSRegularExpression(pattern: "On (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")

    private let dateRangeRegex = try! NSRegularExpression(pattern: "from (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2}) to (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")
    
    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        
        let components = self.extractComponents(from: combinedString.wrappedValue, dateFormatter: dateFormatter)
        self._extractedOnDate = State(initialValue: components.onDate)
        self._extractedFromDate = State(initialValue: components.fromDate)
        self._extractedToDate = State(initialValue: components.toDate)
    }

    var body: some View {
        HStack {
            HStack {
                Text("On")
                DatePicker("", selection: $extractedOnDate, displayedComponents: .date)
                    .disabled(!isEditable)
            }
            HStack {
                Text("from:")
                DatePicker("", selection: $extractedFromDate, displayedComponents: .hourAndMinute)
                    .disabled(!isEditable)
            }
            HStack {
                Text("to:")
                DatePicker("", selection: $extractedToDate, displayedComponents: .hourAndMinute)
                    .disabled(!isEditable)
            }
        }
        .padding()
        .onChange(of: extractedOnDate) { newValue in
            updateCombinedString()
        }
        .onChange(of: extractedFromDate) { _ in
            updateCombinedString()
        }
        .onChange(of: extractedToDate) { _ in
            updateCombinedString()
        }
    }

    func updateCombinedString() {
        combinedString = "on \(dateFormatter.string(from: extractedOnDate)) from \(dateFormatter.string(from: extractedFromDate)) to \(dateFormatter.string(from: extractedToDate))"
    }
    
    func extractComponents(from string: String, dateFormatter: DateFormatter) -> (onDate: Date, fromDate: Date, toDate: Date) {
        let onDateRegex = try! NSRegularExpression(pattern: "On (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")
        let dateRangeRegex = try! NSRegularExpression(pattern: "from (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2}) to (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")
        
        var onDate = Date()
        var fromDate = Date()
        var toDate = Date()
        
        if let onDateMatch = onDateRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            let onDateString = String(string[Range(onDateMatch.range(at: 1), in: string)!])
            onDate = dateFormatter.date(from: onDateString) ?? Date()
        }
        
        if let dateRangeMatch = dateRangeRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            let fromDateString = String(string[Range(dateRangeMatch.range(at: 1), in: string)!])
            let toDateString = String(string[Range(dateRangeMatch.range(at: 2), in: string)!])
            fromDate = dateFormatter.date(from: fromDateString) ?? Date()
            toDate = dateFormatter.date(from: toDateString) ?? Date()
        }
        
        return (onDate, fromDate, toDate)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyNoteFillIn(combinedString: .constant("on 2023-12-11 2:30 PM from 2023-12-11 2:30 PM to 2023-12-11 5:30 PM"))
    }
}

struct DynamicDatePicker: View {
    @Environment(\.isEditable) var isEditable
    @State var showHourAndMinute: Bool
    @Binding var date: Date
    var body: some View {
        if !isEditable {
            Text(date.description)
        } else {
            if showHourAndMinute {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
            } else {
                DatePicker("", selection: $date)
            }
        }
    }
}

