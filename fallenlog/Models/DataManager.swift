//
//  DataManager.swift
//  fallenlog
//
//  Created by Kai Wildberger on 2/21/25.
//

import Foundation
import SwiftData
import CoreData
import CoreLocation
import AVFoundation // ? for those images

// yeah bro i love classes!!! waiter, waiter! more classes please :p
// mfw swift == java
// (i am not using this file. it is here for Reference.... In Case I Need It. 🙂‍↕️)

class DataManager {
    static let shared = DataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "PhotoEntryModel")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let error = err as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createPhotoEntry(entry: PhotoEntry) {
        let context = persistentContainer.viewContext
    }
}
