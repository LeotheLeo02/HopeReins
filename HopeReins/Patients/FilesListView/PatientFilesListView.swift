//
//  PatientDetailView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI
import SwiftData

struct SearchCriteria {
    var name: String?
    var date: Date?
    var fileType: String?
}
enum FormType: Hashable {
    case physicalTherapy(PhysicalTherabyFormType)
    case riding(RidingFormType)

    static func from(string: String) -> FormType? {
        if let physicalTherapyForm = PhysicalTherabyFormType(rawValue: string) {
            return .physicalTherapy(physicalTherapyForm)
        } else if let ridingForm = RidingFormType(rawValue: string) {
            return .riding(ridingForm)
        }
        return nil
    }
}

struct PatientFilesListView: View {
    let patient: Patient
    let patientId: UUID
    var user: User
    @State var searchText = ""
    @Environment(\.modelContext) var modelContext
    @State var selectedFile: MedicalRecordFile?
    @State var selectedFormType: FormType = .riding(.coverLetter)
    @State var addFile: Bool = false
    @State var selectedSpecificForm: String?
    @Query(sort: \MedicalRecordFile.fileType) var files: [MedicalRecordFile]
    
    init (patient: Patient, user: User) {
        self.patient = patient
        self.patientId = patient.id
        self.user = user
        let predicate = #Predicate<MedicalRecordFile> { patientFile in
            patientFile.patient.id == patientId
        }
        _files = Query(filter: predicate, sort: \MedicalRecordFile.fileType)
    }
    
    private var physicalTherapyFiles: [MedicalRecordFile] {
        files.filter {
            if let formType = FormType.from(string: $0.fileType) {
                if case .physicalTherapy(_) = formType {
                    return true
                }
            }
            return false
        }
    }
    
    private var ridingFiles: [MedicalRecordFile] {
        files.filter {
            if let formType = FormType.from(string: $0.fileType) {
                if case .riding(_) = formType {
                    return true
                }
            }
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if searchText.isEmpty {
                    Picker(selection: $selectedFormType) {
                        Text("Adaptive Riding")
                            .tag(FormType.riding(.coverLetter))
                        Text("Phyisical Theraby")
                            .tag(FormType.physicalTherapy(.referral))
                    } label: {
                        Text("Form Type")
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    switch selectedFormType {
                    case .physicalTherapy(_):
                        PhysicalTherapyFileListView(files: physicalTherapyFiles, user: user)
                    case .riding(_):
                        RidingFileListView(files: ridingFiles, user: user)
                    }
                } else {
                    FilteredFilesList(user: user, filteredFiles: filteredFiles)
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "Date, File Type, Name")
        .searchSuggestions({
            ForEach(searchSuggestions, id:\.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
        })
        .sheet(isPresented: $addFile, content: {
            FormAddView(selectedSpecificForm: $selectedSpecificForm, patient: patient, user: user)
                .frame(minWidth: 500, minHeight: 300)
        })
        .navigationTitle(patient.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Section {
                        ForEach(RidingFormType.allCases, id: \.rawValue) { rideForm in
                            Button {
                                    selectedSpecificForm = rideForm.rawValue
                                    addFile.toggle()
                            } label: {
                                Text(rideForm.rawValue)
                            }
                        }
                    } header: {
                        Text("Adpative Riding")
                            .bold()
                            .underline()
                    }
                    
                    Section {
                        ForEach(PhysicalTherabyFormType.allCases, id: \.rawValue) { phyiscalForm in
                            Button  {
                                    selectedSpecificForm = phyiscalForm.rawValue
                                    addFile.toggle()
                            } label: {
                                Text(phyiscalForm.rawValue)
                            }
                            
                        }
                    } header: {
                        Text("Physical Theraby")
                            .bold()
                            .underline()
                    }
                    
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct FilteredFilesList: View {
    @Environment(\.modelContext) var modelContext
    var user: User
    var filteredFiles: [MedicalRecordFile]
    var body: some View {
        ForEach(filteredFiles, id: \.self) { file in
            NavigationLink {
                    FormEditView(file: file, user: user)
            } label: {
                UploadedListItem(file: file)
            }
        }
    }
}
