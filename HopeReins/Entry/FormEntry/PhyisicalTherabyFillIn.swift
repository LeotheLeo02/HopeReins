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
        
        let components = self.extractComponents(from: combinedString.wrappedValue)
        self._frequency = State(initialValue: components.frequency)
        self._duration = State(initialValue: components.duration)
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
    
    func extractComponents(from string: String) -> (frequency: String, duration: String) {
        let frequencyRegex = try! NSRegularExpression(pattern: "(\\w+) /wk")
        let durationRegex = try! NSRegularExpression(pattern: " x (\\w+)")
        
        var frequency = ""
        var duration = ""
        
        if let frequencyMatch = frequencyRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            frequency = String(string[Range(frequencyMatch.range(at: 1), in: string)!])
        }
        
        if let durationMatch = durationRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            duration = String(string[Range(durationMatch.range(at: 1), in: string)!])
        }
        
        return (frequency, duration)
    }
}


struct DynamicTextField: View {
    @Environment(\.isEditable) var isEditable
    @Binding var text: String
    var label: String
    var body: some View {
        if !isEditable {
            Text(text)
        } else {
            TextField(label, text: $text)
        }
    }
}
