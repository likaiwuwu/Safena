//
//  UserModel.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase

class UserModel {
    
    // Account ID
    var accountID: String
    // Name
    var name: NameModel
    // Location
    var location: CLLocation
    // Coordinate
    // UUID
    var uuidString: String
    // Victim UUID
    var victimUUIDString: String
    // Previous Victim UUID
    var previousVictimUUIDString: String
    // Is Notifying
    var isNotifying: Bool
    
    // Enums
    enum FRDKeys {
        static let AccountID = "Account ID"
        static let Name = "Name"
        static let FirstName = "First Name"
        static let LastName = "Last Name"
        static let Location = "Location"
        static let Coordinate = "Coordinate"
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
        static let UUID = "UUID"
        static let Users = "Users"
        static let VictimUUID = "Victim UUID"
        static let PreviousVictimUUID = "Previous Victim UUID"
        static let IsNotifying = "Is Notifying"
    }
    
    init(accountID: String = "", name: NameModel = NameModel(), location: CLLocation = CLLocation(), uuidString: String = "", victimUUIDString: String = "", previousVictimUUID: String = "", isNotifying: Bool = false) {
        self.accountID = accountID
        self.name = name
        self.location = location
        self.uuidString = UUID().uuidString
        self.victimUUIDString = ""
        self.previousVictimUUIDString = ""
        self.isNotifying = isNotifying
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: UUID(uuidString: uuidString)!, major: 1, minor: 1, identifier: name.name())
    }
    
    func postAsUserOnFRD() {
        let name = [FRDKeys.FirstName: self.name.firstName, FRDKeys.LastName: self.name.lastName]
        let coordinate = [FRDKeys.Latitude: Int(self.location.coordinate.latitude), FRDKeys.Longitude: Int(self.location.coordinate.longitude)]
        let location = [FRDKeys.Coordinate: coordinate]
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues(
            [FRDKeys.AccountID: accountID,
             FRDKeys.Name: name,
             FRDKeys.Location: location,
             FRDKeys.IsNotifying: isNotifying,
             FRDKeys.UUID: uuidString,
             FRDKeys.VictimUUID: victimUUIDString,
             FRDKeys.PreviousVictimUUID: previousVictimUUIDString
            ]
        )
    }
    
    // Public Updates
    
    func updateIsNotifying(isNotifying: Bool) {
        self.isNotifying = isNotifying
        updateSelfValue(key: FRDKeys.IsNotifying, value: isNotifying as Bool)
    }
    
    func updateLocationCoordinate(coordinate: CLLocationCoordinate2D) {
        let coordinatePost = [FRDKeys.Latitude: coordinate.latitude,
                              FRDKeys.Longitude: coordinate.longitude]
        updateSelfValue(key: "\(FRDKeys.Location)/\(FRDKeys.Coordinate)", value: coordinatePost)
    }
    
    func renewUUID() {
        updateUUID(uuid: UUID().uuidString)
    }
    
    func updateUUID(uuid: String) {
        self.uuidString = uuid
        updateSelfValue(key: FRDKeys.UUID, value: uuidString)
    }
    
    func updateVictimUUID(userList: [UserModel], uuidString: String) {
        userList.forEach { (user) in
            updateValue(accountID: user.accountID, key: FRDKeys.VictimUUID, value: uuidString)
        }
    }
    
    func updatePreviousVictimUUID(previousUUID: String) {
        self.previousVictimUUIDString = previousUUID
        updateSelfValue(key: FRDKeys.PreviousVictimUUID, value: previousVictimUUIDString)
    }
    
    // Private Updates
    
    private func updateSelfValue(key: String, value: Any) {
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues([key : value])
    }
    
    private func updateValue(accountID: String, key: String, value: Any) {
        Database.database().reference().child(FRDKeys.Users).child(accountID).updateChildValues([key : value])
    }
    
    // Equitable
    
    static func ==(user1: UserModel, user2: UserModel) -> Bool {
        return (user1.accountID == user2.accountID)
    }
    
    static func !=(user1: UserModel, user2: UserModel) -> Bool {
        return !(user1 == user2)
    }
    
}
