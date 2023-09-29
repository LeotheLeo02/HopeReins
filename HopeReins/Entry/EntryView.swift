//
//  EntryView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/22/23.
//

import SwiftUI
import SwiftData

struct EntryView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Patient.name, order: .forward)
    var patients: [Patient]
    var body: some View {
        List {
            Button("Add") {
                modelContext.insert(Patient(name: "Bob Parker"))
            }
            ForEach(patients) { patient in
                Text(patient.name)
                Button("Delete") {
                    modelContext.delete(patient)
                }
            }
         }
    }
}




#Preview {
    EntryView()
}
