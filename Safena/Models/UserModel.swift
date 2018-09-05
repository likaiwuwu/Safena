//
//  UserModel.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import CoreLocation

class UserModel {
    
    var accountID: String
    var name: NameModel
    var filterDistance: Int
    var isNotifying: Bool
    var uuid: UUID
    var uuidString: String
    var victimUUID: UUID
    var victimUUIDString: String
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    
    init(accountID: String, name: NameModel, filterDistance: Int, isNotifying: Bool, uuid: UUID, uuidString: String, victimUUID: UUID, victimUUIDString: String, majorValue: Int = 1, minorValue: Int = 1) {
        self.accountID = accountID
        self.name = name
        self.filterDistance = filterDistance
        self.isNotifying = isNotifying
        self.uuid = uuid
        self.uuidString = uuidString
        self.victimUUID = victimUUID
        self.victimUUIDString = victimUUIDString
        self.majorValue = 1
        self.minorValue = 1
    }
    
    init() {
        self.accountID = ""
        self.name = NameModel()
        self.filterDistance = 0
        self.isNotifying = false
        self.uuid = UUID()
        self.uuidString = ""
        self.victimUUID = UUID()
        self.victimUUIDString = ""
        self.majorValue = 1
        self.minorValue = 1
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: name.name())
    }
}
