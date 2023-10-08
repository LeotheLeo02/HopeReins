//
//  HopeReinsApp.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import SwiftData

typealias Patient = HopeReinsSchemaV2.Patient
typealias ReleaseStatement = HopeReinsSchemaV2.ReleaseStatement

@main
struct HopeReinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema ([
            Patient.self,
            ReleaseStatement.self,
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
        [Patient.self]
    }
    
    @Model final class Patient {
        var name: String
        var dateOfBirth: Date
        
        init(name: String, dateOfBirth: Date) {
            self.name = name
            self.dateOfBirth = dateOfBirth
        }
    }

    @Model final class ReleaseStatement {
        var id = UUID()
        var data: Data
        
        @Relationship(deleteRule: .nullify)
        var patient: Patient?
        
        @Transient
        var patientName: String {
            return patient?.name ?? ""
        }
        
        init(data: Data) {
            self.data = data
        }
    }
}
