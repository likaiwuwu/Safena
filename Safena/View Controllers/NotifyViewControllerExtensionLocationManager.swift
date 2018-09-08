//
//  NotificationViewControllerExtensionLocationManager.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/6/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension NotifyViewController {
    
    func configureLocationManager(desiredAccuracy: CLLocationAccuracy, allowsBackgroundLocationUpdates: Bool, distanceFilter: CLLocationDistance) {
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
        locationManager.distanceFilter = distanceFilter
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate)
        guard let locValue = manager.location?.coordinate else { return }
        fakeUser.updateLocationCoordinate(coordinate: locValue)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DID START MONITORING FOR: \(region.debugDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("MINITORING DID FAIL FOR...")
        print("MANAGER: \(manager.debugDescription)")
        print("DID FAIL MONITORING FOR: \(region.debugDescription)")
        print("ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DID FAIL WITH ERROR")
        print("MANAGER: \(manager.debugDescription)")
        print("DID FAIL WITH ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("RANGING BEACONS DID FAIL FOR")
        print("rangingBeaconDidFail executed error \(error.localizedDescription) for region \(region.proximityUUID)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DID ENTER REGION")
//        if region is CLBeaconRegion {
//            // Start ranging only if the feature is available.
//            if CLLocationManager.isRangingAvailable() {
//                manager.startRangingBeacons(in: region as! CLBeaconRegion)
//                print("CONNECTED TO: \(region.identifier)!!!!!!!!!!!!!!!!!!!!!!!!!!")
//                // Store the beacon so that ranging can be stopped on demand.
//                // beaconsToRange.append(region as! CLBeaconRegion)
//            }
//        } else {
//            print("NOT A CLBEACONREGION")
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("DID EXIT REGION")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("LOCATION MANAGER DID PAUSE LOCATION UPDATES")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("LOCATION MANAGER DID RESUME LOCATION UPDATES")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("DID RANGE BEACONS")
        if beacons.count > 0 {
            let beacon = beacons[0]
            print("beacons count is \(beacons.count)")
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
}
