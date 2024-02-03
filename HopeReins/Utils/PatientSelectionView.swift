//
//  PatientSelectionView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/10/23.
//

import SwiftUI
import SwiftData

struct PatientSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    @Query(sort: \Patient.dateOfBirth, order: .forward)
    var patients: [Patient]
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        } else {
            return patients.filter { patient in
                patient.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    @Binding var selection: Patient?
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search...", text: $searchText)
            ScrollView {
                VStack {
                    ForEach(filteredPatients) { patient in
                        Button {
                            selection = patient
                            dismiss()
                        } label: {
                            Text(patient.name)
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 100)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                   dismiss()
                } label: {
                    Text("Cancel")
                }

            }
        }
    }
}
