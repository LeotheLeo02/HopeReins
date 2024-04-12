//
//  DynamicFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/20/24.
//

import SwiftUI
import SwiftData



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
    @State var isRevertingVersion: Bool = false
    @State var showRevertAlert: Bool = false
    var files: [MedicalRecordFile]
    @State private var selectedFile: MedicalRecordFile?
    
    var body: some View {
        HStack {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    if !uiManagement.isAdding && !files.isEmpty  {
                        HStack {
                            Button(action: {
                                self.onPrint()
                            }, label: {
                                HStack {
                                    Text("Print")
                                    Image(systemName: "printer.fill")
                                }
                            })
                            Spacer()
                            PastChangeSelectionView(showPastChanges: $showPastChanges, selectedVersion: $selectedVersion, pastVersions: uiManagement.record.versions)
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
                    } else {
                            if !uiManagement.errorMessage.isEmpty {
                                Text(uiManagement.errorMessage)
                                    .foregroundStyle(.red)
                                    .padding([.top, .horizontal])
                            }
                        }
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(uiManagement.dynamicUIElements, id: \.title) { section in
                                    if uiManagement.dynamicUIElements.count == 1 {
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
                                                    if changesCount > 0 {
                                                        Text("\(changesCount) changes")
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
                            .alert(isPresented: $showRevertAlert) {
                                if isRevertingVersion {
                                    Alert(
                                        title: Text("Revert To Version \(selectedVersion!.reason)"),
                                        message: Text("Are you sure you want to revert all your changes to this version. You can't undo this action."),
                                        primaryButton: .destructive(Text("Revert")) {
                                            uiManagement.revertToVersion(selectedVersion: selectedVersion, modelContext: modelContext)
                                            selectedVersion = nil
                                        },
                                        secondaryButton: .cancel()
                                    )
                                } else {
                                    Alert(
                                        title: Text("Revert Changes"),
                                        message: Text("Are you sure you want to revert all your changes. You can't undo this action."),
                                        primaryButton: .destructive(Text("Undo")) {
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
                        Button {
                            selectedFile = nil
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                        
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
        if uiManagement.isAdding {
            ToolbarItem(placement: .automatic) {
                Button {
                    uiManagement.addFile(modelContext: modelContext)
                    if uiManagement.errorMessage.isEmpty {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text("Add File")
                        Image(systemName: "doc.badge.plus")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        } else if !uiManagement.changeDescriptions.isEmpty {
            ToolbarItem(placement: .automatic) {
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
                    isRevertingVersion = true
                    showRevertAlert.toggle()
                } label: {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                        Text("Revert To This Version")
                    }
                }
                
            }
        }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if !uiManagement.changeDescriptions.isEmpty {
                        isRevertingVersion = false
                        showRevertAlert.toggle()
                    } else {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                }
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

