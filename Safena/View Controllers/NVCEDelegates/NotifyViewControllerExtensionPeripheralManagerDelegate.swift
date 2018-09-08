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
            PERIPHERAL: \(peripheral)
            ERROR: \(error?.localizedDescription ?? "No localized description")
            """)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Peripheral: \(String(describing: peripheral.delegate))")
    }

}
