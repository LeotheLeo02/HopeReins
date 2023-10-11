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
    @State var addPatient: Bool = false
    var body: some View {
        Table(patients) {
            TableColumn("Name", value: \.name)
            TableColumn("Date of Birth") { patient in
                Text(patient.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .sheet(isPresented: $addPatient, content: {
            AddPatientView()
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    addPatient.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
    
    func dateOfBirthFormatter(patient: Patient) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: patient.dateOfBirth)
    }
}

#Preview {
    PatientsView()
}
