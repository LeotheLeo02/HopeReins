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
                ForEach(record?.pastChanges ?? []) { change  in
                    ChangeView(record: record, fileName: .constant(""), modifiedProperties: $modifiedProperties, onRevert: {}, change: change)
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


struct EditingView<Record: ChangeRecordable & Revertible>: View where Record.PropertiesType: Reflectable {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.isEditable) var isEditable
    @State var fileName: String = ""
    @State var properties: Record.PropertiesType
    @State var pastChangesExpanded: Bool = false
    var record: Record?
    var username: String
    var patient: Patient?

    @ViewBuilder
    private var formView: some View {
        if let ridingLessonProperties = properties as? RidingLessonProperties, let initialProperties = record?.properties as? RidingLessonProperties {
            RidingLessonPlanFormView(initialProperties: initialProperties, fileName: $fileName, properties: Binding(get: {
                ridingLessonProperties
            }, set: {
                properties = $0 as! Record.PropertiesType
            }))
        } else if let uploadFileProperties = properties as? UploadFileProperties {
            UploadFileFormView(fileName: $fileName, properties: Binding(get: {
                uploadFileProperties
            }, set: {
                properties = $0 as! Record.PropertiesType
            }))
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if record != nil {
                    PastChangesView(modifiedProperties: $properties, record: record, fileName: fileName)
                }
            }
        }
    }
}
import SwiftData

struct UploadFileFormView: View {
    @Binding var fileName: String
    @Binding var properties: UploadFileProperties
    var body: some View {
        BasicTextField(title: "File Name...", text: $fileName)
        FileUploadButton(properties: $properties)
    }
}


struct RidingLessonPlanFormView: View {
    @State var initialProperties: RidingLessonProperties
    @Binding var fileName: String
    @Binding var properties: RidingLessonProperties
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    
    private var changeDescriptions: [String] {
        
//        let oldFileName = lessonPlan?.medicalRecordFile.fileName ?? "nil"
        let newFileName = fileName
//        
//        let fileNameChange = (oldFileName != newFileName) ?
//        "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\"" : ""
        
        var totalChanges = RidingLessonProperties.compareProperties(old: initialProperties, new: properties)
//
//        if !fileNameChange.isEmpty {
//            totalChanges.append(fileNameChange)
//        }
        
        return totalChanges
    }
    var body: some View {
        BasicTextField(title: "File Name", text: $fileName)
        
        CustomSectionHeader(title: "Instructor")
        Picker(selection: $properties.instructorName) {
            ForEach(instructors) { user in
                Text(user.username)
                    .tag(user.username)
            }
        } label: {
            Text("Instructor: \(properties.instructorName)")
        }
        .labelsHidden()
        
        DateSelection(title: "Date of Lesson", hourAndMinute: true, date: $properties.date)
        
        BasicTextField(title: "Objective of the Lesson:", text: $properties.objective)
        
        BasicTextField(title: "Teacher preparation/Equipment needs:", text: $properties.preparation)
        
        BasicTextField(title: "Lesson content/Procedure:", text: $properties.content)
        
        BasicTextField(title: "Summary and evaluation of the lesson:", text: $properties.summary)
        
        BasicTextField(title: "Goals for the next lesson:", text: $properties.goals)
    }
}

struct PastChangesView<Record: ChangeRecordable & Revertible> : View where Record.PropertiesType: Reflectable {
    @Binding var modifiedProperties: Record.PropertiesType
    var record: Record?
    @State var fileName: String

    var body: some View {
        DisclosureGroup {
            ForEach(record?.pastChanges ?? [], id: \.id) { change in
                ChangeView(record: record, fileName: $fileName, modifiedProperties: $modifiedProperties, onRevert: {}, change: change)
            }
        } label: {
            CustomSectionHeader(title: "Past Changes")
        }
    }
}
