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
    @State var selectionId: Patient.ID? = nil
    @State var selectedPatient: Patient?
    @State var showDeleteAlert: Bool = false
    var body: some View {
        NavigationStack {
            List(patients, selection: $selectionId) { patient in
                NavigationLink {
                    PatientDetailView(patientId: patient.id)
                } label: {
                    HStack {
                        Text(patient.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .contextMenu {
                        Button(action: {
                            selectedPatient = patient
                            showDeleteAlert.toggle()
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
                
            }
            .alert("Delete \(selectedPatient?.name ?? "")", isPresented: $showDeleteAlert, actions: {
                Button(role: .destructive) {
                    if let _selectedPatient = selectedPatient {
                        let patientModel = modelContext.model(for: _selectedPatient.persistentModelID)
                        modelContext.delete(patientModel)
                    }
                } label: {
                    Text("Delete")
                }
            })
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

#Preview {
    PatientsView()
}
