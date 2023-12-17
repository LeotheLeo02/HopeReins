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
    @ObservedObject var mockLessonPlan: MockRidingLesson
    @State var reasonForChange: String = ""
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var isAddingPlan: Bool
    var lessonPlan: RidingLessonPlan?
    var changeDescription: String {
        var description: String = ""
        // TODO: Add more detailed automatic descriptions of changes
        if lessonPlan?.content != mockLessonPlan.content {
            description += "Changed Content "
        }
        if lessonPlan?.date != mockLessonPlan.date {
            description += "Changed Date "
        }
        if lessonPlan?.goals != mockLessonPlan.goals {
            description += "Changed Goals "
        }
        if lessonPlan?.instructorName != mockLessonPlan.instructor {
            description += "Changed Instructor "
        }
        
        if lessonPlan?.objective != mockLessonPlan.objective {
            description += "Changed Objective "
        }
        
        if lessonPlan?.preparation != mockLessonPlan.preparation {
            description += "Changed Preparation "
        }
        
        if lessonPlan?.summary != mockLessonPlan.summary {
            description += "Changed Summary "
        }
        
        return description
    }
    var username: String?

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                CustomSectionHeader(title: "Instructor")
                Picker(selection: $mockLessonPlan.instructor) {
                    ForEach(instructors) { user in
                        Text(user.username)
                            .tag(user.username)
                    }
                } label: {
                    Text("Instructor: \(mockLessonPlan.instructor)")
                }
                .labelsHidden()
                
                
                Text("Patient: \(mockLessonPlan.patient.name) \(mockLessonPlan.patient.dateOfBirth.formatted(date: .numeric, time: .omitted))")
                    .bold()
                
                
                Divider()
                Section {
                    DatePicker(selection: $mockLessonPlan.date) {
                        Text("Date of Lesson:")
                    }
                    .labelsHidden()
                    .padding(.bottom)
                } header: {
                    CustomSectionHeader(title: "Date Of Lesson")
                }
                
                FormEntryTextField(title: "Objective of the Lesson:", text: $mockLessonPlan.objective)
                
                FormEntryTextField(title: "Teacher preparation/Equipment needs:", text: $mockLessonPlan.preparation)
                
                FormEntryTextField(title: "Lesson content/Procedure:", text: $mockLessonPlan.content)
                
                FormEntryTextField(title: "Summary and evaluation of the lesson", text: $mockLessonPlan.summary)
                
                FormEntryTextField(title: "Goals for the next lesson", text: $mockLessonPlan.goals)
                
                if !isAddingPlan {
                    if !changeDescription.isEmpty {
                        TextField("Reason for Change...", text: $reasonForChange, axis: .vertical)
                        Text(changeDescription)
                            .bold()
                        HStack {
                            Spacer()
                            Button("Save Changes") {
                                do {
                                    let copyOfPlan = RidingLessonPlan(lessonPlan: lessonPlan!)
                                    modelContext.insert(copyOfPlan)
                                    let newFileChange = PastChangeRidingLessonPlan(ridingLessonPlan: copyOfPlan, changeDescription: changeDescription, reason: reasonForChange, author: username!, date: Date.now)
                                    lessonPlan!.pastChanges.append(newFileChange)
                                    try modelContext.save()
                                    mockLessonPlan.saveOrAdd(modelContext: modelContext)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(reasonForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    CustomSectionHeader(title: "Past Changes")
                    ForEach(lessonPlan!.pastChanges) { change in
                        HStack {
                            VStack {
                                Text(change.changeDescription)
                                Text(change.date.description)
                            }
                            Spacer()
                            Button("Revert To") {
                                do {
                                    mockLessonPlan.revertLessonPlan(modelContext: modelContext, lessonPlan: change.ridingLessonPlan)
                                    lessonPlan?.pastChanges.removeAll(where: { element in
                                        return element.reason == change.reason
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
                            mockLessonPlan.saveOrAdd(modelContext: modelContext)
                            dismiss()
                        }, label: {
                            Text("Save")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
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
