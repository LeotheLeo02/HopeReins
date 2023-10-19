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
    @State var showDeleteAlert: Bool = false
    var body: some View {
        Table(patients, selection: $selectionId) {
            TableColumn("Name", value: \.name)
            TableColumn("Date of Birth") { patient in
                Text(patient.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .contextMenu(forSelectionType: Patient.ID.self, menu: { patients in
            if patients.count == 1 {
                Button(action: {
                    showDeleteAlert.toggle()
                }, label: {
                    Text("Delete")
                })
            }
        })
        .alert("Delete \(selectedPatient().name)", isPresented: $showDeleteAlert, actions: {
            Button(role: .destructive) {
                if let _selectionId = selectionId {
                    let patientModel = modelContext.model(for: _selectionId)
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
    func selectedPatient() -> Patient {
        return patients.first { element in  return element.id == selectionId} ?? .init(name: "", dateOfBirth: .now)
    }
}

#Preview {
    PatientsView()
}
