//
//  RidingLessonPlanView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI
import SwiftData

struct RidingLessonPlanView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var fileName: String = ""
    @State var modifiedProperties: RidingLessonProperties = RidingLessonProperties()
    @State var reasonForChange: String = ""
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var lessonPlan: RidingLessonPlan?
    var username: String
    var patient: Patient?
    var description: String {
        var description = ""
        if lessonPlan?.medicalRecordFile.fileName != fileName {
            description += "Changed File Name "
        }
        
        if lessonPlan?.properties.content != modifiedProperties.content {
            description += "Changed Content "
        }
        if lessonPlan?.properties.date != modifiedProperties.date {
            description += "Changed Date "
        }
        if lessonPlan?.properties.goals != modifiedProperties.goals {
            description += "Changed Goals "
        }
        if lessonPlan?.properties.instructorName != modifiedProperties.instructorName {
            description += "Changed Instructor "
        }

        if lessonPlan?.properties.objective != modifiedProperties.objective {
            description += "Changed Objective "
        }

        if lessonPlan?.properties.preparation != modifiedProperties.preparation {
            description += "Changed Preparation "
        }

        if lessonPlan?.properties.summary != modifiedProperties.summary {
            description += "Changed Summary "
        }

        return description
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CustomSectionHeader(title: "File Name")
                TextField("File Name...", text: $fileName, axis: .vertical)
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
                
                Divider()
                Section {
                    DatePicker(selection: $modifiedProperties.date) {
                        Text("Date of Lesson:")
                    }
                    .labelsHidden()
                    .padding(.bottom)
                } header: {
                    CustomSectionHeader(title: "Date Of Lesson")
                }
                
                FormEntryTextField(title: "Objective of the Lesson:", text: $modifiedProperties.objective)
                
                FormEntryTextField(title: "Teacher preparation/Equipment needs:", text: $modifiedProperties.preparation)
                
                FormEntryTextField(title: "Lesson content/Procedure:", text: $modifiedProperties.content)
                
                FormEntryTextField(title: "Summary and evaluation of the lesson", text: $modifiedProperties.summary)
                
                FormEntryTextField(title: "Goals for the next lesson", text: $modifiedProperties.goals)
                
                if lessonPlan != nil {
                    if !description.isEmpty {
                        TextField("Reason for Change...", text: $reasonForChange, axis: .vertical)
                        Text(description)
                            .bold()
                        HStack {
                            Spacer()
                            Button("Save Changes") {
                                do {
                                    let newFileChange = PastChangeRidingLessonPlan(properties: lessonPlan!.properties, fileName: lessonPlan!.medicalRecordFile.fileName, changeDescription: description, reason: reasonForChange, author: username, date: .now)
                                    lessonPlan!.pastChanges.append(newFileChange)
                                    lessonPlan!.medicalRecordFile.fileName = fileName
                                    lessonPlan!.properties = modifiedProperties
                                    try modelContext.save()
                                    modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan!.properties)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(reasonForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    CustomSectionHeader(title: "Past Changes")
                    if let lessonPlan = lessonPlan {
                        ForEach(lessonPlan.pastChanges) { change in
                            HStack {
                                VStack {
                                    Text(change.changeDescription)
                                    Text(change.date.description)
                                }
                                Spacer()
                                Button("Revert To") {
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
                            }
                            
                        }
                    }
                }
                
            }
            .toolbar {
                if lessonPlan == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                    }
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
                }
            }
        }
        .onAppear {
            if let lessonPlan = lessonPlan {
                fileName = lessonPlan.medicalRecordFile.fileName
                modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan.properties)
            }
        }
    }
    func addFile() {
        let digitalSignature = DigitalSignature(author: username, dateAdded: .now)
        let fileName = fileName
        let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: digitalSignature)
        let properties = RidingLessonProperties(otherLessonProperties: modifiedProperties)
        modelContext.insert(properties)
        try? modelContext.save()
        let ridingLesson = RidingLessonPlan(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(ridingLesson)
        try? modelContext.save()
    }
    func revertLessonPlan(otherProperties: RidingLessonProperties, otherFileName: String) {
        let oldProperties = lessonPlan!.properties
        lessonPlan!.properties = otherProperties
        modelContext.delete(oldProperties)
        lessonPlan!.medicalRecordFile.fileName = otherFileName
        fileName = otherFileName
        modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan!.properties)
        try? modelContext.save()
    }
}

struct FormEntryTextField: View {
    var title: String
    @Binding var text: String
    var body: some View {
        CustomSectionHeader(title: title)
        TextField("", text: $text, axis: .vertical)
            .padding(.bottom)
    }
}
