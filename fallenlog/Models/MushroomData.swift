//
//  MushroomData.swift
//  fallenlog
//
//  Created by Kai Wildberger on 1/6/25.
//

enum FamilyClassification: String, CaseIterable, Identifiable, Codable {
    case unknown, amanitaceae, boletaceae, russulaceae
    var id: Self { self }
}

enum CapShapeClassification: String, CaseIterable, Identifiable, Codable {
    case unknown, cylindrical, conical, bell, umbonate, convex, plane, uplifted, umbilicate, depressed, funnel
    var id: Self { self }
}

enum StipeShapeClassification: String, CaseIterable, Identifiable, Codable {
    case unknown, taperingDown, equal, taperingUp, enlargedBelow, bulbous
    var id: Self { self }
}

struct GlobalMushroomData {
    var families: [String] = ["Amanitaceae", "Boletaceae", "Russulaceae"] // double as tags
}

struct EntryMushroomData: Codable {
    // which of these should be optional and how do i express that in the form
    
    var capShape: CapShapeClassification = .unknown
    var capMeasurements: String = ""
    var capColor: String = ""
    var capStain: String = ""
    var capTexture: String = "" // should this be an enum
    var capMargin: String = "" // this too
    
    var stipeShape: StipeShapeClassification = .unknown
    var stipeMeasurements: String = ""
    var stipeColor: String = ""
    var stipeStain: String = ""
    var stipeTexture: String = ""
    var stipeInterior: String = ""
    
    var gillsColor: String = ""
    var gillsAttachment: String = ""
    var gillsSpores: String = ""
}

// cap and stem
// shape measurements color stain texture
// cap: margin
// stem: interior

// gills
// color attachment spores
