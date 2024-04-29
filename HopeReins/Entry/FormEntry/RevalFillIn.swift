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
    
    
    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
    
        
        let components = self.extractComponents(from: combinedString.wrappedValue, dateFormatter: dateFormatter)
        self._totalTreatments = State(initialValue: components.totalTreatments)
        self._fromDate = State(initialValue: components.fromDate)
        self._toDate = State(initialValue: components.toDate)
        self._missedTreatments = State(initialValue: components.missedTreatments)
    }
    
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
                    .disabled(!isEditable)
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
    }
    
    func updateCombinedString() {
        combinedString = "\(totalTreatments) total treatments from \(dateFormatter.string(from: fromDate)) to \(dateFormatter.string(from: toDate)); Treatments missed: \(missedTreatments)"
        print(combinedString)
    }
    
    func extractComponents(from string: String, dateFormatter: DateFormatter) -> (totalTreatments: Int, fromDate: Date, toDate: Date, missedTreatments: Int) {
        let totalTreatmentsRegex = try! NSRegularExpression(pattern: "(\\d+) total treatments")
        let dateRangeRegex = try! NSRegularExpression(pattern: "from (\\d{4}-\\d{2}-\\d{2}) to (\\d{4}-\\d{2}-\\d{2})")
        let missedTreatmentsRegex = try! NSRegularExpression(pattern: "Treatments missed: (\\d+)")
        
        var totalTreatments = 0
        var fromDate = Date()
        var toDate = Date()
        var missedTreatments = 0
        
        if let totalTreatmentsMatch = totalTreatmentsRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            totalTreatments = Int(String(string[Range(totalTreatmentsMatch.range(at: 1), in: string)!])) ?? 0
        }
        
        if let dateRangeMatch = dateRangeRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            let fromDateString = String(string[Range(dateRangeMatch.range(at: 1), in: string)!])
            let toDateString = String(string[Range(dateRangeMatch.range(at: 2), in: string)!])
            fromDate = dateFormatter.date(from: fromDateString) ?? Date()
            toDate = dateFormatter.date(from: toDateString) ?? Date()
        }
        
        if let missedTreatmentsMatch = missedTreatmentsRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            missedTreatments = Int(String(string[Range(missedTreatmentsMatch.range(at: 1), in: string)!])) ?? 0
        }
        
        return (totalTreatments, fromDate, toDate, missedTreatments)
    }
}

