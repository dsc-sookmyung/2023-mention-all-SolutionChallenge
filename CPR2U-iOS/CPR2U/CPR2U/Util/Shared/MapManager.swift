//
//  MapManager.swift
//  CPR2U
//
//  Created by 황정현 on 2023/03/26.
//

import Foundation
import GoogleMaps
import GooglePlaces

final class MapManager {
    func setLocation() -> CLLocationCoordinate2D {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        guard let coor = locationManager.location?.coordinate else { return CLLocationCoordinate2D(latitude: 59, longitude: 59)}
        
        return coor
    }
}
