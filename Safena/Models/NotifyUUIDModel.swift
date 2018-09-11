//
//  NotifyUUIDModel.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/8/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import UIKit

class NotifyUUIDModel {
    
    var uuidString: String
    // Monitoring Beacons
    var monitoringBeacons: [Int:String]
    // Ranging Beacons
    var rangingBeacons: [Int:String]

    init (uuid: String = UUID().uuidString, monitoringBeacons: [Int:String] = [Int:String](), rangingBeacons: [Int:String] = [Int:String]()) {
        self.uuidString = uuid
        // Monitoring Beacons
        self.monitoringBeacons = monitoringBeacons
        // Ranging Beacons
        self.rangingBeacons = rangingBeacons
    }
    
    init () {
        self.uuidString = UUID().uuidString
        self.monitoringBeacons = [Int:String]()
        self.rangingBeacons = [Int:String]()
    }
    
}
