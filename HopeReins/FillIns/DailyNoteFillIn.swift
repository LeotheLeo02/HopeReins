//
//  DailyNoteFillIn.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI

struct DailyNoteFillIn: View {
    @Binding var combinedString: String
    @State private var extractedOnDate: Date = .now
    @State private var extractedFromDate: Date = .now
    @State private var extractedToDate: Date = .now

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
        return formatter
    }()

    private let onDateRegex = try! NSRegularExpression(pattern: "on (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")

    private let dateRangeRegex = try! NSRegularExpression(pattern: "from (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2}) to (\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2} [APMapm]{2})")

    var body: some View {
        HStack {
            HStack {
                Text("On")
                DatePicker("", selection: $extractedOnDate, displayedComponents: .date)
            }
            HStack {
                Text("from:")
                DatePicker("", selection: $extractedFromDate, displayedComponents: .hourAndMinute)
            }
            HStack {
                Text("to:")
                DatePicker("", selection: $extractedToDate, displayedComponents: .hourAndMinute)
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
        .onAppear {
            extractComponents()
        }
    }

    func updateCombinedString() {
        combinedString = "on \(dateFormatter.string(from: extractedOnDate)) from \(dateFormatter.string(from: extractedFromDate)) to \(dateFormatter.string(from: extractedToDate))"
    }

    func extractComponents() {
        if let totalTreatmentsMatch = onDateRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            let onDateString = String(combinedString[Range(totalTreatmentsMatch.range(at: 1), in: combinedString)!])
            if let onDate = dateFormatter.date(from: onDateString) {
                extractedOnDate = onDate
            }
        }
        if let dateRangeMatch = dateRangeRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            let fromDateString = String(combinedString[Range(dateRangeMatch.range(at: 1), in: combinedString)!])
            let toDateString = String(combinedString[Range(dateRangeMatch.range(at: 2), in: combinedString)!])

            if let fromDate = dateFormatter.date(from: fromDateString) {
                extractedFromDate = fromDate
            }
            if let toDate = dateFormatter.date(from: toDateString) {
                extractedToDate = toDate
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyNoteFillIn(combinedString: .constant("on 2023-12-11 2:30 PM from 2023-12-11 2:30 PM to 2023-12-11 5:30 PM"))
    }
}
