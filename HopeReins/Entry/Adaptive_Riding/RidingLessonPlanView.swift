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
    @State var properties: RidingLessonProperties
    @State var initialProperties: InitialProperties = InitialProperties()
    @State var reasonForChange: String = ""
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var isAddingPlan: Bool
    var changeDescription: String = ""
    var lessonPlan: RidingLessonPlan?
    var username: String
    var patient: Patient?
//        var description: String = ""
//        // TODO: Add more detailed automatic descriptions of changes
//        if lessonPlan?.content != mockLessonPlan.content {
//            description += "Changed Content "
//        }
//        if lessonPlan?.date != mockLessonPlan.date {
//            description += "Changed Date "
//        }
//        if lessonPlan?.goals != mockLessonPlan.goals {
//            description += "Changed Goals "
//        }
//        if lessonPlan?.instructorName != mockLessonPlan.instructor {
//            description += "Changed Instructor "
//        }
//        
//        if lessonPlan?.objective != mockLessonPlan.objective {
//            description += "Changed Objective "
//        }
//        
//        if lessonPlan?.preparation != mockLessonPlan.preparation {
//            description += "Changed Preparation "
//        }
//        
//        if lessonPlan?.summary != mockLessonPlan.summary {
//            description += "Changed Summary "
//        }
//        
//        return description
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
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
                
                Divider()
                Section {
                    DatePicker(selection: $properties.date) {
                        Text("Date of Lesson:")
                    }
                    .labelsHidden()
                    .padding(.bottom)
                } header: {
                    CustomSectionHeader(title: "Date Of Lesson")
                }
                
                FormEntryTextField(title: "Objective of the Lesson:", text: $properties.objective)
                
                FormEntryTextField(title: "Teacher preparation/Equipment needs:", text: $properties.preparation)
                
                FormEntryTextField(title: "Lesson content/Procedure:", text: $properties.content)
                
                FormEntryTextField(title: "Summary and evaluation of the lesson", text: $properties.summary)
                
                FormEntryTextField(title: "Goals for the next lesson", text: $properties.goals)
                
                if !isAddingPlan {
                    if changeDescription.isEmpty {
                        TextField("Reason for Change...", text: $reasonForChange, axis: .vertical)
                        Text(changeDescription)
                            .bold()
                        HStack {
                            Spacer()
                            Button("Save Changes") {
                                do {
                                    let changes = RidingLessonProperties(initialProperties: initialProperties)
                                    modelContext.insert(changes)
                                    try modelContext.save()
                                    let newFileChange = PastChangeRidingLessonPlan(properties: changes, changeDescription: "changeDescription", reason: reasonForChange, author: username, date: .now)
                                    lessonPlan!.pastChanges.append(newFileChange)
                                    try modelContext.save()
                                    initialProperties = InitialProperties(properties: properties)
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
                                        revertLessonPlan(otherProperties: change.properties)
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
                if isAddingPlan {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Cancel")
                        })
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            if isAddingPlan {
                                addFile()
                            }
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
            initialProperties = InitialProperties(properties: properties)
        }
    }
    func addFile() {
        let digitalSignature = DigitalSignature(author: username, dateAdded: .now)
        let fileName = "Riding Lesson Plan"
        let medicalRecordFile = MedicalRecordFile(patient: patient!, fileName: fileName, fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: digitalSignature)
        modelContext.insert(properties)
        try? modelContext.save()
        let ridingLesson = RidingLessonPlan(medicalRecordFile: medicalRecordFile, properties: properties)
        modelContext.insert(ridingLesson)
        try? modelContext.save()
    }
    func revertLessonPlan(otherProperties: RidingLessonProperties) {
        lessonPlan?.properties = otherProperties
        properties = lessonPlan!.properties
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
    var instructorName: String = ""
    var date: Date = .now
    var objective: String = ""
    var preparation: String = ""
    var content: String = ""
    var summary: String = ""
    var goals: String = ""
    
    init() { }

    init(properties: RidingLessonProperties) {
        self.instructorName = properties.instructorName
        self.date = properties.date
        self.objective = properties.objective
        self.preparation = properties.preparation
        self.content = properties.content
        self.summary = properties.summary
        self.goals = properties.goals
    }
}
