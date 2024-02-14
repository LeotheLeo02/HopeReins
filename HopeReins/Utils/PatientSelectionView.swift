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
    @Query var patients: [Patient]
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        } else {
            let lowercasedSearchText = searchText.lowercased()
            let filteredPatients = patients.filter { patient in
                (patient.personalFile.properties["Name"]?.stringValue.lowercased() ?? "").contains(lowercasedSearchText)
            }
            return filteredPatients
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
                            Text(patient.personalFile.properties["Name"]!.stringValue)
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
