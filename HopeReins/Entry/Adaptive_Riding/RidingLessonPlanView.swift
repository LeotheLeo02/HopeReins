//
//  RidingLessonPlanView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct RidingLessonPlanView: View {
    @State var date: Date = .now
    
    // TODO: Store these in CoreData
    @State var instructor: String = ""
    @State var student: String = ""
    
    @State var objective: String = ""
    @State var preparation: String = ""
    @State var content: String = ""
    @State var summary: String = ""
    
    @State var goalString: String = ""
    @State var goals: [String] = []
    var body: some View {
        TextField("Instructor:", text: $instructor, axis: .vertical)
        
        TextField("Student:", text: $student, axis: .vertical)
        
        Divider()
        
        DatePicker(selection: $date) {
            Text("Date of Lesson:")
        }
        
        TextField("Objective of the Lesson:", text: $objective, axis: .vertical)
        
        TextField("Teacher preparation/Equipment needs:", text: $preparation, axis: .vertical)
        
        TextField("Lesson content/Procedure:", text: $content, axis: .vertical)
        
        TextField("Summary and evaluation of the lesson", text: $preparation, axis: .vertical)
        
        TextField("Goals for the next lesson", text: $goalString, axis: .vertical)
            .onSubmit {
                goals.append(goalString)
                goalString = ""
            }
        
        ScrollView {
            ForEach(goals, id: \.self) { goal in
                Text(goal)
            }
        }
    }
}

#Preview {
    RidingFormView(rideFormType: .ridingLessonPlan)
}
