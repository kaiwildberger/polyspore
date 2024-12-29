//
//  PhotoEntry+CoreDataProperties.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/28/24.
//
//

import Foundation
import CoreData


extension PhotoEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntry> {
        return NSFetchRequest<PhotoEntry>(entityName: "PhotoEntry")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var image: URL?
    @NSManaged public var notes: String?
    @NSManaged public var author: String?

}

extension PhotoEntry : Identifiable {

}
