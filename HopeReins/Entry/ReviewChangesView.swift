//
//  ReviewChangesLessonPlan.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/28/23.
//

import SwiftUI

struct ReviewChangesView<Record: ChangeRecordable & Revertible, Change: SnapshotChange>: View where Record.ChangeType == Change, Record.PropertiesType == Change.PropertiesType {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var titleForChange: String = ""
    @Binding var modifiedProperties: Record.PropertiesType
    var record: Record?
    var changeDescriptions: [String]
    var username: String
    var oldFileName: String
    var fileName: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TextField("Title of Changes...", text: $titleForChange)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 5)
                Text("Changes:")
                    .bold()
                Divider()
                ForEach(changeDescriptions, id: \.self) { descrip in
                    Text(descrip)
                        .font(.footnote)
                    if descrip != changeDescriptions.last {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save Changes") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .disabled(titleForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func saveChanges() {
        guard var record = record else { return }
        do {
            let newChange = Change(properties: record.properties, fileName: oldFileName, title: titleForChange, changeDescriptions: changeDescriptions, author: username, date: .now)
            record.addChangeRecord(newChange, modelContext: modelContext)
            try modelContext.save()
            record.revertToProperties(modifiedProperties, fileName: fileName, modelContext: modelContext)
            try modelContext.save()
            modifiedProperties = Record.PropertiesType(other: record.properties)
            dismiss()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
