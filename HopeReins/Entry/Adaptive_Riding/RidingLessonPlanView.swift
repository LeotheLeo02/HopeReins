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
    
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
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
            }
            .padding()
            
            .toolbar {
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

struct FormEntryTextField: View {
    var title: String
    @Binding var text: String
    var body: some View {
        CustomSectionHeader(title: title)
        TextField("", text: $text, axis: .vertical)
            .padding(.bottom)
    }
}
