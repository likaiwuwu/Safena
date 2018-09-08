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
                DID FAIL WITH ERROR
                MANAGER: \(manager.debugDescription)
                DID FAIL WITH ERROR: \(error.localizedDescription)
                """)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DID ENTER REGION")
                if region is CLBeaconRegion {
                    // Start ranging only if the feature is available.
                    if CLLocationManager.isRangingAvailable() {
                        manager.startRangingBeacons(in: region as! CLBeaconRegion)
                        print("CONNECTED TO: \(region.identifier)!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        // Store the beacon so that ranging can be stopped on demand.
                        // beaconsToRange.append(region as! CLBeaconRegion)
                    }
                } else {
                    print("NOT A CLBEACONREGION")
                }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        printt("DID EXIT REGION")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        printt("""
            MANAGER: \(manager.debugDescription)
            MONITORING DID FAIL FOR: \(region.debugDescription)
            ERROR: \(error.localizedDescription)
            """)
    }

    private func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        printt("DID START MONITORING FOR: \(region.debugDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        printt("DID RANGE BEACONS")
        if beacons.count > 0 {
            update(distance: beacons[0].proximity)
//            bystanderTableView.reloadData()
        } else {
            update(distance: .unknown)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        printt("""
            RANGING BEACONS DID FAIL FOR
            rangingBeaconDidFail executed error \(error.localizedDescription) for region \(region.proximityUUID)
            """)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        printt("LOCATION MANAGER DID PAUSE LOCATION UPDATES")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        printt("LOCATION MANAGER DID RESUME LOCATION UPDATES")
    }
    
}
