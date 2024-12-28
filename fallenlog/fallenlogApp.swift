//
//  fallenlogApp.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/27/24.
//

import SwiftUI

@main
struct fallenlogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
