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
        modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan.properties)
        try? modelContext.save()
    }
}
