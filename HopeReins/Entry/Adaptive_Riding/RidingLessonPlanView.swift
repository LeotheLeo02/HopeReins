//
//  RidingLessonPlanView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI

struct RidingLessonPlanView: View {
    var patient: Patient
    @State var date: Date = .now
    
    // TODO: Store these in CoreData
    @State var instructor: String = ""
    
    @State var objective: String = ""
    @State var preparation: String = ""
    @State var content: String = ""
    @State var summary: String = ""
    
    @State var goalString: String = ""
    @State var goals: [String] = []
    var body: some View {
        VStack {
            TextField("Instructor:", text: $instructor, axis: .vertical)
            
            Text("Patient: \(patient.name) \(patient.dateOfBirth.formatted())")
                .bold()
            
            Divider()
            
            DatePicker(selection: $date) {
                Text("Date of Lesson:")
            }
            //TODO: Add section titles
            
            TextField("Objective of the Lesson:", text: $objective, axis: .vertical)
            
            TextField("Teacher preparation/Equipment needs:", text: $preparation, axis: .vertical)
            
            TextField("Lesson content/Procedure:", text: $content, axis: .vertical)
            
            TextField("Summary and evaluation of the lesson", text: $summary, axis: .vertical)
            
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
        .padding()
    }
}
