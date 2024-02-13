//
//  FormSectionContent.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/12/24.
//

import SwiftUI

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

