//
//  DateSelection.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/27/23.
//

import SwiftUI

struct DateSelection: View {
    @Environment(\.isEditable) var isEditable: Bool
    var title: String
    var hourAndMinute: Bool
    @Binding var date: Date

    var body: some View {
        Section {
            VStack {
                if !isEditable {
                    Text(date, formatter: dateFormatter)
                } else {
                    if hourAndMinute {
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    } else {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
            .padding(.bottom)
        } header: {
            PropertyHeader(title: title)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        if hourAndMinute {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
        return formatter
    }
}

