//
//  HopeReinsApp.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import SwiftData

typealias Patient = HopeReinsSchemaV2.Patient
typealias MedicalRecordFile = HopeReinsSchemaV2.MedicalRecordFile
typealias UploadFile = HopeReinsSchemaV2.UploadFile
typealias User = HopeReinsSchemaV2.User
typealias FileChange = HopeReinsSchemaV2.FileChange
typealias RidingLessonPlan = HopeReinsSchemaV2.RidingLessonPlan
typealias RidingLessonProperties = HopeReinsSchemaV2.RidingLessonProperties
typealias PastChangeRidingLessonPlan = HopeReinsSchemaV2.PastChangeRidingLessonPlan
typealias DigitalSignature = HopeReinsSchemaV2.DigitalSignature


@main
struct HopeReinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema ([
            Patient.self,
            MedicalRecordFile.self,
            User.self,
            FileChange.self,
            RidingLessonPlan.self,
            UploadFile.self
        ])
        let fileManager = FileManager.default
        var modelConfiguration = ModelConfiguration()
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let storeURL = documentDirectory.appendingPathComponent("HopeReins.sqlite")
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        }
        do  {
            return try ModelContainer(for: schema,migrationPlan: HopeReinsMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
enum HopeReinsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HopeReinsSchemaV1.self, HopeReinsSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: HopeReinsSchemaV1.self,
        toVersion: HopeReinsSchemaV2.self
    )
}

enum HopeReinsSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Patient.self]
    }

    @Model final class Patient {
        var name: String
        
        init(name: String) {
            self.name = name
        }
    }
}
enum HopeReinsSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 1)
    
    static var models: [any PersistentModel.Type] {
        [Patient.self, User.self]
    }
    
    @Model class Patient {
        public var id = UUID()
        var name: String
        var mrn: Int
        var dateOfBirth: Date
        
        @Relationship(deleteRule: .cascade)
        var files = [MedicalRecordFile]()
        
        init(name: String, mrn: Int, dateOfBirth: Date) {
            self.name = name
            self.mrn = mrn
            self.dateOfBirth = dateOfBirth
        }
    }
    
    @Model class FileChange {
        var fileId: UUID
        var reason: String
        var date: Date
        var author: String
        var title: String
    
        init(fileId: UUID, reason: String, date: Date, author: String, title: String) {
            self.fileId = fileId
            self.reason = reason
            self.date = date
            self.author = author
            self.title = title
        }
    }
    
    @Model final class MedicalRecordFile {
        public var id = UUID()
        var patient: Patient
        var fileName: String
        var fileType: String
        var digitalSignature: DigitalSignature
        
        init(id: UUID = UUID(), patient: Patient, fileName: String, fileType: String, digitalSignature: DigitalSignature) {
            self.id = id
            self.patient = patient
            self.fileName = fileName
            self.fileType = fileType
            self.digitalSignature = digitalSignature
        }
    }
    
    @Model class DigitalSignature {
        var author: String
        var dateAdded: Date
        
        init(author: String, dateAdded: Date) {
            self.author = author
            self.dateAdded = dateAdded
        }
    }
    @Model final class UploadFile {
     @Relationship(deleteRule: .cascade)
      var medicalRecordFile: MedicalRecordFile
      var data: Data
      public var id = UUID()
        
        init(medicalRecordFile: MedicalRecordFile, data: Data) {
            self.medicalRecordFile = medicalRecordFile
            self.data = data
        }
    }
    
    @Model final class RidingLessonPlan {
        @Relationship(deleteRule: .cascade)
        var medicalRecordFile: MedicalRecordFile
        @Relationship(deleteRule: .cascade)
        var pastChanges: [PastChangeRidingLessonPlan] = [PastChangeRidingLessonPlan]()
        @Relationship(deleteRule: .cascade)
        var properties: RidingLessonProperties
        
        init(medicalRecordFile: MedicalRecordFile, properties: RidingLessonProperties) {
            self.medicalRecordFile = medicalRecordFile
            self.properties = properties
        }
        
    }
    
    @Model final class RidingLessonProperties {
        var instructorName: String
        var date: Date
        var objective: String
        var preparation: String
        var content: String
        var summary: String
        var goals: String
        
        init () {
            self.instructorName = ""
            self.date = .now
            self.objective = ""
            self.preparation = ""
            self.content = ""
            self.summary = ""
            self.goals = ""
        }
        
        init(initialProperties: InitialProperties) {
            self.instructorName = initialProperties.instructorName
            self.date = initialProperties.date
            self.objective = initialProperties.objective
            self.preparation = initialProperties.preparation
            self.content = initialProperties.content
            self.summary = initialProperties.summary
            self.goals = initialProperties.goals
        }
    }
    
    @Model final class PastChangeRidingLessonPlan {
        var properties: RidingLessonProperties
        var changeDescription: String
        var reason: String
        var author: String
        var date: Date
        
        init(properties: RidingLessonProperties, changeDescription: String, reason: String, author: String, date: Date) {
            self.properties = properties
            self.changeDescription = changeDescription
            self.reason = reason
            self.author = author
            self.date = date
        }
    }
    
    @Model final class User {
        var username: String
        var password: String
        var isLoggedIn: Bool = true
        
        init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }
}
