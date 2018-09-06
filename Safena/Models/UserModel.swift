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
    // Coordinate
    var coordinate: CLLocationCoordinate2D
//    // Filter Distance
//    var filterDistance: Int
    // Is Notifying
    var isNotifying: Bool
    // UUID
    var uuid: UUID
    var uuidString: String
    // Victim UUID
    var victimUUID: UUID
    var victimUUIDString: String
    
    // Enums
    enum FRDKeys {
        static let AccountID = "Account ID"
        static let Coordinate = "Coordinate"
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
        static let FilterDistance = "Filter Distance"
        static let IsNotifying = "Is Notifying"
        static let Name = "Name"
        static let FirstName = "First Name"
        static let LastName = "Last Name"
        static let UUID = "UUID"
        static let Users = "Users"
        static let VictimUUID = "Victim UUID"
    }
    
    init(accountID: String = "", name: NameModel = NameModel(), coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(), isNotifying: Bool = false, uuid: UUID = UUID(), victimUUID: UUID = UUID()) {
        self.accountID = accountID
        self.name = name
        self.coordinate = coordinate
        self.isNotifying = isNotifying
        self.uuid = uuid
        self.uuidString = uuid.uuidString
        self.victimUUID = victimUUID
        self.victimUUIDString = ""
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: name.name())
    }
    
    func postAsUserOnFRD() {
        let name = [FRDKeys.FirstName: self.name.firstName, FRDKeys.LastName: self.name.lastName]
        let coordinate = [FRDKeys.Latitude: Int(self.coordinate.latitude), FRDKeys.Longitude: Int(self.coordinate.longitude)]
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues(
            [FRDKeys.Name: name,
             FRDKeys.Coordinate: coordinate,
             FRDKeys.IsNotifying: isNotifying,
             FRDKeys.AccountID: accountID,
             FRDKeys.UUID: uuidString,
             FRDKeys.VictimUUID: victimUUIDString
            ]
        )
    }
    
    func updateIsNotifying(isNotifying: Bool) {
        self.isNotifying = isNotifying
        updateValue(key: FRDKeys.IsNotifying, value: isNotifying as Bool)
    }
    
    func updateVictimUUID(userList: [UserModel], uuidString: String) {
        print("UpdateVictimUUID\(userList)")
        userList.forEach { (user) in
            updateValue(key: FRDKeys.VictimUUID, value: uuidString)
        }
    }
    
    func renewUUID() {
        updateUUID(uuid: UUID())
    }
    
    func updateUUID(uuid: UUID) {
        self.uuid = uuid
        self.uuidString = uuid.uuidString
        updateValue(key: FRDKeys.UUID, value: uuidString)
    }
    
    func updateUUID(uuid: String) {
        if let realUUID = UUID(uuidString: uuid) {
            self.uuid = realUUID
            self.uuidString = realUUID.uuidString
            updateValue(key: FRDKeys.UUID, value: uuidString)
        }
    }
    
    func updateCoordinate(coordinate: CLLocationCoordinate2D) {
        let coordinatePost = [FRDKeys.Latitude: coordinate.latitude,
                              FRDKeys.Longitude: coordinate.longitude]
        updateValue(key: FRDKeys.Coordinate, value: coordinatePost)
    }
    
    private func updateValue(key: String, value: Any) {
        Database.database().reference().child(FRDKeys.Users).child(self.accountID).updateChildValues([key : value])
    }
}
