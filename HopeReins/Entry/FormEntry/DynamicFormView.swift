//
//  DynamicFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/20/24.
//

import SwiftUI
import SwiftData

struct DynamicFormView: View  {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @StateObject var uiManagement: UIManagement
    @State var isAdding: Bool
    @State var text: String = ""
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
            VStack(alignment: .leading) {
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
                    if !isAdding {
                        PastChangeSelectionView(showPastChanges: $showPastChanges, selectedVersion: $selectedVersion, pastVersions: uiManagement.record.versions)
                    }
                }
                .padding([.top, .horizontal])
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
                        ReviewChangesView(uiManagement: uiManagement, changeDescriptions: changeDescriptions)
                    })
                    .padding()
                }
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
            ToolbarItem(placement: .automatic) {
                Button {
                    uiManagement.addFile(modelContext: modelContext)
                    dismiss()
                } label: {
                    HStack {
                        Text("Add File")
                        Image(systemName: "doc.badge.plus")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        } else if !changeDescriptions.isEmpty {
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
            ToolbarItem(placement: .cancellationAction) {
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

}
