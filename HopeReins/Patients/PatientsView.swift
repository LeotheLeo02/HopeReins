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
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case list
        case grid
    }
    @SceneStorage("viewMode") private var mode: ViewMode = .grid
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if filteredPatients.isEmpty {
                    Label("No Patients Found", systemImage: "person.3.sequence")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.gray)
                }
                Group {
                    switch mode {
                    case .list:
                        VStack(alignment: .leading) {
                            ForEach(filteredPatients) { patient in
                                ListLabel(user: user, patient: patient)
                            }
                        }
                    case .grid:
                        LazyVGrid(columns: columns, content: {
                            ForEach(filteredPatients) { patient in
                                GridLabel(user: user, patient: patient, size: itemSize)
                            }
                        })
                    }
                }

                .padding()
                .searchable(text: $searchQuery, prompt: "Patient Name, MRN Number")
                .searchSuggestions({
                    ForEach(searchSuggestions, id:\.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                })
                .sheet(isPresented: $addPatient, content: {
                    let record = MedicalRecordFile(fileType: "Patient")
                    DynamicFormView(uiManagement: UIManagement(modifiedProperties: record.properties, record: record, username: user.username, patient: nil, isAdding: true, modelContext: modelContext), files: [])
                        .frame(minWidth: 1000, minHeight: 500)
                })
            }
            .padding([.horizontal, .top])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ItemSizeSlider(size: $itemSize)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    DisplayModePicker(mode: $mode)
                }
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
    
    private struct ListLabel: View {
        var user: User
        var patient: Patient
        var body: some View {
            NavigationLink {
                PatientFilesView(user: user, patient: patient)
            } label: {
                HStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color(.primary))
                    Text(patient.personalFile.properties["File Name"]!.stringValue)
                    Spacer()
                }
                .font(.title2)
                .foregroundStyle(.primary)
                .padding()
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
                        Text(patient.personalFile.properties["File Name"]!.stringValue)
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
    @Environment(\.modelContext) var modelContext
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
                Text("Deleted Files (\(getCountOfDeadFiles()))")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.headline)
        }
        .buttonStyle(.borderless)
        .padding(5)
        .background(.bar)
    }
    
    func getCountOfDeadFiles() -> Int {
        let optionalID = Optional(patient.id)
        let descriptor = FetchDescriptor<MedicalRecordFile>(predicate: #Predicate { $0.isDead == true && $0.patient?.id == optionalID })

        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        
        return count
    }
}


import SwiftUI

struct DisplayModePicker: View {
    @Binding var mode: PatientsView.ViewMode

    var body: some View {
        Picker("Display Mode", selection: $mode) {
            ForEach(PatientsView.ViewMode.allCases) { viewMode in
                viewMode.label
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

extension PatientsView.ViewMode {

    var labelContent: (name: String, systemImage: String) {
        switch self {
        case .list:
            return ("List", "list.bullet")
        case .grid:
            return ("Grid", "square.grid.2x2")
        }
    }

    var label: some View {
        let content = labelContent
        return Label(content.name, systemImage: content.systemImage)
    }
}
