//
//  SectionElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI

struct SectionElement: View {
    @State var wrappedElement: DynamicUIElementWrapper
    @Binding var selectedVersion: Version?
    @Binding var selectedFieldChange: String?
    @ObservedObject var uiManagement: UIManagement
    var changeDescriptions: [ChangeDescription]
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack {
                    if let changes = selectedVersion?.changes, changes.contains(where: { $0.fieldID == wrappedElement.id }) {
                        Button(action: {
                            selectedFieldChange = wrappedElement.id
                        }, label: {
                            HStack {
                                Text("Changes (\(changes.filter { $0.fieldID == wrappedElement.id }.count))")
                                Image(systemName: "chevron.right.circle.fill")
                            }
                        })
                        .popover(isPresented: Binding<Bool>(
                            get: { self.selectedFieldChange == wrappedElement.id },
                            set: { show in if !show { self.selectedFieldChange = nil } }
                        ), attachmentAnchor: .point(UnitPoint.top), arrowEdge: .top) {
                            FormSectionContent(wrappedElement: wrappedElement, changeDescriptions: changeDescriptions, selectedVersion: $selectedVersion, selectedFieldChange: $selectedFieldChange, uiManagement: uiManagement)
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
        }
    }
}
