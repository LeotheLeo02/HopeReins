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
            return AnyView(RidingLessonPlanView(mockLessonPlan: MockRidingLesson(instructor: user.username, patient: patient, username: user.username), isAddingPlan: true))
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
    
    func revertLessonPlan(modelContext: ModelContext, lessonPlan: RidingLessonPlan) {
        try? modelContext.transaction {
            if let existingLesson = ridingLesson {
                existingLesson.objective = lessonPlan.objective
                existingLesson.content = lessonPlan.content
                existingLesson.date = lessonPlan.date
                existingLesson.goals = lessonPlan.goals
                existingLesson.instructorName = lessonPlan.instructorName
                existingLesson.preparation = lessonPlan.preparation
                existingLesson.summary = lessonPlan.summary
            }
            try? modelContext.save()
        }
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
    func createLessonPlan(instructor: String, date: Date, objective: String, preparation: String, content: String, summary: String, goals: String) -> RidingLessonPlan {
        let digitalSignature = DigitalSignature(author: username, dateAdded: .now)
        let fileName = "Riding Lesson Plan_\(date.formatted(.iso8601))"
        let medicalRecordFile = MedicalRecordFile(patient: patient, fileName: fileName, fileType: RidingFormType.ridingLessonPlan.rawValue, digitalSignature: digitalSignature)
        return RidingLessonPlan(medicalRecordFile: medicalRecordFile, instructorName: instructor, date: date, objective: objective, preparation: preparation, content: content, summary: summary, goals: goals)
    }

    func saveOrAdd(modelContext: ModelContext) {
        try? modelContext.transaction {
            if let existingLesson = ridingLesson {
                existingLesson.date = date
                existingLesson.instructorName = instructor
                existingLesson.objective = objective
                existingLesson.preparation = preparation
                existingLesson.content = content
                existingLesson.summary = summary
                existingLesson.goals = goals
            } else {
                let newLesson = createLessonPlan(instructor: instructor, date: date, objective: objective, preparation: preparation, content: content, summary: summary, goals: goals)
                modelContext.insert(newLesson)
                ridingLesson = newLesson
            }
            try? modelContext.save()
        }
    }
}
