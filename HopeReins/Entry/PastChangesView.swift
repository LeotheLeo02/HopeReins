//
//  PastChangesView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/17/24.
//

import SwiftUI

struct PastChangesView<Record: ChangeRecordable & Revertible> : View where Record.PropertiesType: Reflectable {
    @Environment(\.modelContext) var modelContext
    @Binding var modifiedProperties: Record.PropertiesType
    @State var record: Record?
    @Binding var initialFileName: String
    @Binding var fileName: String

    var body: some View {
        DisclosureGroup {
            ForEach(record?.pastChanges ?? [], id: \.id) { change in
                ChangeView(record: record, fileName: $fileName, modifiedProperties: $modifiedProperties, onRevert: {
                    revertToChange(change: change)
                }, change: change)
            }
        } label: {
            Label("Past Changes", systemImage: "\(record!.pastChanges.count).circle.fill")
                .font(.callout.bold())
        }
    }
    func revertToChange(change: any SnapshotChange) {
        let objectID = change.persistentModelID
        let objectInContext = modelContext.model(for: objectID)
        record!.pastChanges.removeAll { $0.date == change.date }
        modelContext.delete(objectInContext)
        do {
            try modelContext.save()
        } catch {
            print("Error saving context \(error)")
        }
        initialFileName = fileName
    }
}
