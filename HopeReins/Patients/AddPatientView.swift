//
//  AddPatientView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/10/23.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var name: String = ""
    @State var dateOfBirth: Date = .now
    var body: some View {
        ScrollView {
            VStack {
                TextField("Name...", text: $name)
                DatePicker("Date of Birth", selection: $dateOfBirth)
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Button(action: {
                        let newPatient = Patient(name: name, dateOfBirth: dateOfBirth)
                        modelContext.insert(newPatient)
                        dismiss()
                    }, label: {
                        Text("Add")
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
