//
//  NotificationViewControllerExtensionLocationManager.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/6/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import CoreBluetooth

extension NotifyViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fakeUser.updateLocationCoordinate(coordinate: locations[0].coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        printt("""
            MANAGER: \(manager.debugDescription)
            DID FAIL WITH ERROR: \(error.localizedDescription)
            """)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        printt("""
            MANAGER: \(manager.debugDescription)
            MONITORING DID FAIL FOR: \(region.debugDescription)
            ERROR: \(error.localizedDescription)
            """)
    }
    
    private func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        printt("""
            MANAGER: \(manager.debugDescription)
            DID START MONITORING FOR REGION: \(region.debugDescription)
            """)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        printt("DID RANGE BEACONS")
        update(distance: beacons.first?.proximity ?? .unknown)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        printt("""
            MANAGER: \(manager.debugDescription)
            RANGING BEACONS DID FAIL FOR REGION: \(region.debugDescription)
            WITH ERROR: \(error.localizedDescription)
            """)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        printt("LOCATION MANAGER DID PAUSE LOCATION UPDATES")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        printt("LOCATION MANAGER DID RESUME LOCATION UPDATES")
    }
    
}
