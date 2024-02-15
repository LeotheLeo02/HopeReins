//
//  Forms.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 2/14/24.
//

import SwiftUI

extension UIManagement {
    
    //MARK: - Patient File
    func getPatientFile() -> [FormSection] {
        // TODO: Add int fields and number fields types
        // TODO: ensure that date is working properly
        let uiElements: [FormSection] = [
            FormSection(title: "Personal Info", elements: [
                .textField(title: "Name", binding: stringBinding(for: "Name")),
                .datePicker(title: "Date of Birth", hourAndMinute: false, binding: dateBinding(for: "Date of Birth")),
                .textField(title: "Address", binding: stringBinding(for: "Address")),
                .textField(title: "City", binding: stringBinding(for: "City")),
                .textField(title: "State", binding: stringBinding(for: "State")),
                .textField(title: "Zip", binding: stringBinding(for: "Zip")),
                .textField(title: "Home Phone", binding: stringBinding(for: "Home Phone")),
                .textField(title: "Work Phone", binding: stringBinding(for: "Work Phone")),
                .textField(title: "Cell Phone", binding: stringBinding(for: "Cell Phone")),
                .textField(title: "Email Address", binding: stringBinding(for: "Email Address"))
            ]),
            FormSection(title: "Guardian Information (if participant is under 18 years old)", elements: [
                .textField(title: "Guardian Name", binding: stringBinding(for: "Guardian Name")),
                .textField(title: "Guardian Phone", binding: stringBinding(for: "Guardian Phone")),
                .textField(title: "Guardian Address", binding: stringBinding(for: "Guardian Address")),
                .textField(title: "Guardian City", binding: stringBinding(for: "Guardian City")),
                .textField(title: "Guardian State", binding: stringBinding(for: "Guardian State")),
                .textField(title: "Guardian Zip", binding: stringBinding(for: "Guardian Zip"))
            ]),
            FormSection(title: "Emergency Contact Information", elements: [
                .textField(title: "Emergency Contact Name", binding: stringBinding(for: "Emergency Contact Name")),
                .textField(title: "Emergency Phone", binding: stringBinding(for: "Emergency Phone")),
                .textField(title: "Relation", binding: stringBinding(for: "Relation")),
                .textField(title: "Address", binding: stringBinding(for: "Address")),
                .textField(title: "Emergency City", binding: stringBinding(for: "Emergency City")),
                .textField(title: "Emergency Zip", binding: stringBinding(for: "Emergency Zip")),
                .textField(title: "Emergency Physician", binding: stringBinding(for: "Emergency Physician")),
                .textField(title: "Emergency Phone", binding: stringBinding(for: "Emergency Phone")),
                .textField(title: "Hospital of Preference", binding: stringBinding(for: "Hospital of Preference"))
            ])
        ]
        
        return uiElements
    }
    
    //MARK: - Upload File
    func getUploadFile() -> [FormSection] {
        let uiElements: [FormSection] = [
            FormSection(title: "Upload File", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .fileUploadButton(title: "File Data", dataValue: dataBinding(for: "File Data"))
            ])
        ]
        return uiElements
    }
    
    //MARK: - Riding Lesson Plan
    func getRidingLessonPlan() -> [FormSection] {
        let uiElements : [FormSection] = [
            FormSection(title: "Riding Lesson Plan", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .datePicker(title: "Date", hourAndMinute: false, binding: dateBinding(for: "Date")),
                .textField(title: "Objective", binding: stringBinding(for: "Objective")),
                .textField(title: "Preparation", binding: stringBinding(for: "Preparation")),
                .textField(title: "Content", binding: stringBinding(for: "Content")),
                .textField(title: "Summary", binding: stringBinding(for: "Summary")),
                .textField(title: "Goals", binding: stringBinding(for: "Goals"))
            ])
        ]
        return uiElements
    }
    
    //MARK: - Evaluation Form
    func getEvaluation() -> [FormSection]{
        let uiElements: [FormSection] = [
            FormSection(title: "File Name", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name"))
            ]),
            FormSection(title: "Personal Info", elements: [
                .textField(title: "Education Level", binding: stringBinding(for: "Education Level")),
                .textField(title: "Extracurricular", binding: stringBinding(for: "Extracurricular")),
                .textField(title: "Home Barrier", binding: stringBinding(for: "Home Barrier")),
                .textField(title: "Past medical and/or rehab history", binding: stringBinding(for: "Past medical and/or rehab history")),
                .textField(title: "Surgical History", binding: stringBinding(for: "Surgical History")),
                .textField(title: "Medications", binding: stringBinding(for: "Medications")),
                .textField(title: "Vision", binding: stringBinding(for: "Vision")),
                .textField(title: "Hearing", binding: stringBinding(for: "Hearing")),
                .textField(title: "Speech/Communications", binding: stringBinding(for: "Speech Communications")),
                .textField(title: "Seizures", binding: stringBinding(for: "Seizures")),
            ]),
            FormSection(title: "A/Prom", elements: [
                .textField(title: "A Upper Extremity", binding: stringBinding(for: "A Upper Extremity")),
                .textField(title: "A Lower Extremity", binding: stringBinding(for: "A Lower Extremity")),
            ]),
            FormSection(title: "Strength", elements: [
                .textField(title: "S Upper Extremities", binding: stringBinding(for: "S Upper Extremity")),
                .textField(title: "S Lower Extremities", binding: stringBinding(for: "S Lower Extremity")),
                .textField(title: "Trunk Musculature", binding: stringBinding(for: "Trunk Musculature")),
                .strengthTable(title: "LE Strength and ROM Table", combinedString: stringBinding(for: "LE Strength and ROM Table")),
                .singleSelectDescription(title: "SS Pain", titles: ["Pain"], labels: ["No", "Yes"], combinedString: stringBinding(for: "SS Pain"), isDescription: true)
            ]),
            FormSection(title: "Neurological Functioning", elements: [
                .singleSelectDescription(title: "SS Tone", titles: ["Tone"], labels: ["WNL", "Hypotonic", "Fluctuating", "NT"], combinedString: stringBinding(for: "SS Tone"), isDescription: true),
                .singleSelectDescription(title: "SS Sensation", titles: ["Sensation"], labels: ["WNL", "Hyposensitive", "Hypersensitive", "Absent", "NT"], combinedString: stringBinding(for: "SS Sensation"), isDescription: true),
                .singleSelectDescription(title: "SS Reflexes", titles: ["Reflexes"], labels: ["WNL", "Hyporesponse", "Hyperresponse", "Deficits", "NT"], combinedString: stringBinding(for: "SS Reflexes"), isDescription: true),
                .singleSelectDescription(title: "SS Protective to Praxis", titles: ["Protective Extension", "Righting", "Equilibrium", "Praxis"], labels: ["WNL", "Deficient", "Emerging", "Absent", "NT"], combinedString: stringBinding(for: "SS Protective to Praxis"), isDescription: true),
                .textField(title: "Neurological Notes", binding: stringBinding(for: "Neurological Notes")),
                .textField(title: "Toileting", binding: stringBinding(for: "Toileting")),
            ]),
            FormSection(title: "Coordination", elements: [
                .singleSelectDescription(title: "SS Coordination Extremities", titles: ["Upper Extremities", "Lower Extremities"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Coordination Extremities"), isDescription: true),
                .textField(title: "Coordination Notes", binding: stringBinding(for: "Coordination Notes")),
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Endurance", elements: [
                .singleSelectDescription(title: "SS Endurance", titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Endurance"), isDescription: true)
            ]),
            FormSection(title: "Balance", elements: [
                .singleSelectDescription(title: "SS Balance", titles: ["Sit Static", "Sit Dynamic", "Stance Static", "Stance Dynamic"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: stringBinding(for: "SS Balance"), isDescription: true),
                .textField(title: "Balance Notes", binding: stringBinding(for: "Balance Notes"))
            ]),
            FormSection(title: "Current Equipment", elements: [
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Current Equipment"), labels: ["Orthotics", "Wheelchair", "Bath Equipment", "Glasses", "Augmentative Communication Device", "Walking Device", "Training Aids", "Other"], title: "MST Current Equipment")
            ]),
            FormSection(title: "Mobility", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Locomotion"), labels: ["Ambulation", "Non-Mobile", "Wheel Chair"], title: "MSO Locomotion"),
                .multiSelectWithTitle(combinedString: stringBinding(for: "MST Assistance & Distance"), labels: ["Independent", "Supervision for safety", "Minimal", "Maximal", "SBA", "CGA", "Moderate", "Dependent"], title: "MST Assistance & Distance"),
                .singleSelectDescription(title: "SS Surfaces", titles: ["Level", "Ramp", "Curb", "Stairs", "Uneven terrain"], labels: ["Independent", "SBA", "CGA", "Min", "Mod", "Max"], combinedString: stringBinding(for: "SS Surfaces"), isDescription: true),
                .textField(title: "Gait Deviations", binding: stringBinding(for: "Gait Deviations")),
                .textField(title: "Wheelchair Skills", binding: stringBinding(for: "Wheelchair Skills"))
            ]),
            FormSection(title: "Transfers", elements: [
                .textField(title: "Supine to Sit", binding: stringBinding(for: "Supine to Sit")),
                .textField(title: "Sit to Stand", binding: stringBinding(for: "Sit to Stand")),
                .textField(title: "Stand pivot", binding: stringBinding(for: "Stand pivot")),
                .textField(title: "Floor to stand", binding: stringBinding(for: "Floor to stand")),
                .textField(title: "Bed mobility", binding: stringBinding(for: "Bed mobility")),
                .textField(title: "Army Crawling", binding: stringBinding(for: "Army Crawling")),
                .textField(title: "Creeping", binding: stringBinding(for: "Creeping"))
            ]),
            FormSection(title: "Transitions", elements: [
                .textField(title: "Supine/prone", binding: stringBinding(for: "Supined/prone")),
                .textField(title: "Quadruped", binding: stringBinding(for: "Quadruped")),
                .textField(title: "Tall kneel", binding: stringBinding(for: "Tall kneel")),
                .textField(title: "Half kneel", binding: stringBinding(for: "Half kneel")),
                .textField(title: "Side Sitting", binding: stringBinding(for: "Side Sitting")),
                .textField(title: "Tailor sitting", binding: stringBinding(for: "Tailor sitting")),
                .textField(title: "Other", binding: stringBinding(for: "Transitions Other"))
            ]),
            FormSection(title: "Posture/Body Mechanics/Ergonomics", elements: [
                .singleSelectDescription(title: "SS Posture/Body Mechanics/Ergonomics", titles: ["Posture/Body Mechanics/Ergonomics"], labels: ["WNL", "Patient demonstrated the following deviations"], combinedString: stringBinding(for: "SS Posture/Body Mechanics/Ergonomics"), isDescription: true)
            ]),
            FormSection(title: "Gross Motor Developmental Status", elements: [
                .textField(title: "Chronological Age", binding: stringBinding(for: "Chronological Age")),
                .textField(title: "Approximate Developmental Age", binding: stringBinding(for: "Approximate Developmental Age")),
                .textField(title: "Special Testing/Standardized Testing", binding: stringBinding(for: "Special Testing/Standardized Testing"))
            ]),
            FormSection(title: "Primary Problems/Deficits Include", elements: [
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Primary Problems/Deficits Include"), labels: ["Decreased Strength", "Diminished Endurance", "Dependence with Mobility", "Dependence with ADLs", "Decreased APROM/PROM", "Impaired Coordination/Motor Control", "Dependence with Transition/Transfers", "Impaired Safety Awareness", "Neurologically Impaired Functional Skills", "Developmental Deficits-Gross/Fine Motor", "Impared Balance-Static/Dynamic", "Impaired Sensory Processing/Praxis"], title: "MSO Primary Problems/Deficits Include")
            ]),
            FormSection(title: "Daily Note", elements: [
                .dailyNoteTable(title: "Daily Note", combinedString: stringBinding(for: "Daily Note"))
            ])

        ]

        return uiElements
    }
    
    //MARK: - Physical Therapy Plan of Care
    func getPhysicalTherabyPlanOfCare() -> [FormSection] {
        let uiElements: [FormSection] = [
            FormSection(title: "Diagnosis", elements: [
                .textField(title: "File Name", binding: stringBinding(for: "File Name")),
                .textField(title: "Medical Diagnosis", binding: stringBinding(for: "Medical Diagnosis")),
                .textField(title: "Theraby Diagnosis", binding: stringBinding(for: "Theraby Diagnosis")),
                .textField(title: "Assessment Summary", binding: stringBinding(for: "Assessment Summary"))
            ]),
            FormSection(title: "Goals", elements: [
                .sectionHeader(title: "Short Term"),
                .textField(title: "Short Term Goal 1", binding: stringBinding(for: "Short Term Goal 1")),
                .textField(title: "Short Term Goal 2", binding: stringBinding(for: "Short Term Goal 2")),
                .textField(title: "Short Term Goal 3", binding: stringBinding(for: "Short Term Goal 3")),
                .textField(title: "Short Term Goal 4", binding: stringBinding(for: "Short Term Goal 4")),
                .sectionHeader(title: "Long Term"),
                .textField(title: "Long Term Goal 1", binding: stringBinding(for: "Long Term Goal 1")),
                .textField(title: "Long Term Goal 2", binding: stringBinding(for: "Long Term Goal 2")),
                .textField(title: "Long Term Goal 3", binding: stringBinding(for: "Long Term Goal 3")),
                .textField(title: "Long Term Goal 4", binding: stringBinding(for: "Long Term Goal 4"))
            ]),
            FormSection(title: "Treatment Plan", elements: [
                .sectionHeader(title: "Treatment Plan to address goal attainment will include, but not limited to"),
                .multiSelectOthers(combinedString: stringBinding(for: "MSO Goal Attainment"), labels: ["Balance Training", "Gait Training", "Therapeutic Activity", "Coordination Activities", "Sensory Processing", "ADL Training", "Praxis Activities", "Bilateral Integration Activities", "Proximal Stabalization Training", "Neuromuscular Re-Education", "HEP Training", "Developmental Skills", "Motor Control Training", "Equipment Assessment/Training", "Hippotheraby", "Therapeutic Exercise", "Postural Alignment Training"], title: "MSO Goal Attainment"),
                .singleSelectDescription(title: "Patient demonstrates", titles: ["Patient demonstrates"], labels: ["Good", "Fair", "Poor - rehab potential"], combinedString: stringBinding(for: "Patient demonstrates"), isDescription: false),
                .physicalTherabyFillIn(title: "Physical Theraby Fill In", combinedString: stringBinding(for: "Physical Theraby Fill In")),
                .textField(title: "Discharge Planning", binding: stringBinding(for: "Discharge Planning")),
                .textField(title: "Therapist Signature", binding: stringBinding(for: "Therapist Signature")),
                .datePicker(title: "Therapist Signature Date", hourAndMinute: false, binding: dateBinding(for: "Therapist Signature Date"))
            ]),
            FormSection(title: "UE Strength Table", elements: [
                .strengthTable(title: "UE Arm Strength Table", combinedString: stringBinding(for: "UE Arm Strength Table"))
            ])
        ]
        
        return uiElements
    }
}
