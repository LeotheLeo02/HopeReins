//
//  PhyisicalTherabyFillIn.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//
import SwiftUI


struct RecommendedPhysicalTherapyFillIn: View {
    @Environment(\.isEditable) var isEditable: Bool
    @Binding var combinedString: String
    @State private var frequency: String = ""
    @State private var duration: String = ""
    
    init(combinedString: Binding<String>) {
        self._combinedString = combinedString
        extractComponents()
    }
    
    private let frequencyRegex = try! NSRegularExpression(pattern: "(\\w+) /wk")
    private let durationRegex = try! NSRegularExpression(pattern: " x (\\w+)")
    
    var body: some View {
        VStack(alignment: .leading) {
            PropertyHeader(title: "Recommended Physical Therapy")
            
            HStack {
                DynamicTextField(text: $frequency, label: "Frequency")
                Text("/wk x")
                DynamicTextField(text: $duration, label: "Duration")
            }
        }
        .onChange(of: frequency) { newValue in
            updateCombinedString()
        }
        .onChange(of: duration) { _ in
            updateCombinedString()
        }
    }
    
    func updateCombinedString() {
        if frequency.isEmpty && duration.isEmpty {
            combinedString = ""
        } else {
            combinedString = "\(frequency) /wk x \(duration)"
        }
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


struct DynamicTextField: View {
    @Environment(\.isEditable) var isEditable
    @Binding var text: String
    var label: String
    var body: some View {
        if isEditable {
            Text(text)
        } else {
            TextField(label, text: $text)
        }
    }
}
