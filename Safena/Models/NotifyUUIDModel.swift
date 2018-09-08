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
    var uuidVictimString: String
    var uuidPreviousVictimString: String
    
    init (uuid: String = UUID().uuidString, uuidVictim: String, uuidPreviousVictim: String) {
        self.uuidString = uuid
        self.uuidVictimString = uuidVictim
        self.uuidPreviousVictimString = uuidPreviousVictim
    }
    
    init () {
        uuidString = UUID().uuidString
        uuidVictimString = ""
        uuidPreviousVictimString = ""
    }
    
    func getUUID() -> String {
        return self.uuidString
    }
    
    func getUUIDVictim() -> String {
        return self.uuidVictimString
    }
    
    func getUUIDPreviousVictim() -> String {
        return self.uuidPreviousVictimString
    }
    
}
