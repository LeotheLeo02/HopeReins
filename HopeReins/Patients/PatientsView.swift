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
    @State private var itemSize: CGFloat = 200
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemSize, maximum: itemSize), spacing: 40)]
    }
    @State var addPatient: Bool = false
    @State var searchQuery = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(filteredPatients) { patient in
                        GridLabel(user: user, patient: patient, size: itemSize)
                    }
                })
                .padding()
                .searchable(text: $searchQuery, prompt: "Patient Name, MRN Number")
                .sheet(isPresented: $addPatient, content: {
                    AddPatientView()
                })
            }
            .padding([.horizontal, .top])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ItemSizeSlider(size: $itemSize)
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
    private struct GridLabel: View {
        var user: User
        var patient: Patient
        var size: CGFloat
        var body: some View {
            NavigationLink {
                PatientDetailsView(user: user, patient: patient)
            } label: {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .foregroundStyle(Color(.primary))
                        Text(patient.name)
                    }
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding()
                    Spacer()
                }
                .frame(width: size)
            }
        }
    }
    
    private struct ItemSizeSlider: View {
        @Binding var size: CGFloat

        var body: some View {
            HStack {
                Spacer()
                Slider(value: $size, in: 150...300)
                    .controlSize(.small)
                    .frame(width: 100)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .background(.bar)
        }
    }
}

struct PatientDetailsView: View {
    var user: User
    var patient: Patient
    var body: some View {
        VStack {
            NavigationLink {
                PatientFilesListView(patient: patient, user: user, showDeadFiles: true)
            } label: {
                HStack {
                    Text("Deleted Files")
                    Image(systemName: "trash.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.caption)
            }
            PatientFilesListView(patient: patient, user: user, showDeadFiles: false)
        }
    }
}
