//
//  polysporeApp.swift
//  polyspore
//
//  Created by Kai Wildberger on 12/28/24.
//

import SwiftUI
import SwiftData

@main
struct polysporeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PhotoEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(sharedModelContainer)
        .modelContainer(for: PhotoEntry.self)
//        let _ = sharedModelContainer.mainContext.container.deleteAllData()
    }
}
