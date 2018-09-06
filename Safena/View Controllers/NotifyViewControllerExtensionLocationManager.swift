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

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DID START MONITORING FOR: \(region.debugDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("MANAGER: \(manager.debugDescription)")
        print("DID FAIL MONITORING FOR: \(region.debugDescription)")
        print("ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MANAGER: \(manager.debugDescription)")
        print("DID FAILE WITH ERROR: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else { return }
        fakeUser.updateCoordinate(coordinate: locValue)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("ERRORRRR:\(error.localizedDescription) for region \(region.proximityUUID)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
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
    
}
