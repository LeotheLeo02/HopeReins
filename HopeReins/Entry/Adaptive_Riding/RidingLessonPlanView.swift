//
//  RidingLessonPlanView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/2/23.
//

import SwiftUI
import SwiftData


struct RidingLessonPlanView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var fileName: String = ""
    @State var modifiedProperties: RidingLessonProperties = RidingLessonProperties()
    @State var titleForChange: String = ""
    @State var showChanges: Bool = false
    @State var pastChangesExpanded: Bool = false
    @Query(sort: \User.username, order: .forward)
    var instructors: [User]
    var lessonPlan: RidingLessonPlan?
    var username: String
    var patient: Patient?
    private var description: String {
        guard let oldLessonProperties = lessonPlan?.properties else { return "" }
        
        let oldFileName = lessonPlan?.medicalRecordFile.fileName ?? "nil"
        let newFileName = fileName
        
        let fileNameChange = (oldFileName != newFileName) ?
        "File Name changed from \"\(oldFileName)\" to \"\(newFileName)\", " : ""
        
        return fileNameChange + RidingLessonProperties.compareProperties(old: oldLessonProperties, new: modifiedProperties)
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if lessonPlan != nil {
                    pastChangesView()
                }
                
                formDetailsView()
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text((lessonPlan == nil || !description.isEmpty) ? "Cancel" : "Done")
                })
            }
            if lessonPlan == nil {
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
            } else if !description.isEmpty {
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
        .sheet(isPresented: $showChanges, content: {
            ReviewChangesLessonPlan(modifiedProperties: $modifiedProperties, lessonPlan: lessonPlan, description: description, username: username, fileName: fileName)
        })
        .onAppear {
            if let lessonPlan = lessonPlan {
                fileName = lessonPlan.medicalRecordFile.fileName
                modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan.properties)
            }
        }
    }
    @ViewBuilder
    func pastChangesView() -> some View {
        DisclosureGroup(isExpanded: $pastChangesExpanded) {
            ForEach(lessonPlan?.pastChanges ?? [], id: \.self) { change in
                RidingChangeView(lessonPlan: lessonPlan!, modifiedProperties: $modifiedProperties, fileName: $fileName, change: change)
            }
        } label: {
            CustomSectionHeader(title: "Past Changes")
        }
    }
    
    @ViewBuilder
    func formDetailsView() -> some View {
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
}

