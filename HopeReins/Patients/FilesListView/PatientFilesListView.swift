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
extension PatientFilesListView {
    private func parseSearchText(_ searchText: String) -> SearchCriteria {
        var criteria = SearchCriteria()

        let physicalTherapyTypes = PhysicalTherabyFormType.allCases.map { $0.rawValue.lowercased() }
        let ridingTypes = RidingFormType.allCases.map { $0.rawValue.lowercased() }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Adjust the date format as needed

        let components = searchText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for component in components {
            let lowercasedComponent = component.lowercased()
            print(component)
            // Check if the component is a date
            if criteria.date == nil, let date = dateFormatter.date(from: component) {
                criteria.date = date
                continue // Move to the next component
            }

            // Check if the component is a known file type
            if criteria.fileType == nil {
                if physicalTherapyTypes.contains(lowercasedComponent) {
                    criteria.fileType = component
                    continue // Move to the next component
                } else if ridingTypes.contains(lowercasedComponent) {
                    criteria.fileType = component
                    continue // Move to the next component
                }
            }

            // If the component is neither date nor file type, assume it is the name
            if criteria.name == nil {
                criteria.name = component
            } else {
                // Append to the name if it's already partially captured
                criteria.name = "\(criteria.name!) \(component)"
            }
        }

        return criteria
    }
}



extension PatientFilesListView {
    var searchSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }

        let lowercasedSearchText = searchText.lowercased()
        var suggestions = Set<String>()

        suggestions.formUnion(files
            .map { $0.name }
            .filter { $0.lowercased().contains(lowercasedSearchText) })

        suggestions.formUnion(files
            .map { $0.fileType }
            .filter { $0.lowercased().contains(lowercasedSearchText) })

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        suggestions.formUnion(files
            .map { dateFormatter.string(from: $0.dateAdded) }
            .filter { $0.contains(searchText) })

        return Array(suggestions)
    }
}



extension PatientFilesListView {
    var filteredFiles: [PatientFile] {
        if searchText.isEmpty {
            return files
        } else {
            let criteria = parseSearchText(searchText)
            return files.filter { file in
                var matches = true
                
                // Check if the file name matches
                if let name = criteria.name {
                    matches = matches && file.name.localizedCaseInsensitiveContains(name)
                }
                // Check if the file date matches
                if let date = criteria.date {
                    matches = matches && Calendar.current.isDate(file.dateAdded, inSameDayAs: date)
                }
                // Check if the file type matches
                if let fileType = criteria.fileType {
                    matches = matches && file.fileType.localizedStandardContains(fileType)
                }
                return matches
            }
        }
    }

}


struct PatientFilesListView: View {
    let patient: Patient
    let patientId: UUID
    var user: User
    @State private var searchText = ""
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
                ForEach(filteredFiles) { file in
                    Text(file.name)
                }
                switch selectedFormType {
                case .physicalTherapy(_):
                    PhysicalTherapyFileListView(files: physicalTherapyFiles, user: user)
                case .riding(_):
                    RidingFileListView(files: ridingFiles, user: user)
                }
            }
            .padding()
        }
        .searchable(text: $searchText)
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
