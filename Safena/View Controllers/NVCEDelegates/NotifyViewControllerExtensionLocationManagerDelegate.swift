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
        currentUser.addRangingAccountID(forAccountID: region.identifier)
        if let user = findUserFromUserList(accountID: region.identifier) {
            locationManager.startRangingBeacons(in: user.asBeaconRegion())
        }
        printt("""
            MANAGER: \(manager.debugDescription)
            DID START MONITORING FOR REGION: \(region.debugDescription)
            """)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        printt("DID RANGE BEACONS")
        update(distance: beacons.first?.proximity ?? .unknown)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        printt("DID ENTER REGION")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        printt("DID EXIT REGION")
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
                self.view.backgroundColor = UIColor.white
                printt("UNKNOWN")
            case .far:
                self.view.backgroundColor = UIColor.cyan
                printt("FAR")
            case .near:
                self.view.backgroundColor = UIColor.yellow
                printt("NEAR")
            case .immediate:
                self.view.backgroundColor = UIColor.red
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
