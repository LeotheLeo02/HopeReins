//
//  DynamicFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/20/24.
//

import SwiftUI
import SwiftData

enum FileModification: String {
    case added = "Created"
    case edited = "Modified"
    case deleted = "Deleted"
}

struct FormSectionContent: View {
    @Environment(\.modelContext) var modelContext
    var wrappedElement: DynamicUIElementWrapper
    var changeDescriptions: [ChangeDescription]
    @Binding var selectedVersion: Version?
    @Binding var selectedFieldChange: String?
    @Binding var initialProperties: [String : CodableValue]
    var record: MedicalRecordFile
    
    var body: some View {
        ScrollView {
            VStack {
                if selectedVersion != nil {
                    ForEach(selectedVersion!.changes, id: \.self) { change in
                        if change.fieldID == wrappedElement.id {
                            HStack {
                                OriginalValueView(id: wrappedElement.id, value: change.propertyChange, displayName: change.displayName, onTap: {
                                    selectedFieldChange = wrappedElement.id
                                })
                                Button(action: {
                                    if  record.revertToPastChange(fieldId: selectedFieldChange, version: selectedVersion!, revertToAll: false, modelContext: modelContext) {
                                        modelContext.delete(selectedVersion!)
                                        selectedVersion = nil
                                    }
                                    print(change.propertyChange)
                                    initialProperties[selectedFieldChange!] = CodableValue.string(change.propertyChange)
                                }, label: {
                                    Image(systemName: "arrowshape.turn.up.backward.fill")
                                })
                                .buttonStyle(.plain)
                            }
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.windowBackground))
                        }
                    }
                }
            }
            .padding(5)
        }
    }
}


struct OriginalValueView: View {
    var id: String
    var value: String
    var displayName: String?
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Original Value:")
                .foregroundStyle(.gray)
                .font(.caption.bold())
            Text(displayName ?? (value.isEmpty ? "Default Value" : value))
                   .font(.caption2)
                   .bold(displayName != nil)

        }
        .padding(5)
        .onTapGesture(perform: onTap)
    }
    
}

struct DynamicFormView: View  {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var isAdding: Bool
    @State var text: String = ""
    @State var patient: Patient?
    @State var initialProperties: [String: CodableValue] = [:]
    @State var record: MedicalRecordFile
    var username: String
    var changeDescriptions: [ChangeDescription] {
        return record.compareProperties(with: initialProperties)
    }
    @State var showPastChanges: Bool = false
    @State var selectedVersion: Version?
    @State var selectedFieldChange: String?
    @State var reviewChanges: Bool = false
    @State var isRevertingVersion: Bool = false
    @State var showRevertAlert: Bool = false
    @State var uiElements: [FormSection] = []
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    if !isAdding {
                        HStack {
                            Spacer()
                            PastChangeSelectionView(showPastChanges: $showPastChanges, selectedVersion: $selectedVersion, pastVersions: record.versions)
                        }
                    }
                    ForEach(uiElements, id: \.title) { section in
                        if uiElements.count == 1 {
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
                                    SectionHeader(title: section.title)
                                }
                            )
                            .id(section.title)
                        }
                    }
                    
                }
                .onAppear {
                    if !isAdding {
                        initialProperties = record.properties
                    }
                    uiElements = getUIElements()
                }
                .alert(isPresented: $showRevertAlert) {
                    if isRevertingVersion {
                        Alert(
                            title: Text("Revert To Version \(selectedVersion!.reason)"),
                            message: Text("Are you sure you want to revert all your changes to this version. You can't undo this action."),
                            primaryButton: .destructive(Text("Revert")) {
                                record.revertToPastChange(fieldId: nil, version: selectedVersion!, revertToAll: true, modelContext: modelContext)
                                selectedVersion = nil
                                initialProperties = record.properties
                            },
                            secondaryButton: .cancel()
                        )
                    } else {
                        Alert(
                            title: Text("Revert Changes"),
                            message: Text("Are you sure you want to revert all your changes. You can't undo this action."),
                            primaryButton: .destructive(Text("Undo")) {
                                record.properties = initialProperties
                                dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .sheet(isPresented: $reviewChanges, content: {
                    ReviewChangesView(changeDescriptions: changeDescriptions, record: record, initialProperties: $initialProperties, username: username)
                })
                .padding()
            }
        }
        .frame(minWidth: 650, minHeight: 600)
        .toolbar {
            toolbarContent()
        }
    }
    
    @ViewBuilder
    func sectionContent(section: FormSection) -> some View {
        ForEach(section.elements.map(DynamicUIElementWrapper.init), id: \.id) { wrappedElement in
            HStack {
                VStack(alignment: .leading) {
                    VStack {
                        if selectedVersion?.changes.contains(where: { $0.fieldID == wrappedElement.id }) == true {
                            Button(action: {
                                selectedFieldChange = wrappedElement.id
                            }, label: {
                                Text("Changes")
                                Image(systemName: "chevron.right.circle.fill")
                            })
                            .popover(isPresented: Binding<Bool>(
                                get: { self.selectedFieldChange == wrappedElement.id },
                                set: { show in if !show { self.selectedFieldChange = nil } }
                            ), attachmentAnchor: .point(UnitPoint.top), arrowEdge: .top) {
                                FormSectionContent(wrappedElement: wrappedElement, changeDescriptions: changeDescriptions, selectedVersion: $selectedVersion, selectedFieldChange: $selectedFieldChange, initialProperties: $initialProperties, record: record)
                            }
                        }
                        DynamicElementView(wrappedElement: wrappedElement.element)
                    }
                    if changeDescriptions.first(where: { $0.id == wrappedElement.id }) != nil {
                        Text("Modified")
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.red)
                    }
                }
                if selectedVersion != nil {
                    
                }
            }
        }
        .padding(3)
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        if isAdding {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    addFile()
                    dismiss()
                } label: {
                    HStack {
                        Text("Add File")
                        Image(systemName: "doc.badge.plus")
                    }
                }
            }
        } else if !changeDescriptions.isEmpty {
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
            ToolbarItem(placement: .destructiveAction) {
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
                if !changeDescriptions.isEmpty {
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
        return uiElements.reduce(0) { $0 + $1.elements.count }
    }
    
    func pastChangeValueString(value: CodableValue) -> String {
        switch value {
        case .int(let value):
            return "Integer: \(value)"
        case .string(let value):
            return "String: \(value)"
        case .double(let value):
            return "Double: \(value)"
        case .bool(let value):
            return "Boolean: \(value ? "true" : "false")"
        case .date(let value):
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            return "Date: \(dateFormatter.string(from: value))"
        case .data(let value):
            return "Data: \(value.base64EncodedString())"
        }
    }
    
    func addFile() {
        let newDigitalSig = DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now)
        modelContext.insert(newDigitalSig)
        record.digitalSignature = newDigitalSig
        newDigitalSig.created(by: username)
        modelContext.insert(record)
       try? modelContext.save()
    }
    
    func getUIElements() -> [FormSection] {
        if let type = RidingFormType(rawValue: record.fileType) {
            switch type {
            case .releaseStatement:
                return []
            case .coverLetter:
                return []
            case .updateCoverLetter:
                return []
            case .ridingLessonPlan:
                return record.getRidingLessonPlan()
            }
        }
        if let type = PhysicalTherabyFormType(rawValue: record.fileType) {
            switch type {
            case .evaluation:
                return record.getEvaluation()
            case .dailyNote:
                return []
            case .reEvaluation:
                return []
            case .medicalForm:
                return []
            case .missedVisit:
                return []
            case .referral:
                return []
            }
        }
        return []
    }
}

