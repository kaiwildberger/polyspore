//
//  PhotoEntry+CoreDataClass.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/28/24.
//
//

import Foundation
import CoreData
import UIKit

@objc(PhotoEntry)
public class PhotoEntry: NSManagedObject {
    static func addCoreData(name: String, image: URL) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newData = PhotoEntry(context: context)
        newData.name = name
        newData.image = image
        do {
            try context.save()
        } catch {
            print("error-Saving data")
        }
    }
    static func fetchCoreData(onSuccess: @escaping ([PhotoEntry]?) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let items = try context.fetch(PhotoEntry.fetchRequest()) as? [PhotoEntry]
            onSuccess(items)
        } catch {
            print("error-Fetching data")
        }
    }
    static func deleteCoreData(indexPath: Int, items: [PhotoEntry]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let dataToRemove = items[indexPath]
        context.delete(dataToRemove)
        do {
            try context.save()
        } catch {
            print("error-Deleting data")
        }
    }
}
