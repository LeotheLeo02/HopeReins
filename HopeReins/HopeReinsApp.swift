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
typealias User = HopeReinsSchemaV2.User
typealias DigitalSignature = HopeReinsSchemaV2.DigitalSignature
typealias PastChange = HopeReinsSchemaV2.PastChange
typealias Version = HopeReinsSchemaV2.Version


@main
struct HopeReinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema ([
            Patient.self,
            MedicalRecordFile.self,
            User.self,
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
}
