//
//  RidingChangeView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/28/23.
//

import SwiftUI

struct RidingChangeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    var lessonPlan: RidingLessonPlan
    @Binding var modifiedProperties: RidingLessonProperties
    @Binding var fileName: String
    var change: PastChangeRidingLessonPlan
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(change.title)
                    .italic()
                Spacer()
                Text("Modified By: \(change.author) \(change.date.formatted())")
                    .italic()
            }
            .font(.caption)
            Divider()
            Text(change.changeDescription)
                .font(.caption2)
            HStack {
                Spacer()
                Button("Revert To This Version") {
                    do {
                        revertLessonPlan(otherProperties: change.properties, otherFileName: change.fileName)
                        lessonPlan.pastChanges.removeAll(where: { element in
                            return element.date == change.date
                        })
                        modelContext.delete(change)
                        try modelContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .font(.caption)
            }
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color("darkBrown").gradient)
        }
    }
    func revertLessonPlan(otherProperties: RidingLessonProperties, otherFileName: String) {
        let oldProperties = lessonPlan.properties
        lessonPlan.properties = otherProperties
        modelContext.delete(oldProperties)
        lessonPlan.medicalRecordFile.fileName = otherFileName
        fileName = otherFileName
        modifiedProperties = RidingLessonProperties(other: lessonPlan.properties)
        try? modelContext.save()
    }
}


struct ChangeView<Record: ChangeRecordable & Revertible, Change: SnapshotChange>: View where Record.ChangeType == Change, Record.PropertiesType == Change.PropertiesType {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext

    var record: Record?
    @Binding var fileName: String
    @Binding var modifiedProperties: Record.PropertiesType
    var onRevert: () -> Void
    var change: Change

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(change.title)
                    .italic()
                Spacer()
                Text("Modified By: \(change.author) \(change.date.formatted())")
                    .italic()
            }
            .font(.caption)
            Divider()
            Text(change.changeDescription)
                .font(.caption2)
            HStack {
                Spacer()
                Button("Revert To This Version") {
                    revertToVersion()
                }
                .font(.caption)
            }
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color("darkBrown").gradient)
        }
    }

    private func revertToVersion() {
        guard var record = record else { return }
        record.revertToProperties(change.properties, fileName: fileName, modelContext: modelContext)
        fileName = change.fileName
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        onRevert()
        modifiedProperties = Record.PropertiesType(other: record.properties)
    }
}

