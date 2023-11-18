//
//  PatientDetailView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/18/23.
//

import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) var modelContext
    @State var selectedFile: PatientFile?
    @State var selectedFormType: FormType = .riding(.coverLetter)
    @State var addFile: Bool = false
    @State var selectedSpecificForm: String?
    @Query(sort: \PatientFile.fileType) private var files: [PatientFile]
    
    init (patient: Patient, user: User) {
        self.patient = patient
        self.patientId = patient.id
        self.user = user
        let predicate = #Predicate<PatientFile> { patientFile in
            patientFile.patient?.id == patientId
        }
        _files = Query(filter: predicate, sort: \PatientFile.fileType)
    }
    
    private var physicalTherapyFiles: [PatientFile] {
        files.filter {
            if let formType = FormType.from(string: $0.fileType) {
                if case .physicalTherapy(_) = formType {
                    return true
                }
            }
            return false
        }
    }
    
    private var ridingFiles: [PatientFile] {
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
            }
            .padding()
        }
        .sheet(isPresented: $addFile, content: {
            FormAddView(selectedSpecificForm: $selectedSpecificForm, patient: patient, user: user)
                .frame(minWidth: 500, minHeight: 300)
        })
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
