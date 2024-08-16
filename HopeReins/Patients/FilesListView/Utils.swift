//
//  Utils.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 11/18/23.
//

import SwiftUI
import SwiftData

struct FilePreview: View {
    var data: Data
    var size: CGFloat
    var body: some View {
        if let image = getNSImage() {
            HStack {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .shadow(radius: 2.0, x: 0.0, y: 2.0)
            }
        } else {
            Image(systemName: "doc.text.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)
                .foregroundStyle(Color(.primary))
        }
    }
    
    func getNSImage() -> NSImage? {
        let decoder = JSONDecoder()
        guard let file = try? decoder.decode(EncodedFile.self, from: data) else {
            return nil
        }
        return NSImage(data: file.data)
    }
}

public func isUploadFile(fileType: String) -> Bool {
    
    let specificFileTypes = [
        RidingFormType.releaseStatement.rawValue,
        RidingFormType.coverLetter.rawValue,
        PhysicalTherapyFormType.referral.rawValue,
        PhysicalTherapyFormType.medicalForm.rawValue,
    ]

    return specificFileTypes.contains(fileType)
}

public func formatDate(_ date: Date) -> String {
    date.formatted(
        Date.FormatStyle()
            .month(.defaultDigits)
            .day(.defaultDigits)
            .year(.twoDigits)
    )
}


public func formatPerformedDateFromString(from combinedString: String) -> String? {
    let onDateRegex = try! NSRegularExpression(pattern: "On (\\d{4}-\\d{2}-\\d{2})")
    
    if let onDateMatch = onDateRegex.firstMatch(in: combinedString, options: [], range: NSRange(location: 0, length: combinedString.utf16.count)) {
        let onDateString = String(combinedString[Range(onDateMatch.range(at: 1), in: combinedString)!])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let onDate = dateFormatter.date(from: onDateString) {
            // Format the extracted date as a short date style
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .short
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: onDate)
        }
    }
    
    return nil
}
