//
//  ReviewChangesView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/2/24.
//

import SwiftUI

struct ReviewChangesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @ObservedObject var uiManagement: UIManagement
    @State var changeDescriptions: [ChangeDescription]
    @State var reason: String = ""
    var body: some View {
        ScrollView {
            VStack {
                BasicTextField(title: "Title For Change(s)", text: $reason)
                HStack {
                    Text("Property")
                        .frame(width: 100, alignment: .center)
                    Divider()
                    Spacer()
                    Text("Original Value")
                        .frame(width: 100, alignment: .center)
                    Divider()
                    Spacer()
                    Text("New Value")
                        .frame(width: 100, alignment: .center)
                }
                .bold()
                Divider()
                ForEach(Array(changeDescriptions.enumerated()), id: \.element.self) { index, changeDescription in
                    HStack {
                        Text("\(changeDescription.displayName.isEmpty ? changeDescription.id : changeDescription.displayName)")
                            .frame(width: 100, alignment: .center)
                            .padding(.trailing, 8)
                        Text("\(changeDescription.oldValue.isEmpty ? "Default Value" : changeDescription.oldValue)")
                            .foregroundStyle(.red)
                            .frame(width: 100, alignment: .center)
                            .padding(.trailing, 8)
                        Text("\(changeDescription.value)")
                            .foregroundStyle(.green)
                            .frame(width: 100, alignment: .center)
                    }
                    if index < changeDescriptions.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
            .frame(maxWidth: 375)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    uiManagement.record.properties = uiManagement.modifiedProperties
                    uiManagement.record.addPastChanges(reason: reason, changes: changeDescriptions, author: uiManagement.username, modelContext: modelContext)
                    dismiss()
                }, label: {
                    Text("Apply Changes")
                })
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                })
            }
        }
    }
}
