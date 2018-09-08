//
//  NotifyViewControllerExtensionPeripheralManagerDelegate.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/8/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import CoreBluetooth

extension NotifyViewController: CBPeripheralManagerDelegate {

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        printt("""
            Peripheral is advertising: \(peripheral.isAdvertising)
            ERROR: \(error?.localizedDescription ?? "No localized description")
            ERROR DEBUG DESCRIPTION: \(error.debugDescription)
            """)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("""
            Peripheral delegate is \(String(describing: peripheral.delegate))
            Peripheral is advertisting\(peripheral.isAdvertising)
            """)
    }

}
