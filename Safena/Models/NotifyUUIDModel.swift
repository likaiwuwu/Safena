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
    // Monitoring/Ranging Beacons
    var monitoringRangingBeacons: [String:String]

    init (uuid: String = UUID().uuidString, monitoringRangingBeacons: [String:String] = [String:String]()) {
        self.uuidString = uuid
        // Monitoring/Ranging Beacons
        self.monitoringRangingBeacons = monitoringRangingBeacons
    }
    
    init () {
        self.uuidString = UUID().uuidString
        self.monitoringRangingBeacons = [String:String]()
    }
    
}
