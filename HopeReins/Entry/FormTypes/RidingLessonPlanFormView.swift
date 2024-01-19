//
//  RidingLessonPlanFormView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/17/24.
//

import SwiftUI
import SwiftData

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
