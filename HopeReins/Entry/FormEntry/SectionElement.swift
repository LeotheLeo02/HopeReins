//
//  SectionElement.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI

struct SectionElement: View {
    @Environment(\.isEditable) var isEditable
    @State var wrappedElement: DynamicUIElementWrapper
    @Binding var selectedVersion: Version?
    @Binding var selectedFieldChange: String?
    @ObservedObject var uiManagement: UIManagement
    @State var text: String = ""
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack {
                    if let changes = selectedVersion?.changes, changes.contains(where: { $0.fieldID == wrappedElement.id }) {
                        Button(action: {
                            selectedFieldChange = wrappedElement.id
                        }, label: {
                            HStack {
                                Image(systemName: "chevron.up.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        })
                        .buttonStyle(.plain)
                        .popover(isPresented: Binding<Bool>(
                            get: { self.selectedFieldChange == wrappedElement.id },
                            set: { show in if !show { self.selectedFieldChange = nil } }
                        )) {
                            FormSectionContent(wrappedElement: wrappedElement, selectedVersion: $selectedVersion, selectedFieldChange: $selectedFieldChange, uiManagement: uiManagement)
                        }
                    }
                    
                    DynamicElementView(wrappedElement: wrappedElement.element)
                    
                }
                if uiManagement.changeDescriptions.first(where: { $0.id == wrappedElement.id }) != nil {
                    Text("Modified")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
