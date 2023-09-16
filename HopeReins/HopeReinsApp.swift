//
//  HopeReinsApp.swift
//  HopeReins
//
//  Created by Nathanael Suarez on 9/10/23.
//

import SwiftUI

@main
struct HopeReinsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
