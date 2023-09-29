//
//  HopeReinsApp.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI
import SwiftData

@main
struct HopeReinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema ([
            Patient.self,
        ])
        let fileManager = FileManager.default
        var modelConfiguration = ModelConfiguration()
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let storeURL = documentDirectory.appendingPathComponent("HopeReins.sqlite")
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        }
        do  {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
