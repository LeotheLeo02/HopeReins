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
                    ChangeDescriptionView(changeDescription: changeDescription)
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

struct ChangeDescriptionView: View {
    var changeDescription: ChangeDescription
    var body: some View {
        HStack {
            Text("\(changeDescription.displayName.isEmpty ? changeDescription.id : changeDescription.displayName)")
                .frame(width: 100, alignment: .center)
                .padding(.trailing, 8)
            ChangeFieldView(value: changeDescription.oldValue, isOldChangeLabel: true)
            ChangeFieldView(value: changeDescription.value, isOldChangeLabel: false)
        }
    }
}

struct ChangeFieldView: View {
    var value: CodableValue
    var isOldChangeLabel: Bool
    
    var body: some View {
        switch value {
        case .int(let int):
            textView(text: String(int))
        case .string(let string):
            textView(text: string)
        case .double(let double):
            textView(text: String(double))
        case .bool(let bool):
            textView(text: String(bool))
        case .date(let date):
            textView(text: formatDate(date: date))
        case .data(let data):
            FilePreview(data: data, size: 20)
                .frame(width: 100, alignment: .center)
                .padding(.trailing, 8)
        }
    }

    private func textView(text: String) -> some View {
        Text(text.isEmpty ? "Default Value" : text)
            .foregroundStyle(isOldChangeLabel ? .red : .green)
            .frame(width: 100, alignment: .center)
            .padding(.trailing, 8)
    }

    private func formatDate(date: Date) -> String {
        // Format your date to string using DateFormatter or similar
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

