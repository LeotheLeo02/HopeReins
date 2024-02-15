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
            VStack {
                if selectedVersion != nil {
                    ForEach(selectedVersion!.changes.filter { $0.fieldID == wrappedElement.id }, id: \.self) { change in
                        HStack {
                            DynamicElementView(wrappedElement: wrappedElement.element, change: change)
                            Button(action: {
                                if uiManagement.revertToPastVersion(selectedVersion: selectedVersion!, selectedFieldChange: selectedFieldChange, change: change, revertToAll: false, modelContext: modelContext) {
                                    selectedVersion = nil
                                }
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
            .frame(minWidth: 200, maxWidth: .infinity)
            .padding(5)
    }
}

