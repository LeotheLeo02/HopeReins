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
                    Text(date.description)
                } else {
                    if hourAndMinute {
                        DatePicker("", selection: $date)
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
}
