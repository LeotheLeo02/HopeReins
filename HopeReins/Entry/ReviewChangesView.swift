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
    @Binding var oldFileName: String
    @Binding var fileName: String
    
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
            oldFileName = fileName
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
    @State var showChanges: Bool = false
    @State var changeDescription: String = ""
    @State var modifiedProperties: Record.PropertiesType
    @State var pastChangesExpanded: Bool = false
    @State var initialFileName: String
    @State var fileName: String = ""
    @State var record: Record?
    var username: String
    var patient: Patient?
    @State var changeDescripions: [String] = []
    private var changeDescriptions: [String] {

        let oldFileName = initialFileName
        let newFileName = fileName

        let fileNameChange = (oldFileName != newFileName) ?
        "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\"" : ""

        guard let oldProperties = record?.properties as? Reflectable else { return [] }

        var totalChanges = oldProperties.compareProperties(with: modifiedProperties)

        if !fileNameChange.isEmpty {
            totalChanges.append(fileNameChange)
        }

        return totalChanges
    }
    
    var ridingFormType: RidingFormType?
    var phyiscalFormType: PhysicalTherabyFormType?


    @ViewBuilder
    private var formView: some View {
        if let _ = modifiedProperties as? RidingLessonProperties {
            RidingLessonPlanFormView(modifiedProperties: Binding(get: {
                modifiedProperties as! RidingLessonProperties
            }, set: {
                modifiedProperties = $0 as! Record.PropertiesType
            }), fileName: $fileName)
        }
        else if let uploadFileProperties = modifiedProperties as? UploadFileProperties {
            UploadFileFormView(modifiedProperties: Binding(get: {
                modifiedProperties as! UploadFileProperties
            }, set: {
                modifiedProperties = $0 as! Record.PropertiesType
            }), fileName: $fileName)
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if record != nil {
                    PastChangesView(modifiedProperties: $modifiedProperties, record: record, initialFileName: $initialFileName, fileName: $fileName)
                }
                formView
                
            }
            .padding()
        }
        .environment(\.isEditable, isEditable)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text((record == nil || !changeDescription.isEmpty) ? "Cancel" : "Done")
                }
            }
            if record == nil {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        addFile()
                        try? modelContext.save()
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                    .buttonStyle(.borderedProminent)
                }
            } else if !changeDescriptions.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showChanges.toggle()
                    } label: {
                        Text("Apply Changes")
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
            }
        }
        .sheet(isPresented: $showChanges) {
            ReviewChangesView(modifiedProperties: $modifiedProperties, record: record, changeDescriptions: changeDescriptions, username: username, oldFileName: $initialFileName, fileName: $fileName)
        }
        .onAppear {
            fileName = initialFileName
        }
    }
    
    func addFile() {
        if let record = record as? RidingLessonPlan {
            let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now))
            let properties = RidingLessonProperties(other: modifiedProperties as! HopeReinsSchemaV2.RidingLessonProperties)
            modelContext.insert(properties)
            try? modelContext.save()
            let ridingLesson = RidingLessonPlan(medicalRecordFile: medicalRecordFile, properties: properties)
            modelContext.insert(ridingLesson)
            try? modelContext.save()
        } else  if let uploadFileProperties = modifiedProperties as? UploadFileProperties {
            var fileType: String = ""
            if let type = ridingFormType {
                if type == .releaseStatement {
                    fileType = type.rawValue
                } else if type == .coverLetter {
                    fileType = type.rawValue
                } else if type == .updateCoverLetter {
                    fileType = type.rawValue
                }
            } else {
                if let type = phyiscalFormType {
                    if type == .referral {
                        fileType = type.rawValue
                    }
                }
            }
            let digitalSignature = DigitalSignature(author: username, modification: FileModification.added.rawValue, dateModified: .now)
            modelContext.insert(digitalSignature)
            let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: fileType, digitalSignature: digitalSignature)
            modelContext.insert(medicalRecordFile)
            let properties = UploadFileProperties(other: modifiedProperties as! HopeReinsSchemaV2.UploadFileProperties)
            modelContext.insert(properties)
            let dataFile = UploadFile(medicalRecordFile: medicalRecordFile, properties: properties)
            modelContext.insert(dataFile)
            try? modelContext.save()
        }
    }
}
import SwiftData

struct UploadFileFormView: View {
    @Binding var modifiedProperties: UploadFileProperties
    @Binding var fileName: String
    var body: some View {
        BasicTextField(title: "File Name...", text: $fileName)
        FileUploadButton(properties: $modifiedProperties)
    }
}


struct RidingLessonPlanFormView: View {
    @Binding var modifiedProperties: RidingLessonProperties
    @Binding var fileName: String
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    
    var body: some View {
        BasicTextField(title: "File Name", text: $fileName)
        
        CustomSectionHeader(title: "Instructor")
        Picker(selection: $modifiedProperties.instructorName) {
            ForEach(instructors) { user in
                Text(user.username)
                    .tag(user.username)
            }
        } label: {
            Text("Instructor: \(modifiedProperties.instructorName)")
        }
        .labelsHidden()
        
        DateSelection(title: "Date of Lesson", hourAndMinute: true, date: $modifiedProperties.date)
        
        BasicTextField(title: "Objective of the Lesson:", text: $modifiedProperties.objective)
        
        BasicTextField(title: "Teacher preparation/Equipment needs:", text: $modifiedProperties.preparation)
        
        BasicTextField(title: "Lesson content/Procedure:", text: $modifiedProperties.content)
        
        BasicTextField(title: "Summary and evaluation of the lesson:", text: $modifiedProperties.summary)
        
        BasicTextField(title: "Goals for the next lesson:", text: $modifiedProperties.goals)
    }
}

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
            CustomSectionHeader(title: "Past Changes")
        }
    }
    func revertToChange(change: any SnapshotChange) {
        if let change = change as? PastChangeRidingLessonPlan {
            let objectID = change.persistentModelID
            let objectInContext = modelContext.model(for: objectID)
            record!.pastChanges.removeAll { $0.date == change.date }
            modelContext.delete(objectInContext)
            do {
                try modelContext.save()
            } catch {
                print("Error saving context \(error)")
            }
        } else if let change = change as? FileChange {
            let objectID = change.persistentModelID
            let objectInContext = modelContext.model(for: objectID)
            record!.pastChanges.removeAll { $0.date == change.date }
            modelContext.delete(objectInContext)
            do {
                try modelContext.save()
            } catch {
                print("Error saving context \(error)")
            }
        }
        initialFileName = fileName
    }
}
