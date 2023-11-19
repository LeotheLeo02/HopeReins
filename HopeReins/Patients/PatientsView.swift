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
    @Query(sort: \Patient.dateOfBirth, order: .forward) var patients: [Patient]
    var user: User
    let columns: [GridItem] = [
            GridItem(.adaptive(minimum: 200))
    ]
    @State var addPatient: Bool = false
    @State private var searchQuery = ""
    var filteredPatients: [Patient] {
        if searchQuery.isEmpty {
            return patients
        } else {
            return patients.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(filteredPatients) { patient in
                        NavigationLink {
                            PatientFilesListView(patient: patient, user: user)
                        } label: {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundStyle(Color(.primary))
                                    Text(patient.name)
                                }
                                .font(.largeTitle)
                                .foregroundStyle(.primary)
                                .padding()
                                Spacer()
                            }
                        }
                    }
                })
                .padding()
                .searchable(text: $searchQuery, prompt: "Search Patients")
                .sheet(isPresented: $addPatient, content: {
                    AddPatientView()
                })
            }
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
    }
}
