//
//  InstructorsMenu.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI
import SwiftData


struct InstructorsMenu: View {
    @Binding var instructorName: String
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var body: some View {
        PropertyHeader(title: "Instructor")
        Picker(selection: $instructorName) {
            ForEach(instructors) { user in
                Text(user.username)
                    .tag(user.username)
            }
        } label: {
            Text("Instructor: \(instructorName)")
        }
        .labelsHidden()
    }
}
