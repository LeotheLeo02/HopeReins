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


struct PatientDetailView: View {
    let patient: Patient
    let patientId: UUID
    var user: User
    @Environment(\.modelContext) var modelContext
    @State var showDeleteAlert: Bool = false
    @State var selectedFile: PatientFile?
    @State var showEdit: Bool = false
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
        List {
            Picker(selection: $selectedFormType) {
                Text("Adaptive Riding")
                    .tag(FormType.riding(.coverLetter))
                Text("Phyisical Theraby")
                    .tag(FormType.physicalTherapy(.dailyNote))
            } label: {
                Text("Form Type")
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            switch selectedFormType {
            case .physicalTherapy(_):
                if !physicalTherapyFiles.isEmpty {
                    ForEach(physicalTherapyFiles, id: \.self) { file in
                        uploadedListItem(file: file)
                    }
                }
            case .riding(_):
                if !ridingFiles.isEmpty {
                    ForEach(ridingFiles, id: \.self) { file in
                        uploadedListItem(file: file)
                    }
                }
            }
        }
        .sheet(isPresented: $addFile, content: {
            FormAddView(selectedSpecificForm: $selectedSpecificForm, patient: patient, user: user)
                .frame(minWidth: 500, minHeight: 300)
        })
        .sheet(isPresented: $showEdit, content: {
            if let _selectedFile = selectedFile {
                FormEditView(file: _selectedFile, user: user)
            }
        })
        .alert("Delete \(selectedFile?.name ?? "")", isPresented: $showDeleteAlert, actions: {
            Button(role: .destructive) {
                if let _selectedFile = selectedFile {
                    modelContext.delete(_selectedFile)
                }
            } label: {
                Text("Delete")
            }
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

extension PatientDetailView {
    @ViewBuilder func uploadedListItem(file: PatientFile) -> some View {
        Button {
            if let url = saveToTemporaryFile(data: file.data) {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack {
                FilePreview(data: file.data, size: 25)
                Text(file.name)
                Spacer()
                Text("Created By: \(file.author) \(file.dateAdded.formatted())")
                    .font(.caption.italic())
            }
        }
        .contextMenu {
            Button {
                selectedFile = file
                showEdit.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button  {
                selectedFile = file
                showDeleteAlert.toggle()
            } label: {
                Text("Delete")
            }
            
        }
    }
}

struct FilePreview: View {
    var data: Data
    var size: CGFloat
    var body: some View {
        if let image = NSImage(data: data) {
            HStack {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size, alignment: .center)
            }
        }
    }
}


func saveToTemporaryFile(data: Data) -> URL? {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString)
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving to temporary file: \(error)")
        return nil
    }
}
