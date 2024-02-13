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
    @State var wrappedElement: DynamicUIElementWrapper
    var changeDescriptions: [ChangeDescription]
    @Binding var selectedVersion: Version?
    @Binding var selectedFieldChange: String?
    @ObservedObject var uiManagement: UIManagement
    
    
    var body: some View {
        ScrollView {
            VStack {
                if selectedVersion != nil {
                    ForEach(selectedVersion!.changes.filter { $0.fieldID == wrappedElement.id }, id: \.self) { change in
                        HStack {
                            OriginalValueView(id: wrappedElement.id, value: change.propertyChange, displayName: change.displayName, onTap: {
                                selectedFieldChange = wrappedElement.id
                            })
                            Button(action: {
                                if  uiManagement.record.revertToPastChange(fieldId: selectedFieldChange, version: selectedVersion!, revertToAll: false, modelContext: modelContext) {
                                    uiManagement.record.versions.removeAll{ $0 == selectedVersion! }
                                    modelContext.delete(selectedVersion!)
                                    selectedVersion = nil
                                }
                                print(change.propertyChange)
                                uiManagement.assignFieldValue(fieldID: selectedFieldChange!, value: CodableValue.string(change.propertyChange))
                                uiManagement.record.properties[selectedFieldChange!] = CodableValue.string(change.propertyChange)
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
            .padding(5)
        }
    }
}


struct OriginalValueView: View {
    var id: String
    var value: String
    var displayName: String
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Original Value:")
                .foregroundStyle(.gray)
                .font(.caption.bold())
            Text(displayName)
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
    @StateObject var uiManagement: UIManagement
    @State var isAdding: Bool
    @State var text: String = ""
    @State var patient: Patient?
    var username: String
    var changeDescriptions: [ChangeDescription] {
        return uiManagement.record.compareProperties(with: uiManagement.modifiedProperties)
    }
    @State var showPastChanges: Bool = false
    @State var selectedVersion: Version?
    @State var selectedFieldChange: String?
    @State var reviewChanges: Bool = false
    @State var isRevertingVersion: Bool = false
    @State var showRevertAlert: Bool = false
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    if !isAdding {
                        HStack {
                            Spacer()
                            PastChangeSelectionView(showPastChanges: $showPastChanges, selectedVersion: $selectedVersion, pastVersions: uiManagement.record.versions)
                        }
                    }
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
                                uiManagement.record.revertToPastChange(fieldId: nil, version: selectedVersion!, revertToAll: true, modelContext: modelContext)
                                selectedVersion = nil
                                uiManagement.modifiedProperties = uiManagement.record.properties
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
                    ReviewChangesView(uiManagement: uiManagement, changeDescriptions: changeDescriptions , username: username)
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
            SectionElement(wrappedElement: wrappedElement, selectedVersion: $selectedVersion, selectedFieldChange: $selectedFieldChange, uiManagement: uiManagement, changeDescriptions: changeDescriptions)
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
    
    func addFile() {
        let newDigitalSig = DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now)
        modelContext.insert(newDigitalSig)
        uiManagement.record.digitalSignature = newDigitalSig
        newDigitalSig.created(by: username)
        uiManagement.record.properties = uiManagement.modifiedProperties
        print(uiManagement.modifiedProperties)
        modelContext.insert(uiManagement.record)
       try? modelContext.save()
    }

}


class UIManagement: ObservableObject {
    @Published var modifiedProperties: [String : CodableValue]
    @Published var dynamicUIElements: [FormSection] = []
    @Published var record: MedicalRecordFile
    @Published var forceUpdateToggle: Bool = false
    
    init(modifiedProperties: [String : CodableValue], record: MedicalRecordFile) {
        self.modifiedProperties = modifiedProperties
        self.record = record
        self.dynamicUIElements = getUIElements()
    }
    
    
    
    public func getUIElements() -> [FormSection] {
        if isUploadFile(fileType: record.fileType) {
            return getUploadFile()
        }

        if let type = RidingFormType(rawValue: record.fileType) {
            switch type {
            case .ridingLessonPlan:
                return getRidingLessonPlan()
            default:
                return []
            }
        }

        if let type = PhysicalTherabyFormType(rawValue: record.fileType) {
            switch type {
            case .evaluation:
                return getEvaluation()
            default:
                return []
            }
        }

        return []
    }
    
    func getUploadFile() -> [FormSection] {
        let uiElements: [FormSection] = [
            FormSection(title: "Upload File", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .fileUploadButton(title: "File Data", dataValue: dataBinding(for: "File Data"))
            ])
        ]
        return uiElements
    }
    
    private func stringBinding(for key: String, defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: {
                if self.modifiedProperties[key] == nil {
                    self.modifiedProperties[key] = .string(defaultValue)
                }
                return self.modifiedProperties[key]?.stringValue ?? defaultValue
            },
            set: { self.modifiedProperties[key] = .string($0) }
        )
    }

    private func intBinding(for key: String, defaultValue: Int = 0) -> Binding<Int> {
        Binding<Int>(
            get: { self.modifiedProperties[key]?.intValue ?? defaultValue },
            set: { self.modifiedProperties[key] = .int($0) }
        )
    }


    private func dataBinding(for key: String, defaultValue: Data = .init()) -> Binding<Data?> {
        Binding<Data?>(
            get: { self.modifiedProperties[key]?.dataValue ?? defaultValue },
            set: { self.modifiedProperties[key] = .data($0!) }
        )
    }


    
    private func dateBinding(for key: String, defaultValue: Date = .now) -> Binding<Date> {
        Binding<Date>(
            get: { self.modifiedProperties[key]?.dateValue ?? defaultValue },
            set: { self.modifiedProperties[key] = .date($0) }
        )
    }
    func getRidingLessonPlan() -> [FormSection] {
        let uiElements : [FormSection] = [
            FormSection(title: "Riding Lesson Plan", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .datePicker(title: "Date", hourAndMinute: false, binding: dateBinding(for: "Date")),
                .textField(title: "Objective", binding: stringBinding(for: "Objective")),
                .textField(title: "Preparation", binding: stringBinding(for: "Preparation")),
                .textField(title: "Content", binding: stringBinding(for: "Content")),
                .textField(title: "Summary", binding: stringBinding(for: "Summary")),
                .textField(title: "Goals", binding: stringBinding(for: "Goals"))
            ])
        ]
        return uiElements
    }
    
    func getEvaluation() -> [FormSection]{
        let uiElements: [FormSection] = [
            FormSection(title: "File Name", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name"))
            ]),
            FormSection(title: "Personal Info", elements: [
                .textField(title: "Education Level", binding: stringBinding(for: "Education Level")),
                .textField(title: "Extracurricular", binding: stringBinding(for: "Extracurricular")),
                .textField(title: "Home Barrier", binding: stringBinding(for: "Home Barrier")),
                .textField(title: "Past medical and/or rehab history", binding: stringBinding(for: "Past medical and/or rehab history")),
                .textField(title: "Surgical History", binding: stringBinding(for: "Surgical History")),
                .textField(title: "Medications", binding: stringBinding(for: "Medications")),
                .textField(title: "Vision", binding: stringBinding(for: "Vision")),
                .textField(title: "Hearing", binding: stringBinding(for: "Hearing")),
                .textField(title: "Speech/Communications", binding: stringBinding(for: "Speech Communications")),
                .textField(title: "Seizures", binding: stringBinding(for: "Seizures")),
            ]),
            FormSection(title: "A/Prom", elements: [
                .textField(title: "A Upper Extremity", binding: stringBinding(for: "A Upper Extremity")),
                .textField(title: "A Lower Extremity", binding: stringBinding(for: "A Lower Extremity")),
            ]),
            FormSection(title: "Strength", elements: [
                .textField(title: "S Upper Extremities", binding: stringBinding(for: "S Upper Extremity")),
                .textField(title: "S Lower Extremities", binding: stringBinding(for: "S Lower Extremity")),
                .textField(title: "Trunk Musculature", binding: stringBinding(for: "Trunk Musculature")),
                .leRomTable(title: "LE Strength and ROM Table", combinedString: stringBinding(for: "LE Strength and ROM Table")),
                .singleSelectDescription(title: "SS Pain", titles: ["Pain"], labels: ["No", "Yes"], combinedString: stringBinding(for: "SS Pain"), isDescription: true)
            ]),
            FormSection(title: "Neurological Functioning", elements: [
                .singleSelectDescription(title: "SS Tone", titles: ["Tone"], labels: ["WNL", "Hypotonic", "Fluctuating", "NT"], combinedString: stringBinding(for: "SS Tone"), isDescription: true),
                .singleSelectDescription(title: "SS Sensation", titles: ["Sensation"], labels: ["WNL", "Hyposensitive", "Hypersensitive", "Absent", "NT"], combinedString: stringBinding(for: "SS Sensation"), isDescription: true),
                .singleSelectDescription(title: "SS Reflexes", titles: ["Reflexes"], labels: ["WNL", "Hyporesponse", "Hyperresponse", "Deficits", "NT"], combinedString: stringBinding(for: "SS Reflexes"), isDescription: true),
                .singleSelectDescription(title: "SS Protective to Praxis", titles: ["Protective Extension", "Righting", "Equilibrium", "Praxis"], labels: ["WNL", "Deficient", "Emerging", "Absent", "NT"], combinedString: stringBinding(for: "SS Protective to Praxis"), isDescription: true),
                .textField(title: "Neurological Notes", binding: stringBinding(for: "Neurological Notes")),
                .textField(title: "Toileting", binding: stringBinding(for: "Toileting")),
            ]),
            FormSection(title: "Coordination", elements: [
                .singleSelectDescription(title: "SS Coordination Extremities", titles: ["Upper Extremities", "Lower Extremities"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Coordination Extremities"), isDescription: true),
                .textField(title: "Coordination Notes", binding: stringBinding(for: "Coordination Notes")),
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Endurance", elements: [
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Balance", elements: [
                .singleSelectDescription(title: "SS Balance", titles: ["Sit Static", "Sit Dynamic", "Stance Static", "Stance Dynamic"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Balance"), isDescription: true),
                .textField(title: "Balance Notes", binding: stringBinding(for: "Balance Notes"))
            ]),
            FormSection(title: "Current Equipment", elements: [
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Current Equipment"), labels: ["Orthotics", "Wheelchair", "Bath Equipment", "Glasses", "Augmentative Communication Device", "Walking Device", "Training Aids", "Other"], title: "MST Current Equipment")
            ]),
            FormSection(title: "Mobility", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Locomotion"), labels: ["Ambulation", "Non-Mobile", "Wheel Chair"], title: "MSO Locomotion"),
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Assistance & Distance"), labels: ["Independent", "Supervision for safety", "Minimal", "Maximal", "SBA", "CGA", "Moderate", "Dependent"], title: "MST Assistance & Distance"),
                .singleSelectDescription(title: "SS Surfaces", titles: ["Level", "Ramp", "Curb", "Stairs", "Uneven terrain"], labels: ["Independent", "SBA", "CGA", "Min", "Mod", "Max"], combinedString: stringBinding(for: "SS Surfaces"), isDescription: true),
                .textField(title: "Gait Deviations", binding: stringBinding(for: "Gait Deviations")),
                .textField(title: "Wheelchair Skills", binding: stringBinding(for: "Wheelchair Skills"))
            ]),
            FormSection(title: "Transfers", elements: [
                .textField(title: "Supine to Sit", binding: stringBinding(for: "Supine to Sit")),
                .textField(title: "Sit to Stand", binding: stringBinding(for: "Sit to Stand")),
                .textField(title: "Stand pivot", binding: stringBinding(for: "Stand pivot")),
                .textField(title: "Floor to stand", binding: stringBinding(for: "Floor to stand")),
                .textField(title: "Bed mobility", binding: stringBinding(for: "Bed mobility")),
                .textField(title: "Army Crawling", binding: stringBinding(for: "Army Crawling")),
                .textField(title: "Creeping", binding: stringBinding(for: "Creeping"))
            ]),
            FormSection(title: "Transitions", elements: [
                .textField(title: "Supine/prone", binding: stringBinding(for: "Supined/prone")),
                .textField(title: "Quadruped", binding: stringBinding(for: "Quadruped")),
                .textField(title: "Tall kneel", binding: stringBinding(for: "Tall kneel")),
                .textField(title: "Half kneel", binding: stringBinding(for: "Half kneel")),
                .textField(title: "Side Sitting", binding: stringBinding(for: "Side Sitting")),
                .textField(title: "Tailor sitting", binding: stringBinding(for: "Tailor sitting")),
                .textField(title: "Other", binding: stringBinding(for: "Transitions Other"))
            ]),
            FormSection(title: "Posture/Body Mechanics/Ergonomics", elements: [
                .singleSelectDescription(title: "SS Posture/Body Mechanics/Ergonomics", titles: ["Posture/Body Mechanics/Ergonomics"], labels: ["WNL", "Patient demonstrated the following deviations"], combinedString: stringBinding(for: "SS Posture/Body Mechanics/Ergonomics"), isDescription: true)
            ]),
            FormSection(title: "Gross Motor Developmental Status", elements: [
                .textField(title: "Chronological Age", binding: stringBinding(for: "Chronological Age")),
                .textField(title: "Approximate Developmental Age", binding: stringBinding(for: "Approximate Developmental Age")),
                .textField(title: "Special Testing/Standardized Testing", binding: stringBinding(for: "Special Testing/Standardized Testing"))
            ]),
            FormSection(title: "Primary Problems/Deficits Include", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Primary Problems/Deficits Include"), labels: ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"], title: "MSO Primary Problems/Deficits Include")
            ]),
            FormSection(title: "Daily Note", elements: [
                .dailyNoteTable(title: "Daily Note", combinedString: stringBinding(for: "Daily Note"))
            ])

        ]

        return uiElements
    }
    func assignFieldValue(fieldID: String, value: CodableValue) {
        print("Before updating: \(modifiedProperties[fieldID])")
        modifiedProperties[fieldID] = value
        print("After updating: \(modifiedProperties[fieldID])")
    }


}
