//
//  RevalFillIn.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//
import SwiftUI

struct ReEvalFillInInput: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var totalTreatments: Int = 0
    @State private var fromDate: Date = .now
    @State private var toDate: Date = .now
    @State private var missedTreatments: Int = 0

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private let totalTreatmentsRegex = try! NSRegularExpression(pattern: "(\\d+) total treatments")
    private let dateRangeRegex = try! NSRegularExpression(pattern: "from (\\d{4}-\\d{2}-\\d{2}) to (\\d{4}-\\d{2}-\\d{2})")
    private let missedTreatmentsRegex = try! NSRegularExpression(pattern: "Treatments missed: (\\d+)")

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total treatments:")
                TextField("Enter total treatments", value: $totalTreatments, formatter: NumberFormatter())
                    .disabled(!isEditable)
            }
            HStack {
                Text("from:")
                DatePicker("", selection: $fromDate)
                    .disabled(!isEditable)
            }
            HStack {
                Text("to:")
                DatePicker("", selection: $toDate)
            }
            HStack {
                Text("Treatments missed:")
                TextField("Enter missed treatments", value: $missedTreatments, formatter: NumberFormatter())
                    .disabled(!isEditable)
            }
        }
        .onChange(of: totalTreatments) { newValue in
            updateCombinedString()
        }
        .onChange(of: fromDate) { _ in
            updateCombinedString()
        }
        .onChange(of: toDate) { _ in
            updateCombinedString()
        }
        .onChange(of: missedTreatments) { newValue in
            updateCombinedString()
        }
        .onAppear {
            extractComponents()
        }
    }

    func updateCombinedString() {
        combinedString = "\(totalTreatments) total treatments from \(dateFormatter.string(from: fromDate)) to \(dateFormatter.string(from: toDate)); Treatments missed: \(missedTreatments)"
        print(combinedString)
    }

    func extractComponents() {
        if let totalTreatmentsMatch = totalTreatmentsRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            totalTreatments = Int(String(combinedString[Range(totalTreatmentsMatch.range(at: 1), in: combinedString)!])) ?? 0
        }

        if let dateRangeMatch = dateRangeRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            let fromDateString = String(combinedString[Range(dateRangeMatch.range(at: 1), in: combinedString)!])
            let toDateString = String(combinedString[Range(dateRangeMatch.range(at: 2), in: combinedString)!])

            if let fromDate = dateFormatter.date(from: fromDateString) {
                self.fromDate = fromDate
            }
            if let toDate = dateFormatter.date(from: toDateString) {
                self.toDate = toDate
            }
        }

        if let missedTreatmentsMatch = missedTreatmentsRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            missedTreatments = Int(String(combinedString[Range(missedTreatmentsMatch.range(at: 1), in: combinedString)!])) ?? 0
        }
    }
}
