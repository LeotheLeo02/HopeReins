//
//  RecommendedPhysicalTherabyFillIn.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/25/23.
//

import SwiftUI


struct RecommendedPhysicalTherabyFillIn: View {
    @Binding var combinedString: String
    @State private var frequency: String = ""
    @State private var duration: String = ""

    private let frequencyRegex = try! NSRegularExpression(pattern: "(\\w+) /wk")
    private let durationRegex = try! NSRegularExpression(pattern: " x (\\w+)")

    var body: some View {
        VStack(alignment: .leading) {
            CustomSectionHeader(title: "Recommended Physical Theraby")
            HStack {
                TextField("Frequency", text: $frequency)
                Text("/wk x")
                TextField("Duration", text: $duration)
            }
        }
        .onChange(of: frequency) { newValue in
            updateCombinedString()
        }
        .onChange(of: duration) { _ in
            updateCombinedString()
        }
        .onAppear {
            extractComponents()
        }
    }

    func updateCombinedString() {
        combinedString = "\(frequency) /wk x \(duration)"
        print(combinedString)
    }

    func extractComponents() {
        if let frequencyMatch = frequencyRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            frequency = String(combinedString[Range(frequencyMatch.range(at: 1), in: combinedString)!])
        }

        if let durationMatch = durationRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
            duration = String(combinedString[Range(durationMatch.range(at: 1), in: combinedString)!])
        }
    }
}
