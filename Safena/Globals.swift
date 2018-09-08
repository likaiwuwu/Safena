//
//  Globals.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/9/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

// References to the Firebase Realtime Database
var ref = Database.database().reference()
var refUsers = ref.child("Users")


// Print function for debugging.
func printt(_ message: String = "") {
    print()
    print(message)
    print()
}

//MARK:- Enums

enum FRDKeys {
    
    // Just the Child Key
    static let AccountID = "Account ID"
    static let NotifyNameModel = "Notify Name Model"
    static let FirstName = "First Name"
    static let LastName = "Last Name"
    static let Location = "Location"
    static let Coordinate = "Coordinate"
    static let Latitude = "Latitude"
    static let Longitude = "Longitude"
    static let NotifyUUIDModel = "Notify UUID Model"
    static let Users = "Users"
    static let UUIDUser = "User UUID"
    static let UUIDVictim = "Victim UUID"
    static let UUIDPreviousVictim = "Previous Victim UUID"
    static let IsNotifying = "Is Notifying"
    
    // Path to Child Key
    static let ToFirstName = "Notify Name ModelFirst Name"
    static let ToLastName = "Notify Name ModelLast Name"
    static let ToCoordinate = "Location/Coordinate"
    static let ToLatitude = "Location/Coordinate/Latitude"
    static let ToLongitude = "Location/Coordinate/Longitude"
    static let ToUUIDUser = "Notify UUID Model/User UUID"
    static let ToUUIDVictim = "Notify UUID Model/Victim UUID"
    static let ToUUIDPreviousVictim = "Notify UUID Model/Previous Victim UUID"
}
