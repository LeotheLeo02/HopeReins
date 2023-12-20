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
    @State var initialProperties: InitialProperties = InitialProperties()
    @State var reasonForChange: String = ""
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var changeDescription: String = ""
    var lessonPlan: RidingLessonPlan?
    var username: String
    var patient: Patient?
    var description: String {
        var description = ""
        if lessonPlan?.medicalRecordFile.fileName != initialProperties.fileName {
            description += "Changed File Name "
        }
        
        if lessonPlan?.properties.content != initialProperties.content {
            description += "Changed Content "
        }
        if lessonPlan?.properties.date != initialProperties.date {
            description += "Changed Date "
        }
        if lessonPlan?.properties.goals != initialProperties.goals {
            description += "Changed Goals "
        }
        if lessonPlan?.properties.instructorName != initialProperties.instructorName {
            description += "Changed Instructor "
        }

        if lessonPlan?.properties.objective != initialProperties.objective {
            description += "Changed Objective "
        }

        if lessonPlan?.properties.preparation != initialProperties.preparation {
            description += "Changed Preparation "
        }

        if lessonPlan?.properties.summary != initialProperties.summary {
            description += "Changed Summary "
        }

        return description
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CustomSectionHeader(title: "File Name")
                if let lessonPlan = lessonPlan {
                    TextField("File Name...", text: $initialProperties.fileName, axis: .vertical)
                } else {
                    TextField("File Name...", text: $fileName, axis: .vertical)
                }
                
                CustomSectionHeader(title: "Instructor")
                Picker(selection: $initialProperties.instructorName) {
                    ForEach(instructors) { user in
                        Text(user.username)
                            .tag(user.username)
                    }
                } label: {
                    Text("Instructor: \(initialProperties.instructorName)")
                }
                .labelsHidden()
                
                Divider()
                Section {
                    DatePicker(selection: $initialProperties.date) {
                        Text("Date of Lesson:")
                    }
                    .labelsHidden()
                    .padding(.bottom)
                } header: {
                    CustomSectionHeader(title: "Date Of Lesson")
                }
                
                FormEntryTextField(title: "Objective of the Lesson:", text: $initialProperties.objective)
                
                FormEntryTextField(title: "Teacher preparation/Equipment needs:", text: $initialProperties.preparation)
                
                FormEntryTextField(title: "Lesson content/Procedure:", text: $initialProperties.content)
                
                FormEntryTextField(title: "Summary and evaluation of the lesson", text: $initialProperties.summary)
                
                FormEntryTextField(title: "Goals for the next lesson", text: $initialProperties.goals)
                
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
                                    lessonPlan!.medicalRecordFile.fileName = initialProperties.fileName
                                    lessonPlan!.properties = RidingLessonProperties(initialProperties: initialProperties)
                                    try modelContext.save()
                                    initialProperties = InitialProperties(fileName: lessonPlan!.medicalRecordFile.fileName, properties: lessonPlan!.properties)
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
            initialProperties = InitialProperties(fileName: lessonPlan?.medicalRecordFile.fileName ?? "", properties: lessonPlan?.properties ?? .init())
        }
    }
    func addFile() {
        let digitalSignature = DigitalSignature(author: username, dateAdded: .now)
        let fileName = fileName
        let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: digitalSignature)
        let properties = RidingLessonProperties(initialProperties: initialProperties)
        modelContext.insert(properties)
        try? modelContext.save()
        let ridingLesson = RidingLessonPlan(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(ridingLesson)
        try? modelContext.save()
    }
    func revertLessonPlan(otherProperties: RidingLessonProperties, otherFileName: String) {
        lessonPlan!.properties = otherProperties
        lessonPlan!.medicalRecordFile.fileName = otherFileName
        initialProperties = InitialProperties(fileName: otherFileName, properties: otherProperties)
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

struct InitialProperties {
    var fileName: String = ""
    var instructorName: String = ""
    var date: Date = .now
    var objective: String = ""
    var preparation: String = ""
    var content: String = ""
    var summary: String = ""
    var goals: String = ""
    
    init() { }

    init(fileName: String, properties: RidingLessonProperties) {
        self.fileName = fileName
        self.instructorName = properties.instructorName
        self.date = properties.date
        self.objective = properties.objective
        self.preparation = properties.preparation
        self.content = properties.content
        self.summary = properties.summary
        self.goals = properties.goals
    }
}
