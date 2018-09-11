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
        currentUser.updateLocationCoordinate(coordinate: locations.last!.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        currentUser.updateMonitoringUsers(user: region.)
//        if let otherUser = createUserFromFRD(accountID: region.identifier) {
//            otherUser.updateMonitoringUsers(user: currentUser)
//        }
        printt("""
            MANAGER: \(manager.debugDescription)
            DID START MONITORING FOR REGION: \(region.debugDescription)
            """)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        printt("DID RANGE BEACONS")
        if let victimUser = createUserFromFRD(accountID: region.identifier) {
            victimUser.updateRangingUUID(newRangingBeaconUUIDString: currentUser.uuid.uuidString)
        }
        if let user = createUserFromFRD(accountID: region.identifier) {
            startMonitoringAndRangingUser(user: user)
            printt("Did range beacons for Region Identifier: \(region.identifier)")
        }
        update(distance: beacons.first?.proximity ?? .unknown)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let user = createUserFromFRD(accountID: region.identifier) {
            stopMonitoringAndRangingUser(user: user)
            printt("Did exit region for Region Identifier: \(region.identifier)")
        }
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
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
//        stopMonitoringAndRangingUser(user: user)
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
    
    // Continuously logs distance to bystanders.
    // Changes the color of the background to indicate nearby bystander presence.
    private func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) { [unowned self] in
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.init(hex: 0x9698e8)
                printt("UNKNOWN")
            case .far:
                self.view.backgroundColor = UIColor.init(hex: 0x6c6fdf)
                printt("FAR")
            case .near:
                self.view.backgroundColor = UIColor.init(hex: 0x4246d6)
                printt("NEAR")
            case .immediate:
                self.view.backgroundColor = UIColor.init(hex: 0x292cbd)
                printt("IMMEDIATE")
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            printt("central.state is .unknown")
        case .resetting:
            printt("central.state is .resetting")
        case .unsupported:
            printt("central.state is .unsupported")
        case .unauthorized:
            printt("central.state is .unauthorized")
        case .poweredOff:
            printt("central.state is .poweredOff")
        case .poweredOn:
            printt("central.state is .poweredOn")
        }
    }
}
