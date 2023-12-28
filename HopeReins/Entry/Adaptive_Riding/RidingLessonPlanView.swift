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
    @State var titleForChange: String = ""
    @State var showChanges: Bool = false
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
                CustomSectionHeader(title: "File Name")
                TextField("File Name...", text: $fileName, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
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
                    
                    DateSelection(title: "Date of Lesson", hourAndMinute: true, date: $modifiedProperties.date)
                    
                    BasicTextField(title: "Objective of the Lesson:", text: $modifiedProperties.objective)
                    
                    BasicTextField(title: "Teacher preparation/Equipment needs:", text: $modifiedProperties.preparation)
                    
                    BasicTextField(title: "Lesson content/Procedure:", text: $modifiedProperties.content)
                    
                    BasicTextField(title: "Summary and evaluation of the lesson:", text: $modifiedProperties.summary)
                    
                    BasicTextField(title: "Goals for the next lesson:", text: $modifiedProperties.goals)
                    
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
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

struct ReviewChangesLessonPlan: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State var titleForChange: String = ""
    @Binding var modifiedProperties: RidingLessonProperties
    var lessonPlan: RidingLessonPlan?
    var description: String
    var username: String
    var fileName: String
    var body: some View {
        VStack {
            TextField("Title of Change...", text: $titleForChange, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Text(description)
                .bold()
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

                Spacer()
                Button("Save Changes") {
                    do {
                        let newFileChange = PastChangeRidingLessonPlan(properties: lessonPlan!.properties, fileName: lessonPlan!.medicalRecordFile.fileName, title: titleForChange, changeDescription: description, author: username, date: .now)
                        lessonPlan!.pastChanges.append(newFileChange)
                        lessonPlan!.medicalRecordFile.fileName = fileName
                        lessonPlan!.properties = modifiedProperties
                        try modelContext.save()
                        modifiedProperties = RidingLessonProperties(otherLessonProperties: lessonPlan!.properties)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(titleForChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }
}
