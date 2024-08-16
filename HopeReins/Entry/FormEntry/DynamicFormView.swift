//
//  DynamicFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/20/24.
//

import SwiftUI
import SwiftData



enum ActiveAlert {
    case revertVersion, revertChanges, cancelSave
}

struct DynamicFormView: View  {
    @Environment(\.isEditable) var isEditable
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @StateObject var uiManagement: UIManagement
    @State var text: String = ""
    @State var showPastChanges: Bool = false
    @State var selectedVersion: Version?
    @State var selectedFieldChange: String?
    @State var reviewChanges: Bool = false
    @State var activeAlert: ActiveAlert = .revertVersion
    @State var showAlert: Bool = false
    var files: [MedicalRecordFile]
    @State private var selectedFile: MedicalRecordFile?
    
    var body: some View {
        HStack {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    if !files.isEmpty {
                        HStack {
                            if !uiManagement.isAdding {
                                Button(action: {
                                    self.onPrint()
                                }, label: {
                                    HStack {
                                        Text("Print")
                                        Image(systemName: "printer.fill")
                                    }
                                })
                            }
                            Spacer()
                            if !uiManagement.isAdding {
                                PastChangeSelectionView(showPastChanges: $showPastChanges, selectedVersion: $selectedVersion, pastVersions: uiManagement.record.versions)
                            }
                            Menu {
                                CategorizedFormsView(selectedFile: $selectedFile, files: files, formType: .riding(.coverLetter))
                                CategorizedFormsView(selectedFile: $selectedFile, files: files, formType: .physicalTherapy(.dailyNote))
                            } label: {
                                Image(systemName: "macwindow.badge.plus")
                            }
                            .font(.largeTitle)
                            .buttonStyle(.borderless)
                            .help("Open another file")
                            
                        }
                        .padding([.top, .horizontal])
                    }
                    if !uiManagement.errorMessage.isEmpty {
                        Text(uiManagement.errorMessage)
                            .foregroundStyle(.red)
                            .padding([.top, .horizontal])
                    }
                    ScrollView {
                        VStack(alignment: .leading) {
                            if let section = uiManagement.dynamicUIElements.first {
                                sectionContent(section: section)
                            }
                            ForEach(Array(uiManagement.dynamicUIElements.enumerated()).dropFirst(), id: \.element.title) { index, section in
                                if uiManagement.dynamicUIElements.count == 2 {
                                    sectionContent(section: section)
                                } else {
                                    DisclosureGroup(
                                        content: {
                                            sectionContent(section: section)
                                                .onAppear {
                                                    proxy.scrollTo(section.title)
                                                }
                                        },
                                        label: {
                                            HStack {
                                                SectionHeader(title: section.title)
                                                let changesCount = countChangesInSection(section)
                                                let modificationCount = countModificationsInSection(section)
                                                if changesCount > 0 {
                                                    Text("\(changesCount) changes")
                                                        .font(.subheadline)
                                                        .foregroundColor(.red)
                                                } else if modificationCount > 0 {
                                                    Text("\(changesCount) modifications")
                                                        .font(.subheadline)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    )
                                    .id(section.title)
                                }
                            }
                            
                        }
                        .alert(isPresented: $showAlert) {
                            switch activeAlert {
                            case .revertVersion:
                                return Alert(
                                    title: Text("Revert To Version \(selectedVersion!.reason)"),
                                    message: Text("Are you sure you want to revert all your changes to this version. You can't undo this action."),
                                    primaryButton: .destructive(Text("Revert")) {
                                        uiManagement.revertToVersion(selectedVersion: selectedVersion, modelContext: modelContext)
                                        selectedVersion = nil
                                    },
                                    secondaryButton: .cancel()
                                )
                            case .revertChanges:
                                return  Alert(
                                    title: Text("Revert Changes"),
                                    message: Text("Are you sure you want to revert all your changes. You can't undo this action."),
                                    primaryButton: .destructive(Text("Undo")) {
                                        dismiss()
                                    },
                                    secondaryButton: .cancel()
                                )
                            case .cancelSave:
                                return  Alert(
                                    title: Text("Incomplete Form"),
                                    message: Text("The form will not save due to incompleteness. Do you want to discard this file? You can't undo this action."),
                                    primaryButton: .destructive(Text("Discard")) {
                                        dismiss()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        .sheet(isPresented: $reviewChanges, content: {
                            ReviewChangesView(uiManagement: uiManagement, changeDescriptions: uiManagement.changeDescriptions)
                        })
                        .padding()
                    }
                    .toolbar {
                        toolbarContent()
                    }
                    
                    
                }
            }
            if selectedFile != nil {
                Divider()
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            selectedFile = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                        Spacer()
                        Label("Viewing", systemImage: "eye")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.trailing)
                    
                    DynamicFormView(uiManagement: UIManagement(modifiedProperties: selectedFile!.properties, record: selectedFile!, username: uiManagement.username, patient: uiManagement.patient, isAdding: false, modelContext: modelContext), files: [])
                        .id(selectedFile!.id)
                        .environment(\.isEditable, false)
                }
                .padding(.vertical)
            }
        }
        .onChange(of: uiManagement.modifiedProperties) { oldValue, newValue in
            uiManagement.refreshUI()
        }
        .onAppear {
            if uiManagement.isAdding && uiManagement.isRevaluation {
                transferGoalsFromLatestEval()
            }
        }
    }
    
    @ViewBuilder
    func sectionContent(section: FormSection) -> some View {
        ForEach(section.elements.map(DynamicUIElementWrapper.init), id: \.id) { wrappedElement in
            SectionElement(wrappedElement: wrappedElement, selectedVersion: $selectedVersion, selectedFieldChange: $selectedFieldChange, uiManagement: uiManagement)
            
        }
        .padding(3)
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {

        if !uiManagement.changeDescriptions.isEmpty {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    reviewChanges.toggle()
                } label: {
                    HStack {
                        Text("Review Changes")
                        Image(systemName: "eyes.inverse")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        if selectedVersion != nil {
            ToolbarItem(placement: .automatic) {
                Button {
                    activeAlert = .revertVersion
                    showAlert.toggle()
                } label: {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                        Text("Revert To This Version")
                    }
                }
                
            }
        }
        
        ToolbarItem(placement: .cancellationAction) {
            if !uiManagement.changeDescriptions.isEmpty || uiManagement.isAdding {
                Button("Cancel") {
                    if uiManagement.isAdding {
                        if uiManagement.isEmptyNewFile {
                            dismiss()
                        } else {
                            activeAlert = .cancelSave
                            showAlert.toggle()
                        }
                    } else if !uiManagement.changeDescriptions.isEmpty {
                        activeAlert = .revertChanges
                        showAlert.toggle()
                    } else {
                        dismiss()
                    }
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                if uiManagement.isAdding {
                    uiManagement.addFile()
                }
                uiManagement.record.properties = uiManagement.modifiedProperties
                uiManagement.refreshUI()
                dismiss()
            } label: {
                Text("Done")
            }
            .disabled((uiManagement.isAdding && !uiManagement.isFileComplete) || !uiManagement.changeDescriptions.isEmpty)
        }
        
    }
    func getCountOfFields() -> Int {
        return uiManagement.dynamicUIElements.reduce(0) { $0 + $1.elements.count }
    }
    
    func countChangesInSection(_ section: FormSection) -> Int {
        let wrappedElements = section.elements.map(DynamicUIElementWrapper.init)
        let changesInSection = wrappedElements.compactMap { wrappedElement -> Int? in
            if let changes = selectedVersion?.changes, changes.contains(where: { $0.fieldID == wrappedElement.id }) {
                return changes.filter { $0.fieldID == wrappedElement.id }.count
            }
            return nil
        }
        return changesInSection.reduce(0, +)
    }
    
    func countModificationsInSection(_ section: FormSection) -> Int {
        let wrappedElements = section.elements.map(DynamicUIElementWrapper.init)
        let changeDescriptions = uiManagement.changeDescriptions
        let changesInSection = wrappedElements.compactMap { wrappedElement -> Int? in
            return uiManagement.changeDescriptions.filter { $0.id == wrappedElement.id }.count
        }
        
        return 0
    }
    
}

struct CategorizedFormsView: View {
    @Binding var selectedFile: MedicalRecordFile?
    var files: [MedicalRecordFile]
    var formType: FormType
    
    private var fileGroups: [(String, [MedicalRecordFile])] {
        subcategories(for: formType).map { subcategory in
            (subcategory, filesForSubcategory(subcategory: subcategory))
        }
    }
    
    private func filesForSubcategory(subcategory: String) -> [MedicalRecordFile] {
        let filteredFiles = files.filter { $0.fileType == subcategory }
        
        let sortedFiles = filteredFiles.sorted {
            $0.addedSignature!.dateModified > $1.addedSignature!.dateModified
        }
        
        return sortedFiles
    }
    
    private func subcategories(for formType: FormType) -> [String] {
        switch formType {
        case .physicalTherapy:
            return PhysicalTherapyFormType.allCases.map { $0.rawValue }
        case .riding:
            return RidingFormType.allCases.map { $0.rawValue }
        }
    }
    
    var body: some View {
        Menu {
            ForEach(fileGroups, id: \.0) { group in
                if !group.1.isEmpty {
                    Section(header: Text(group.0)) {
                        ForEach(group.1, id: \.id) { file in
                            Button {
                                selectedFile = nil
                                selectedFile = file
                            } label: {
                                Text(file.properties["File Name"]!.stringValue + "\(selectedFile?.id == file.id ? " (Currently Viewing)" : "")")
                            }
                            .disabled(selectedFile?.id == file.id)
                        }
                    }
                }
            }
        } label: {
            switch formType {
            case .physicalTherapy:
                Text("Physical Therapy")
            case .riding:
                Text("Adaptive Riding")
            }
        }
    }
}


extension DynamicFormView {
    func transferGoalsFromLatestEval() {
        let reEvaluationRawValue = PhysicalTherapyFormType.reEvaluation.rawValue
        let pocRawValue = PhysicalTherapyFormType.physicalTherapyPlanOfCare.rawValue
        
        var fetchRequest = FetchDescriptor<MedicalRecordFile>(
            predicate: #Predicate { record in
                (record.fileType == reEvaluationRawValue) || (record.fileType == pocRawValue) && (record.isDead == false)
            },
            sortBy: [SortDescriptor(\.addedSignature?.dateModified, order: .reverse)]
        )
        fetchRequest.fetchLimit = 1
        
        
        if let latestRecord = try? modelContext.fetch(fetchRequest).first {
            if let shortTermGoals = latestRecord.properties["TE Short Term Goals"],
               let longTermGoals = latestRecord.properties["TE Long Term Goals"] {
                uiManagement.modifiedProperties["TE Short Term Goals"] = shortTermGoals
                uiManagement.modifiedProperties["TE Long Term Goals"] = longTermGoals
            }
        }
    }
}
