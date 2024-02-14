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
    @Query var patients: [Patient]
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
                if filteredPatients.isEmpty {
                    Label("No Patients Found", systemImage: "person.3.sequence")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.gray)
                }
                LazyVGrid(columns: columns, content: {
                    ForEach(filteredPatients) { patient in
                        GridLabel(user: user, patient: patient, size: itemSize)
                    }
                })
                .padding()
                .searchable(text: $searchQuery, prompt: "Patient Name, MRN Number")
                .sheet(isPresented: $addPatient, content: {
                    let record = MedicalRecordFile(fileType: "Patient")
                    DynamicFormView(uiManagement: UIManagement(modifiedProperties: record.properties, record: record), isAdding: true, username: user.username)
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
                PatientFilesView(user: user, patient: patient)
            } label: {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .foregroundStyle(Color(.primary))
                        Text(patient.personalFile.properties["Name"]!.stringValue)
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

struct PatientFilesView: View {
    var user: User
    var patient: Patient
    var body: some View {
        PatientFilesListView(patient: patient, user: user, showDeadFiles: false)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                deletedFilesLink
            }
    }
    private var deletedFilesLink: some View {
        NavigationLink {
           PatientFilesListView(patient: patient, user: user, showDeadFiles: true)
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.red)
                Text("Deleted Files")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.headline)
        }
        .buttonStyle(.borderless)
        .padding(5)
        .background(.bar)
    }
}
