//
//  Evaluation.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/19/24.
//

import SwiftUI
import SwiftData

extension HopeReinsSchemaV2 {
    
//    @Model final class Evaluation: Revertible {
//        typealias PropertiesType = EvaluationProperties
//        typealias ChangeType = PastEvaluation
//        @Attribute(.unique) var id: UUID = UUID()
//        var medicalRecordFile: MedicalRecordFile
//        @Relationship(deleteRule: .cascade)
//        var properties: EvaluationProperties
//        
//        init(medicalRecordFile: MedicalRecordFile, properties: EvaluationProperties) {
//            self.medicalRecordFile = medicalRecordFile
//            self.properties = properties
//        }
//    }
    
//    @Model final class EvaluationProperties: ResettableProperties, DynamicUIRepresentable {
//        var properties: [String : CodableValue] = [:]
//        
//        var pastChanges: [PastChange] = []
//        
//        func getDynamicUIElements() -> [DynamicUIElement] {
//            let uiElements: [DynamicUIElement] = [
//                .textField(title: "Education Level:", binding: Binding(get: { self.educationLevel }, set: { self.educationLevel = $0 })),
//                .textField(title: "Extracurricular:", binding: Binding(get: { self.extraCurricular }, set: { self.extraCurricular = $0 })),
//                .textField(title: "Home Barrier:", binding: Binding( get: { self.homeBarriers }, set: { self.homeBarriers = $0 })),
//                .textField(title: "Past medical and/or rehab history:", binding: Binding( get: { self.pastMedicalHistory }, set: { self.pastMedicalHistory = $0 })),
//                .textField(title: "Surgical History:", binding: Binding( get: { self.surgicalHistory }, set: { self.surgicalHistory = $0 })),
//                .textField(title: "Medications:", binding: Binding( get: { self.medication }, set: { self.medication = $0 })),
//                .textField(title: "Vision:", binding: Binding( get: { self.vision }, set: { self.vision = $0 })),
//                .textField(title: "Hearing:", binding: Binding( get: { self.vision }, set: { self.vision = $0 })),
//                .textField(title: "Speech/Communications:", binding: Binding( get: { self.communication }, set: { self.communication = $0 })),
//                .textField(title: "Seizures:", binding: Binding( get: { self.seizures }, set: { self.seizures = $0 })),
//                .sectionHeader(title: "A/Prom"),
//                .textField(title: "Upper Extremity:", binding: Binding( get: { self.AUpperExtremity }, set: { self.AUpperExtremity = $0 })),
//                .textField(title: "Lower Extremity:", binding: Binding( get: { self.ALowerExtremity }, set: { self.ALowerExtremity = $0 })),
//                .sectionHeader(title: "Strength"),
//                .textField(title: "Upper Extremities:", binding: Binding( get: { self.SLowerExtremity }, set: { self.SUpperExtremity = $0 })),
//                .textField(title: "Lower Extremities:", binding: Binding( get: { self.SLowerExtremity }, set: { self.SLowerExtremity = $0 })),
//                .textField(title: "Trunk Musculature:", binding: Binding( get: { self.trunkMusculator }, set: { self.trunkMusculator = $0 })),
//                .customView(title: "LE Strength and ROM Table:", viewProvider: {
//                    AnyView(LeRomTable(combinedString: Binding(get: { self.romTable }, set: { self.romTable = $0 })))
//                }),
//                .singleSelectDescription(titles: ["Pain"], labels: ["No", "Yes"], combinedString: Binding (get: { self.pain }, set: { self.pain = $0}), isDescription: true),
//                .sectionHeader(title: "Neurological Functioning"),
//                .singleSelectDescription(titles: ["Tone"], labels: ["WNL", "Hypotonic", "Fluctuating", "NT"], combinedString: Binding (get: { self.tone }, set: { self.tone = $0}), isDescription: true),
//                .singleSelectDescription(titles: ["Sensation"], labels: ["WNL", "Hyposensitive", "Hypersensitive", "Absent", "NT"], combinedString: Binding (get: { self.sensation }, set: { self.sensation = $0}), isDescription: true),
//                .singleSelectDescription(titles: ["Reflexes"], labels: ["WNL", "Hyporesponse" , "Hyperesponse", "Deficits", "NT"], combinedString: Binding (get: { self.reflexes }, set: { self.reflexes = $0}), isDescription: true),
//                .singleSelectDescription(titles: ["Protective Extension", "Righting", "Equilibrium", "Praxis"], labels: ["WNL", "Deficient", "Emerging", "Absent", "NT"], combinedString: Binding (get: { self.protectiveExtensionToPraxis }, set: { self.protectiveExtensionToPraxis = $0}), isDescription: true),
//                .textField(title: "Notes:", binding: Binding( get: { self.neurologicalNotes }, set: { self.neurologicalNotes = $0 })),
//                .textField(title: "Toileting", binding: Binding( get: { self.toileting }, set: { self.toileting = $0 })),
//                .sectionHeader(title: "Coordination"),
//                .singleSelectDescription(titles: ["Upper Extremities", "Lower Extremeties"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: Binding (get: { self.CExtremities }, set: { self.CExtremities = $0}), isDescription: true),
//                .textField(title: "Notes", binding: Binding( get: { self.coordinationNotes }, set: { self.coordinationNotes = $0 })),
//                .singleSelectDescription(titles: ["Endurance"], labels: ["Normal", "Good", "Fair", "Poor", "NT"], combinedString: Binding (get: { self.endurance }, set: { self.endurance = $0}), isDescription: true),
//            ]
//                           
//            return uiElements
//        }
//        
//        
//        init() {
//            educationLevel = ""
//            extraCurricular = ""
//            familyHistory = ""
//            homeBarriers = ""
//            pastMedicalHistory = ""
//            surgicalHistory = ""
//            medication = ""
//            vision = ""
//            hearing = ""
//            communication = ""
//            seizures = ""
//            AUpperExtremity = ""
//            ALowerExtremity = ""
//            SUpperExtremity = ""
//            SLowerExtremity = ""
//            trunkMusculator = ""
//            romTable = ""
//            pain = ""
//            tone = ""
//            sensation = ""
//            reflexes = ""
//            protectiveExtensionToPraxis = ""
//            neurologicalNotes = ""
//            toileting = ""
//            CExtremities = ""
//            coordinationNotes = ""
//            endurance = ""
//            sitStatic = ""
//            sitDynamic = ""
//            stanceStatic = ""
//            stanceDynamic = ""
//            balanceNotes = ""
//            currentEquipment = ""
//            locomotion = ""
//            assistanceDistance = ""
//            levelSurfaces = ""
//            rampSurfaces = ""
//            curbSurfaces = ""
//            stairsSurfaces = ""
//            uevenSurfaces = ""
//            gaitDeviations = ""
//            wheelChairSkills = ""
//            supineToSit = ""
//            sitToStand = ""
//            standPivot = ""
//            floorToStand = ""
//            bedMobility = ""
//            armyCrawling = ""
//            creeping = ""
//            suprineProne = ""
//            quadruped = ""
//            tallKneel = ""
//            halfKneel = ""
//            sideSitting = ""
//            tailorSitting = ""
//            posture = ""
//            chronologicalAge = ""
//            developmentAge = ""
//            specialTesting = ""
//            primaryProblems = ""
//        }
//        var keyPathDictionary: [String: PartialKeyPath<EvaluationProperties>] {
//            [
//                "Education Level": \.educationLevel,
//                "Extra Curricular": \.extraCurricular,
//                "Family History": \.familyHistory,
//                "Home Barriers": \.homeBarriers,
//                "Past Medical History": \.pastMedicalHistory,
//                "Surgical History": \.surgicalHistory,
//                "Medication": \.medication,
//                "Vision": \.vision,
//                "Hearing": \.hearing,
//                "Communication": \.communication,
//                "Seizures": \.seizures,
//                "A Upper Extremity": \.AUpperExtremity,
//                "A Lower Extremity": \.ALowerExtremity,
//                "S Upper Extremity": \.SUpperExtremity,
//                "S Lower Extremity": \.SLowerExtremity,
//                "Trunk Musculature": \.trunkMusculator,
//                "ROM Table": \.romTable,
//                "Pain": \.pain,
//                "Tone": \.tone,
//                "Sensation": \.sensation,
//                "Reflexes": \.reflexes,
//                "Protective Extension to Praxis": \.protectiveExtensionToPraxis,
//                "Neurological Notes": \.neurologicalNotes,
//                "Toileting": \.toileting,
//                "C Extremities": \.CExtremities,
//                "Coordination Notes": \.coordinationNotes,
//                "Endurance": \.endurance,
//                "Sit Static": \.sitStatic,
//                "Sit Dynamic": \.sitDynamic,
//                "Stance Static": \.stanceStatic,
//                "Stance Dynamic": \.stanceDynamic,
//                "Balance Notes": \.balanceNotes,
//                "Current Equipment": \.currentEquipment,
//                "Locomotion": \.locomotion,
//                "Assistance Distance": \.assistanceDistance,
//                "Level Surfaces": \.levelSurfaces,
//                "Ramp Surfaces": \.rampSurfaces,
//                "Curb Surfaces": \.curbSurfaces,
//                "Stairs Surfaces": \.stairsSurfaces,
//                "Uneven Surfaces": \.uevenSurfaces,
//                "Gait Deviations": \.gaitDeviations,
//                "Wheel Chair Skills": \.wheelChairSkills,
//                "Supine To Sit": \.supineToSit,
//                "Sit To Stand": \.sitToStand,
//                "Stand Pivot": \.standPivot,
//                "Floor To Stand": \.floorToStand,
//                "Bed Mobility": \.bedMobility,
//                "Army Crawling": \.armyCrawling,
//                "Creeping": \.creeping,
//                "Supine Prone": \.suprineProne,
//                "Quadruped": \.quadruped,
//                "Tall Kneel": \.tallKneel,
//                "Half Kneel": \.halfKneel,
//                "Side Sitting": \.sideSitting,
//                "Tailor Sitting": \.tailorSitting,
//                "Posture": \.posture,
//                "Chronological Age": \.chronologicalAge,
//                "Development Age": \.developmentAge,
//                "Special Testing": \.specialTesting,
//                "Primary Problems": \.primaryProblems,
//            ]
//        }
//        
//
//        init(other: HopeReinsSchemaV2.EvaluationProperties) {
//            self.educationLevel = other.educationLevel
//            self.extraCurricular = other.extraCurricular
//            self.familyHistory = other.familyHistory
//            self.homeBarriers = other.homeBarriers
//            self.pastMedicalHistory = other.pastMedicalHistory
//            self.surgicalHistory = other.surgicalHistory
//            self.medication = other.medication
//            self.vision = other.vision
//            self.hearing = other.hearing
//            self.communication = other.communication
//            self.seizures = other.seizures
//            self.AUpperExtremity = other.AUpperExtremity
//            self.ALowerExtremity = other.ALowerExtremity
//            self.SUpperExtremity = other.SUpperExtremity
//            self.SLowerExtremity = other.SLowerExtremity
//            self.trunkMusculator = other.trunkMusculator
//            self.romTable = other.romTable
//            self.pain = other.pain
//            self.tone = other.tone
//            self.sensation = other.sensation
//            self.reflexes = other.reflexes
//            self.protectiveExtensionToPraxis = other.protectiveExtensionToPraxis
//            self.neurologicalNotes = other.neurologicalNotes
//            self.toileting = other.toileting
//            self.CExtremities = other.CExtremities
//            self.coordinationNotes = other.coordinationNotes
//            self.endurance = other.endurance
//            self.sitStatic = other.sitStatic
//            self.sitDynamic = other.sitDynamic
//            self.stanceStatic = other.stanceStatic
//            self.stanceDynamic = other.stanceDynamic
//            self.balanceNotes = other.balanceNotes
//            self.currentEquipment = other.currentEquipment
//            self.locomotion = other.locomotion
//            self.assistanceDistance = other.assistanceDistance
//            self.levelSurfaces = other.levelSurfaces
//            self.rampSurfaces = other.rampSurfaces
//            self.curbSurfaces = other.curbSurfaces
//            self.stairsSurfaces = other.stairsSurfaces
//            self.uevenSurfaces = other.uevenSurfaces
//            self.gaitDeviations = other.gaitDeviations
//            self.wheelChairSkills = other.wheelChairSkills
//            self.supineToSit = other.supineToSit
//            self.sitToStand = other.sitToStand
//            self.standPivot = other.standPivot
//            self.floorToStand = other.floorToStand
//            self.bedMobility = other.bedMobility
//            self.armyCrawling = other.armyCrawling
//            self.creeping = other.creeping
//            self.suprineProne = other.suprineProne
//            self.quadruped = other.quadruped
//            self.tallKneel = other.tallKneel
//            self.halfKneel = other.halfKneel
//            self.sideSitting = other.sideSitting
//            self.tailorSitting = other.tailorSitting
//            self.posture = other.posture
//            self.chronologicalAge = other.chronologicalAge
//            self.developmentAge = other.developmentAge
//            self.specialTesting = other.specialTesting
//            self.primaryProblems = other.primaryProblems
//        }
//        
//        @Attribute(.unique) var id: UUID = UUID()
//        var educationLevel: String
//        var extraCurricular: String
//        var familyHistory: String
//        var homeBarriers: String
//        var pastMedicalHistory: String
//        var surgicalHistory: String
//        var medication: String
//        var vision: String
//        var hearing: String
//        var communication: String
//        var seizures: String
//        var AUpperExtremity: String
//        var ALowerExtremity: String
//        var SUpperExtremity: String
//        var SLowerExtremity: String
//        var trunkMusculator: String
//        var romTable: String
//        var pain: String
//        var tone: String
//        var sensation: String
//        var reflexes: String
//        var protectiveExtensionToPraxis: String
//        var neurologicalNotes: String
//        var toileting: String
//        var CExtremities: String
//        var coordinationNotes: String
//        var endurance: String
//        var sitStatic: String
//        var sitDynamic: String
//        var stanceStatic: String
//        var stanceDynamic: String
//        var balanceNotes: String
//        var currentEquipment: String
//        var locomotion: String
//        var assistanceDistance: String
//        var levelSurfaces: String
//        var rampSurfaces: String
//        var curbSurfaces: String
//        var stairsSurfaces: String
//        var uevenSurfaces: String
//        var gaitDeviations: String
//        var wheelChairSkills: String
//        var supineToSit: String
//        var sitToStand: String
//        var standPivot: String
//        var floorToStand: String
//        var bedMobility: String
//        var armyCrawling: String
//        var creeping: String
//        var suprineProne: String
//        var quadruped: String
//        var tallKneel: String
//        var halfKneel: String
//        var sideSitting: String
//        var tailorSitting: String
//        var posture: String
//        var chronologicalAge: String
//        var developmentAge: String
//        var specialTesting: String
//        var primaryProblems: String
//        
//        
//        func toDictionary() -> [String: Any] {
//             return [
//                 "Education Level": educationLevel,
//                 "Extra Curricular": extraCurricular,
//                 "Family History": familyHistory,
//                 "Home Barriers": homeBarriers,
//                 "Past Medical History": pastMedicalHistory,
//                 "Surgical History": surgicalHistory,
//                 "Medication": medication,
//                 "Vision": vision,
//                 "Hearing": hearing,
//                 "Communication": communication,
//                 "Seizures": seizures,
//                 "A Upper Extremity": AUpperExtremity,
//                 "A Lower Extremity": ALowerExtremity,
//                 "S Upper Extremity": SUpperExtremity,
//                 "S Lower Extremity": SLowerExtremity,
//                 "Trunk Musculature": trunkMusculator,
//                 "ROM Table": romTable,
//                 "Pain": pain,
//                 "Tone": tone,
//                 "Sensation": sensation,
//                 "Reflexes": reflexes,
////                 "Protective Extension": protectiveExtension,
////                 "Righting": righting,
////                 "Equilibrium": equilibrium,
////                 "Praxis": praxis,
//                 "Neurological Notes": neurologicalNotes,
//                 "Toileting": toileting,
////                 "C Upper Extremities": CUpperExtremities,
////                 "C Lower Extremities": CLowerExtremities,
//                 "Coordination Notes": coordinationNotes,
//                 "Endurance": endurance,
//                 "Sit Static": sitStatic,
//                 "Sit Dynamic": sitDynamic,
//                 "Stance Static": stanceStatic,
//                 "Stance Dynamic": stanceDynamic,
//                 "Balance Notes": balanceNotes,
//                 "Current Equipment": currentEquipment,
//                 "Locomotion": locomotion,
//                 "Assistance Distance": assistanceDistance,
//                 "Level Surfaces": levelSurfaces,
//                 "Ramp Surfaces": rampSurfaces,
//                 "Curb Surfaces": curbSurfaces,
//                 "Stairs Surfaces": stairsSurfaces,
//                 "Uneven Surfaces": uevenSurfaces,
//                 "Gait Deviations": gaitDeviations,
//                 "Wheel Chair Skills": wheelChairSkills,
//                 "Supine To Sit": supineToSit,
//                 "Sit To Stand": sitToStand,
//                 "Stand Pivot": standPivot,
//                 "Floor To Stand": floorToStand,
//                 "Bed Mobility": bedMobility,
//                 "Army Crawling": armyCrawling,
//                 "Creeping": creeping,
//                 "Supine Prone": suprineProne,
//                 "Quadruped": quadruped,
//                 "Tall Kneel": tallKneel,
//                 "Half Kneel": halfKneel,
//                 "Side Sitting": sideSitting,
//                 "Tailor Sitting": tailorSitting,
//                 "Posture": posture,
//                 "Chronological Age": chronologicalAge,
//                 "Development Age": developmentAge,
//                 "Special Testing": specialTesting,
//                 "Primary Problems": primaryProblems
//             ]
//         }
//        
//    }
//    
//    @Model final class PastEvaluation: SnapshotChange {
//        var id: UUID = UUID()
//        
//        typealias PropertiesType = EvaluationProperties
//        var properties: EvaluationProperties
//        var fileName: String
//        var title: String
//        var changeDescriptions: [String]
//        var author: String
//        var date: Date
//        
//        init(properties: EvaluationProperties, fileName: String, title: String, changeDescriptions: [String], author: String, date: Date) {
//            self.properties = properties
//            self.fileName = fileName
//            self.title = title
//            self.changeDescriptions = changeDescriptions
//            self.author = author
//            self.date = date
//        }
//    }
}

