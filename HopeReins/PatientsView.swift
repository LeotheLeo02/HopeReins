//
//  PatientsView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/8/23.
//

import SwiftUI
import SwiftData

struct PatientsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Patient.dateOfBirth, order: .forward)
    var patients: [Patient]
    var body: some View {
        VStack {
            Button {
                let newPatient = Patient(name: "Bob Parker", dateOfBirth: .now)
                modelContext.insert(newPatient)
            } label: {
                Text("Add Patient")
            }

            ForEach(patients) { patient in
                HStack {
                    Text(patient.name)
                    Text(patient.dateOfBirth.description)
                }
            }
        }
    }
}

#Preview {
    PatientsView()
}
