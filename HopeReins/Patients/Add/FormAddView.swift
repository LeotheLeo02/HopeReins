//
//  FormAddView.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 10/27/23.
//

import SwiftUI

struct FormAddView: View {
    @Binding var selectedSpecificForm: String?
    var patient: Patient
    var user: User

    var body: some View {
        Group {
            if let ptForm = PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? "") {
                ptForm.view(for: patient, user: user, physicalTherabyFormType: PhysicalTherabyFormType(rawValue: selectedSpecificForm ?? ""), ridingFormType: nil)
            } else if let ridingForm = RidingFormType(rawValue: selectedSpecificForm ?? "") {
                ridingForm.view(for: patient, user: user, physicalTherabyFormType: nil, ridingFormType: RidingFormType(rawValue: selectedSpecificForm ?? ""))
            } else {
                Text("Unknown form type")
            }
        }
    }
}


protocol FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?,  ridingFormType : RidingFormType?) -> AnyView
}

extension PhysicalTherabyFormType: FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .referral:
            return AnyView(SharedFormView(patient: patient, user: user, physicalTherabyFormType: self))
        // Handle other cases
        default:
            return AnyView(EmptyView())
        }
    }
}

extension RidingFormType: FormSpecialGroup {
    func view(for patient: Patient, user: User, physicalTherabyFormType: PhysicalTherabyFormType?, ridingFormType: RidingFormType?) -> AnyView {
        switch self {
        case .releaseStatement, .coverLetter, .updateCoverLetter :
            return AnyView(SharedFormView(patient: patient, user: user, ridingFormType: self))
        case .ridingLessonPlan:
            return AnyView(RidingLessonPlanView(mockLessonPlan: MockRidingLesson(instructor: user.username, patient: patient, username: user.username)))
        default:
            return AnyView(EmptyView())
        }
    }
}

import SwiftData

class MockRidingLesson: ObservableObject {
    @Published var ridingLesson: RidingLessonPlan?
    @Published var date: Date = .now
    @Published var instructor: String = ""
    @Published var patient: Patient
    @Published var username: String = ""
    @Published var objective: String = ""
    @Published var preparation: String = ""
    @Published var content: String = ""
    @Published var summary: String = ""
    @Published var goals: String = ""
    
    init(instructor: String, patient: Patient, username: String) {
        self.instructor = instructor
        self.patient = patient
        self.username = username
    }
    
    init(lessonPlan: RidingLessonPlan, patient: Patient, username: String) {
        self.ridingLesson = lessonPlan
        self.date = lessonPlan.date
        self.instructor = lessonPlan.instructorName
        self.patient = patient
        self.username = username
        self.objective = lessonPlan.objective
        self.preparation = lessonPlan.preparation
        self.content = lessonPlan.content
        self.summary = lessonPlan.summary
        self.goals = lessonPlan.goals
    }
    
    func saveOrAdd(modelContext: ModelContext) {
      try? modelContext.transaction {
        if let lesson = ridingLesson {
          lesson.date = date
          lesson.instructorName = instructor
          lesson.objective = objective
          lesson.preparation = preparation
          lesson.content = content
          lesson.summary = summary
          lesson.goals = goals
        } else {
          let digitalSignature = DigitalSignature(author: username, dateAdded: .now)
          modelContext.insert(digitalSignature)
          let medicalRecordFile = MedicalRecordFile(patient: patient, fileName: "Riding Lesson Plan", fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: digitalSignature)
          modelContext.insert(medicalRecordFile)
          let lessonFile = RidingLessonPlan(medicalRecordFile: medicalRecordFile, instructorName: instructor, date: date, objective: objective, preparation: preparation, content: content, summary: summary, goals: goals)
          modelContext.insert(lessonFile)
          ridingLesson = lessonFile
        }
        try? modelContext.save()
      }
    }
}
