//
//  PhotoEntry.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/28/24.
//

import Foundation
import SwiftData
import SwiftUI
import AVFoundation
import CoreData
import CoreLocation

@Model
class PhotoEntry: Identifiable {
    var author: String = "iOS Device"
    var timestamp: Int = 0
    var notes: String = "(no note added)"
    var image: Data = Data(count: 0)
    var family: FamilyClassification = FamilyClassification.unknown
    var mushroomData: EntryMushroomData = EntryMushroomData()
    var id: UUID = UUID()
    var location: [Double]
    init(author: String, timestamp: Int, notes: String, image: Data, family: String? = nil, location: [Double]? = nil) {
//    init(author: String, timestamp: Date, notes: String, image: Data, family: String? = nil) {
        self.author = author
        self.timestamp = timestamp
        self.notes = notes
        self.image = image
        self.family = FamilyClassification.unknown
        self.mushroomData = EntryMushroomData()
        self.location = location ?? [0.0, 0.0, 0.0] // where does it fail when it cant get the location
        self.id = id
    }
}

func emptyEntry() -> PhotoEntry {
    return PhotoEntry(author: "", timestamp: Int(Date().timeIntervalSince1970), notes: "", image: Data(count: 0))
}
