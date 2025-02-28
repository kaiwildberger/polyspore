//
//  AppSettings.swift
//  fallenlog
//
//  Created by Kai Wildberger on 2/24/25.
//


@Model
class AppSettings: Identifiable {
    var locationAccuracyThreshold: Double // radius of uncertainty over which to query location again
    var exportName: String
    var id = UUID()
    init(locationAccuracyThreshold: Double = 30, exportName: String = "iPhone") {
        self.locationAccuracyThreshold = locationAccuracyThreshold
        self.exportName = exportName
    }
}
