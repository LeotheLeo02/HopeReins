//
//  HopeReinsApp.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import SwiftData

typealias Patient = HopeReinsSchemaV2.Patient
typealias PatientFile = HopeReinsSchemaV2.PatientFile
typealias User = HopeReinsSchemaV2.User
typealias FileChange = HopeReinsSchemaV2.FileChange

@main
struct HopeReinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema ([
            Patient.self,
            PatientFile.self,
            User.self,
            FileChange.self
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
    
    @Model final class Patient {
        public var id = UUID()
        var name: String
        var mrn: Int
        var dateOfBirth: Date
        
        @Relationship(deleteRule: .cascade)
        var files = [PatientFile]()
        
        init(name: String, mrn: Int, dateOfBirth: Date) {
            self.name = name
            self.mrn = mrn
            self.dateOfBirth = dateOfBirth
        }
    }

    @Model final class PatientFile {
        public var id = UUID()
        var data: Data
        var fileType: String
        var name: String
        var author: String
        var dateAdded: Date
        var patient: Patient?
        @Relationship(deleteRule: .cascade)
        var changes = [FileChange]()
        
        init(id: UUID = UUID(), data: Data, fileType: String, name: String, author: String, dateAdded: Date) {
            self.id = id
            self.data = data
            self.fileType = fileType
            self.name = name
            self.author = author
            self.dateAdded = dateAdded
        }
    }
    
    @Model final class FileChange {
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
