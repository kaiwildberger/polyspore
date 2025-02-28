//
//  Location.swift
//  fallenlog
//
//  Created by Kai Wildberger on 2/10/25.
//

import Foundation
import CoreLocation

@Observable
class LocationManager {
    var location: CLLocation? = nil
    private let locationManager = CLLocationManager()
    func requestUserAuth() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }
            self.location = location
        }
    }
}

class LocationWrapper {
    var lat: Double
    var long: Double
    var alt: Double
    var acc: Double
    var id: UUID = UUID()
    init(full: CLLocationCoordinate2D, alt: CLLocationDistance, acc: CLLocationDistance) {
        self.lat = full.latitude
        self.long = full.longitude
        if alt > -10000000.0 {
            self.alt = alt
        } else {
            self.alt = 0.0 // this should be if location perms are denied
        }
        self.acc = acc // radius of horizontal uncertainty
    }
    func expand() -> [Double] {
        return [self.lat, self.long, self.alt, self.acc]
    }
}
