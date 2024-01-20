//
//  Evaluation.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 1/19/24.
//

import Foundation
import SwiftData

extension HopeReinsSchemaV2 {
    
    @Model final class Evaluation: Revertible, ChangeRecordable {
        typealias PropertiesType = EvaluationProperties
        typealias ChangeType = PastEvaluation
        @Attribute(.unique) var id: UUID = UUID()
        var medicalRecordFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var pastChanges: [PastEvaluation] = [PastEvaluation]()
        @Relationship(deleteRule: .cascade)
        var properties: EvaluationProperties
        
        init(medicalRecordFile: MedicalRecordFile, properties: EvaluationProperties) {
            self.medicalRecordFile = medicalRecordFile
            self.properties = properties
        }
        
        func addChangeRecord(_ change: PastEvaluation, modelContext: ModelContext) {
            pastChanges.append(change)
            self.medicalRecordFile.digitalSignature.modified()
            try? modelContext.save()
        }
        
        func revertToProperties(_ properties: EvaluationProperties, fileName: String, modelContext: ModelContext) {
            self.properties = properties
            self.medicalRecordFile.fileName = fileName
            self.medicalRecordFile.digitalSignature.modified()
            try? modelContext.save()
        }
    }
    
    @Model final class EvaluationProperties: Reflectable, ResettableProperties {
        
        init() {
            educationLevel = ""
            extraCurricular = ""
            familyHistory = ""
            homeBarriers = ""
            pastMedicalHistory = ""
            surgicalHistory = ""
            medication = ""
            vision = ""
            hearing = ""
            communication = ""
            seizures = ""
            AUpperExtremity = ""
            ALowerExtremity = ""
            SUpperExtremity = ""
            SLowerExtremity = ""
            trunkMusculator = ""
            romTable = ""
            pain = ""
            tone = ""
            sensation = ""
            reflexes = ""
            protectiveExtension = ""
            righting = ""
            equilibrium = ""
            praxis = ""
            neurologicalNotes = ""
            toileting = ""
            CUpperExtremities = ""
            CLowerExtremities = ""
            coordinationNotes = ""
            endurance = ""
            sitStatic = ""
            sitDynamic = ""
            stanceStatic = ""
            stanceDynamic = ""
            balanceNotes = ""
            currentEquipment = ""
            locomotion = ""
            assistanceDistance = ""
            levelSurfaces = ""
            rampSurfaces = ""
            curbSurfaces = ""
            stairsSurfaces = ""
            uevenSurfaces = ""
            gaitDeviations = ""
            wheelChairSkills = ""
            supineToSit = ""
            sitToStand = ""
            standPivot = ""
            floorToStand = ""
            bedMobility = ""
            armyCrawling = ""
            creeping = ""
            suprineProne = ""
            quadruped = ""
            tallKneel = ""
            halfKneel = ""
            sideSitting = ""
            tailorSitting = ""
            posture = ""
            chronologicalAge = ""
            developmentAge = ""
            specialTesting = ""
            primaryProblems = ""
        }
        
        init(other: HopeReinsSchemaV2.EvaluationProperties) {
            self.educationLevel = other.educationLevel
            self.extraCurricular = other.extraCurricular
            self.familyHistory = other.familyHistory
            self.homeBarriers = other.homeBarriers
            self.pastMedicalHistory = other.pastMedicalHistory
            self.surgicalHistory = other.surgicalHistory
            self.medication = other.medication
            self.vision = other.vision
            self.hearing = other.hearing
            self.communication = other.communication
            self.seizures = other.seizures
            self.AUpperExtremity = other.AUpperExtremity
            self.ALowerExtremity = other.ALowerExtremity
            self.SUpperExtremity = other.SUpperExtremity
            self.SLowerExtremity = other.SLowerExtremity
            self.trunkMusculator = other.trunkMusculator
            self.romTable = other.romTable
            self.pain = other.pain
            self.tone = other.tone
            self.sensation = other.sensation
            self.reflexes = other.reflexes
            self.protectiveExtension = other.protectiveExtension
            self.righting = other.righting
            self.equilibrium = other.equilibrium
            self.praxis = other.praxis
            self.neurologicalNotes = other.neurologicalNotes
            self.toileting = other.toileting
            self.CUpperExtremities = other.CUpperExtremities
            self.CLowerExtremities = other.CLowerExtremities
            self.coordinationNotes = other.coordinationNotes
            self.endurance = other.endurance
            self.sitStatic = other.sitStatic
            self.sitDynamic = other.sitDynamic
            self.stanceStatic = other.stanceStatic
            self.stanceDynamic = other.stanceDynamic
            self.balanceNotes = other.balanceNotes
            self.currentEquipment = other.currentEquipment
            self.locomotion = other.locomotion
            self.assistanceDistance = other.assistanceDistance
            self.levelSurfaces = other.levelSurfaces
            self.rampSurfaces = other.rampSurfaces
            self.curbSurfaces = other.curbSurfaces
            self.stairsSurfaces = other.stairsSurfaces
            self.uevenSurfaces = other.uevenSurfaces
            self.gaitDeviations = other.gaitDeviations
            self.wheelChairSkills = other.wheelChairSkills
            self.supineToSit = other.supineToSit
            self.sitToStand = other.sitToStand
            self.standPivot = other.standPivot
            self.floorToStand = other.floorToStand
            self.bedMobility = other.bedMobility
            self.armyCrawling = other.armyCrawling
            self.creeping = other.creeping
            self.suprineProne = other.suprineProne
            self.quadruped = other.quadruped
            self.tallKneel = other.tallKneel
            self.halfKneel = other.halfKneel
            self.sideSitting = other.sideSitting
            self.tailorSitting = other.tailorSitting
            self.posture = other.posture
            self.chronologicalAge = other.chronologicalAge
            self.developmentAge = other.developmentAge
            self.specialTesting = other.specialTesting
            self.primaryProblems = other.primaryProblems
        }
        
        @Attribute(.unique) var id: UUID = UUID()
        var educationLevel: String
        var extraCurricular: String
        var familyHistory: String
        var homeBarriers: String
        var pastMedicalHistory: String
        var surgicalHistory: String
        var medication: String
        var vision: String
        var hearing: String
        var communication: String
        var seizures: String
        var AUpperExtremity: String
        var ALowerExtremity: String
        var SUpperExtremity: String
        var SLowerExtremity: String
        var trunkMusculator: String
        var romTable: String
        var pain: String
        var tone: String
        var sensation: String
        var reflexes: String
        var protectiveExtension: String
        var righting: String
        var equilibrium: String
        var praxis: String
        var neurologicalNotes: String
        var toileting: String
        var CUpperExtremities: String
        var CLowerExtremities: String
        var coordinationNotes: String
        var endurance: String
        var sitStatic: String
        var sitDynamic: String
        var stanceStatic: String
        var stanceDynamic: String
        var balanceNotes: String
        var currentEquipment: String
        var locomotion: String
        var assistanceDistance: String
        var levelSurfaces: String
        var rampSurfaces: String
        var curbSurfaces: String
        var stairsSurfaces: String
        var uevenSurfaces: String
        var gaitDeviations: String
        var wheelChairSkills: String
        var supineToSit: String
        var sitToStand: String
        var standPivot: String
        var floorToStand: String
        var bedMobility: String
        var armyCrawling: String
        var creeping: String
        var suprineProne: String
        var quadruped: String
        var tallKneel: String
        var halfKneel: String
        var sideSitting: String
        var tailorSitting: String
        var posture: String
        var chronologicalAge: String
        var developmentAge: String
        var specialTesting: String
        var primaryProblems: String
        
        
        func toDictionary() -> [String: Any] {
             return [
                 "Education Level": educationLevel,
                 "Extra Curricular": extraCurricular,
                 "Family History": familyHistory,
                 "Home Barriers": homeBarriers,
                 "Past Medical History": pastMedicalHistory,
                 "Surgical History": surgicalHistory,
                 "Medication": medication,
                 "Vision": vision,
                 "Hearing": hearing,
                 "Communication": communication,
                 "Seizures": seizures,
                 "A Upper Extremity": AUpperExtremity,
                 "A Lower Extremity": ALowerExtremity,
                 "S Upper Extremity": SUpperExtremity,
                 "S Lower Extremity": SLowerExtremity,
                 "Trunk Musculature": trunkMusculator,
                 "ROM Table": romTable,
                 "Pain": pain,
                 "Tone": tone,
                 "Sensation": sensation,
                 "Reflexes": reflexes,
                 "Protective Extension": protectiveExtension,
                 "Righting": righting,
                 "Equilibrium": equilibrium,
                 "Praxis": praxis,
                 "Neurological Notes": neurologicalNotes,
                 "Toileting": toileting,
                 "C Upper Extremities": CUpperExtremities,
                 "C Lower Extremities": CLowerExtremities,
                 "Coordination Notes": coordinationNotes,
                 "Endurance": endurance,
                 "Sit Static": sitStatic,
                 "Sit Dynamic": sitDynamic,
                 "Stance Static": stanceStatic,
                 "Stance Dynamic": stanceDynamic,
                 "Balance Notes": balanceNotes,
                 "Current Equipment": currentEquipment,
                 "Locomotion": locomotion,
                 "Assistance Distance": assistanceDistance,
                 "Level Surfaces": levelSurfaces,
                 "Ramp Surfaces": rampSurfaces,
                 "Curb Surfaces": curbSurfaces,
                 "Stairs Surfaces": stairsSurfaces,
                 "Uneven Surfaces": uevenSurfaces,
                 "Gait Deviations": gaitDeviations,
                 "Wheel Chair Skills": wheelChairSkills,
                 "Supine To Sit": supineToSit,
                 "Sit To Stand": sitToStand,
                 "Stand Pivot": standPivot,
                 "Floor To Stand": floorToStand,
                 "Bed Mobility": bedMobility,
                 "Army Crawling": armyCrawling,
                 "Creeping": creeping,
                 "Supine Prone": suprineProne,
                 "Quadruped": quadruped,
                 "Tall Kneel": tallKneel,
                 "Half Kneel": halfKneel,
                 "Side Sitting": sideSitting,
                 "Tailor Sitting": tailorSitting,
                 "Posture": posture,
                 "Chronological Age": chronologicalAge,
                 "Development Age": developmentAge,
                 "Special Testing": specialTesting,
                 "Primary Problems": primaryProblems
             ]
         }
        
    }
    
    @Model final class PastEvaluation: SnapshotChange {
        var id: UUID = UUID()
        
        typealias PropertiesType = EvaluationProperties
        var properties: EvaluationProperties
        var fileName: String
        var title: String
        var changeDescriptions: [String]
        var author: String
        var date: Date
        
        init(properties: EvaluationProperties, fileName: String, title: String, changeDescriptions: [String], author: String, date: Date) {
            self.properties = properties
            self.fileName = fileName
            self.title = title
            self.changeDescriptions = changeDescriptions
            self.author = author
            self.date = date
        }
    }
}

