//
//  ReviewChangesLessonPlan.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 12/28/23.
//

import SwiftUI

struct ReviewChangesLessonPlan: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var titleForChange: String = ""
    @Binding var modifiedProperties: RidingLessonProperties
    var lessonPlan: RidingLessonPlan?
    var description: String
    var username: String
    var fileName: String
    var body: some View {
        VStack {
            TextField("Title of Change...", text: $titleForChange, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Text(description)
                .bold()
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                Button("Save Changes") {
                    do {
                        let newFileChange = PastChangeRidingLessonPlan(properties: lessonPlan!.properties, fileName: lessonPlan!.medicalRecordFile.fileName, title: titleForChange, changeDescription: description, author: username, date: .now)
                        lessonPlan!.pastChanges.append(newFileChange)
                        lessonPlan!.medicalRecordFile.fileName = fileName
                        lessonPlan!.properties = modifiedProperties
                        try modelContext.save()
                        modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan!.properties)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(titleForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }
}
