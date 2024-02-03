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

struct OriginalValueView: View {
    var value: CodableValue
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Original Value:")
                .foregroundStyle(.gray)
                .font(.caption.bold())
            Text(value.stringValue)
                .font(.caption2.bold())
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.windowBackground))
        .onTapGesture(perform: onTap)
    }
}


struct DynamicFormView: View  {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var isAdding: Bool
    @State var patient: Patient?
    @State var initialProperties: [String: CodableValue] = [:]
    @State var record: MedicalRecordFile
    var username: String
    var changeDescriptions: [ChangeDescription] {
        return record.compareProperties(with: initialProperties)
    }
    @State var showPastChanges: Bool = false
    @State var selectedPastChange: PastChange?
    @State var selectedFieldChange: String?
    @State var reviewChanges: Bool = false
    @State var isRevertingVersion: Bool = false
    @State var showRevertAlert: Bool = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if !isAdding {
                    HStack {
                        Spacer()
                        PastChangeSelectionView(showPastChanges: $showPastChanges, selectedPastChange: $selectedPastChange, pastChanges: record.pastChanges)
                    }
                }
                ForEach(getUIElements().map(DynamicUIElementWrapper.init), id: \.id) { wrappedElement in
                    HStack {
                        VStack(alignment: .leading) {
                            DynamicElementView(wrappedElement: wrappedElement.element)
                            if changeDescriptions.first(where: { $0.id == wrappedElement.id }) != nil {
                               Text("Modified")
                                    .font(.caption)
                                    .italic()
                                    .foregroundStyle(.red)
                            }
                        }
                        if let value = selectedPastChange?.propertyChanges[wrappedElement.id] {
                            OriginalValueView(value: value, onTap: {
                                selectedFieldChange = wrappedElement.id
                            })
                            .popover(isPresented: Binding<Bool>(
                                get: { self.selectedFieldChange == wrappedElement.id },
                                set: { show in if !show { self.selectedFieldChange = nil } }
                            ), attachmentAnchor: .point(UnitPoint.bottom), arrowEdge: .bottom) {
                                Button {
                                    if  record.revertToPastChange(fieldId: selectedFieldChange, pastChange: selectedPastChange!, revertToAll: false, modelContext: modelContext) {
                                        modelContext.delete(selectedPastChange!)
                                        selectedPastChange = nil
                                    }
                                    initialProperties[selectedFieldChange!] = value
                                } label: {
                                    HStack {
                                        Image(systemName: "arrowshape.turn.up.backward.fill")
                                        Text("Revert To Field")
                                    }
                                }
                                .buttonStyle(.borderless)
                                .padding(5)

                            }
                        }
                    }
                }
                
            }
            .onAppear {
                if !isAdding {
                    initialProperties = record.properties
                }
            }
            .alert(isPresented: $showRevertAlert) {
                if isRevertingVersion {
                    Alert(
                        title: Text("Revert To Version \(selectedPastChange!.reason)"),
                        message: Text("Are you sure you want to revert all your changes to this version. You can't undo this action."),
                        primaryButton: .destructive(Text("Revert")) {
                            record.revertToPastChange(fieldId: nil, pastChange: selectedPastChange!, revertToAll: true, modelContext: modelContext)
                            selectedPastChange = nil
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
        .toolbar {
            toolbarContent()
        }
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
        if selectedPastChange != nil {
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
    
    func getUIElements() -> [DynamicUIElement] {
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
                return []
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

