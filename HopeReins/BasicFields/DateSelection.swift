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
                if hourAndMinute {
                    DatePicker("", selection: $date)
                        .labelsHidden()
                        .disabled(!isEditable)
                } else {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .disabled(!isEditable)
                }
            }
            .padding(.bottom)
        } header: {
            CustomSectionHeader(title: title)
        }
    }
}
