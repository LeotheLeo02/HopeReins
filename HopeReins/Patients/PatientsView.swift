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
    var user: User
    @State var addPatient: Bool = false
    @State var selectionId: Patient.ID? = nil
    @State var selectedSpecificForm: String?
    @State private var searchQuery = ""
    @State var addFile: Bool = false
    var filteredPatients: [Patient] {
        if searchQuery.isEmpty {
            return patients
        } else {
            return patients.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredPatients, selection: $selectionId) { patient in
                NavigationLink {
                    PatientDetailView(patient: patient, user: user)
                } label: {
                    HStack {
                        Image(systemName: "person.fill")
                        Text(patient.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .contextMenu {
                        Menu {
                            ForEach(RidingFormType.allCases, id: \.rawValue) { rideForm in
                                Button {
                                        selectedSpecificForm = rideForm.rawValue
                                        addFile.toggle()
                                } label: {
                                    Text(rideForm.rawValue)
                                }
                            }
                        } label: {
                            Label("Adaptive Riding Form", systemImage: "plus")
                        }
                        Menu {
                            ForEach(PhysicalTherabyFormType.allCases, id:\.rawValue) { physicalForm in
                                Button {
                                        selectedSpecificForm = physicalForm.rawValue
                                        addFile.toggle()
                                } label: {
                                    Text(physicalForm.rawValue)
                                }
                            }
                        } label: {
                            Label("Physical Theraby Form", systemImage: "plus")
                        }

                    }
                }
                .sheet(isPresented: $addFile, content: {
                    FormAddView(selectedSpecificForm: $selectedSpecificForm, patient: patient, user: user)
                            .frame(minWidth: 500, minHeight: 300)
                })
                
            }
            .searchable(text: $searchQuery, prompt: "Search Patients")
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
    }
}
