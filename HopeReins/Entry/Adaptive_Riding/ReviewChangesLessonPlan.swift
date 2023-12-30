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
    var description: String
    var username: String
    var oldFileName: String
    var fileName: String
    
    var body: some View {
        VStack {
            TextField("Title of Change...", text: $titleForChange)
                .textFieldStyle(.roundedBorder)
            Text(description)
                .bold()
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Save Changes") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .disabled(titleForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }
    
    private func saveChanges() {
        guard var record = record else { return }
        do {
            let newChange = Change(properties: record.properties, fileName: oldFileName, title: titleForChange, changeDescription: description, author: username, date: .now)
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
