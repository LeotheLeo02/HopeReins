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

    
    static var allCases: [FormType] {
        // Combine all cases from both subtypes
        return PhysicalTherabyFormType.allCases.map(FormType.physicalTherapy) +
        RidingFormType.allCases.map(FormType.riding)
    }
    
    var stringValue: String {
        switch self {
        case .physicalTherapy(let type):
            return "physicalTherapy.\(type.rawValue)"
        case .riding(let type):
            return "riding.\(type.rawValue)"
        }
    }
    
    static func from(string: String) -> FormType? {
        let components = string.split(separator: ".")
        guard components.count == 2 else { return nil }
        let typePart = String(components[0])
        let valuePart = String(components[1])

        switch typePart {
        case "physicalTherapy":
            if let type = PhysicalTherabyFormType(rawValue: valuePart) {
                return .physicalTherapy(type)
            }
        case "riding":
            if let type = RidingFormType(rawValue: valuePart) {
                return .riding(type)
            }
        default:
            return nil
        }
        return nil
    }
}

import SwiftUI


struct PatientFilesListView: View {
    let patient: Patient
    let patientId: UUID
    var user: User
    var showDeadFiles: Bool
    @State var searchText = ""
    @Environment(\.modelContext) var modelContext
    @State var selectedFile: MedicalRecordFile?
    @State var selectedFormType: FormType = .riding(.coverLetter)
    @State var addFile: Bool = false
    @State var showPatientInfo: Bool = false
    @State var selectedSpecificForm: FormType?
    @Query(sort: \MedicalRecordFile.fileType) var files: [MedicalRecordFile]
    
    init(patient: Patient, user: User, showDeadFiles: Bool) {
        self.patient = patient
        self.patientId = patient.id
        self.showDeadFiles = showDeadFiles
        self.user = user
        let predicate = #Predicate<MedicalRecordFile> { patientFile in
            patientFile.patient?.id == patientId && patientFile.isDead == showDeadFiles
        }
        _files = Query(filter: predicate, sort: \MedicalRecordFile.fileType)
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                listHeader()
                Divider()
                formTypePicker
                formTypeContent
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
        .sheet(isPresented: $showPatientInfo, content: {
            DynamicFormView(uiManagement: UIManagement(modifiedProperties: patient.personalFile.properties, record: patient.personalFile), isAdding: false, username: user.username)
                .environment(\.isEditable, !showDeadFiles)
        })
        .sheet(isPresented: $addFile, content: {
            FormAddView(selectedSpecificForm: $selectedSpecificForm, patient: patient, user: user)
                .frame(minWidth: 500, minHeight: 300)
        })
        .navigationTitle(showDeadFiles ? "Existing Files" : "Patients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                toolbarMenu
            }
        }
    }

    @ViewBuilder
    func listHeader() -> some View {
        HStack {
            Image(systemName:  showDeadFiles ? "trash.fill" : "person.circle")
                .foregroundStyle(showDeadFiles ? .red : .primary)
            Text(showDeadFiles ? "Deleted Files" : patient.personalFile.properties["Name"]?.stringValue ?? "")
                .bold()
        }
        .font(.largeTitle)
        if !showDeadFiles {
            Button {
                showPatientInfo.toggle()
            } label: {
                Label("Personal Info", systemImage: "person.text.rectangle.fill")
            }
        }
    }
    
    private var formTypePicker: some View {
        Picker(selection: $selectedFormType) {
            Text("Adaptive Riding").tag(FormType.riding(.coverLetter))
            Text("Physical Therapy").tag(FormType.physicalTherapy(.referral))
        } label: {
            Text("Form Type")
        }
        .labelsHidden()
        .pickerStyle(.segmented)
    }
    
    private var formTypeContent: some View {
        Group {
            if searchText.isEmpty {
                switch selectedFormType {
                case .physicalTherapy(_):
                    FileListView(files: files, user: user, formType: .physicalTherapy(.evaluation), isEditable: !showDeadFiles)
                case .riding(_):
                    FileListView(files: files, user: user, formType: .riding(.releaseStatement), isEditable: !showDeadFiles)
                }
            } else {
                FilteredFilesList(user: user, filteredFiles: filteredFiles, isEditable: !showDeadFiles)
            }
        }
    }

    private var toolbarMenu: some View {
        Menu {
            Section(header: Text("Adaptive Riding").bold().underline()) {
                ForEach(RidingFormType.allCases, id: \.self) { rideForm in
                    Button {
                        selectedSpecificForm = .riding(rideForm)
                        addFile.toggle()
                    } label: {
                        Text(rideForm.rawValue)
                    }
                }
            }
            
            Section(header: Text("Physical Therapy").bold().underline()) {
                ForEach(PhysicalTherabyFormType.allCases, id: \.self) { physicalForm in
                    Button {
                        selectedSpecificForm = .physicalTherapy(physicalForm)
                        addFile.toggle()
                    } label: {
                        Text(physicalForm.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "plus")
        }
    }
}



struct FilteredFilesList: View {
    @Environment(\.modelContext) var modelContext
    @State var selectedFile: MedicalRecordFile? = nil
    @State var showEditSheet: Bool = false
    var user: User
    var filteredFiles: [MedicalRecordFile]
    var isEditable: Bool
    var body: some View {
        VStack {
            ForEach(filteredFiles, id: \.self) { file in
                Button {
                    selectedFile = file
                    showEditSheet.toggle()
                } label: {
                    ListItemLabel(file: file)
                }
            }
        }
        .sheet(isPresented: $showEditSheet, content: {
            FormEditView(file: $selectedFile, isEditable: isEditable, user: user)
        })
        
    }
}
