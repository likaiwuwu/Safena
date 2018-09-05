//
//  NotifyViewControllerExtension.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation

extension NotifyViewController {
    func fillRandomCoordinatesToFRD() {
        for index in 1...15 {
            
            // AccountID generation.
            let accountID1 = refUsers.childByAutoId().key
            let accountID2 = refUsers.childByAutoId().key
            let accountID3 = refUsers.childByAutoId().key
            let accountID4 = refUsers.childByAutoId().key
            
            // Write coordinates.
            updateUserCoordiantesToFRD(withLatitude: (userLatitude) - Double(index), withLongitude: (userLongitude) - Double(index), withAccountID: accountID1)
            updateUserCoordiantesToFRD(withLatitude: (userLatitude) + Double(index), withLongitude: (userLongitude) + Double(index), withAccountID: accountID2)
            updateUserCoordiantesToFRD(withLatitude: (userLatitude) - Double(index), withLongitude: (userLongitude) + Double(index), withAccountID: accountID3)
            updateUserCoordiantesToFRD(withLatitude: (userLatitude) + Double(index), withLongitude: (userLongitude) - Double(index), withAccountID: accountID4)
            
            // Write user information.
            refUsers.child("\(accountID1)").updateChildValues(
                [FRDKeys.Name: [FRDKeys.FirstName: "Li-Kai\(index)", FRDKeys.LastName: "Wu\(-index)"],
                 FRDKeys.IsNotifying: arc4random_uniform(2) == 1 ? true : false,
                 FRDKeys.AccountID: accountID1,
                 FRDKeys.UUID: UUID().uuidString,
                 FRDKeys.FilterDistance: index])
            refUsers.child("\(accountID2)").updateChildValues(
                [FRDKeys.Name: [FRDKeys.FirstName: "Li-Kai\(index)", FRDKeys.LastName: "Wu\(-index)"],
                 FRDKeys.IsNotifying: arc4random_uniform(2) == 1 ? true : false,
                 FRDKeys.AccountID: accountID2,
                 FRDKeys.UUID: UUID().uuidString,
                 FRDKeys.FilterDistance: index])
            refUsers.child("\(accountID3)").updateChildValues(
                [FRDKeys.Name: [FRDKeys.FirstName: "Li-Kai\(index)", FRDKeys.LastName: "Wu\(-index)"],
                 FRDKeys.IsNotifying: arc4random_uniform(2) == 1 ? true : false,
                 FRDKeys.AccountID: accountID3,
                 FRDKeys.UUID: UUID().uuidString,
                 FRDKeys.FilterDistance: index])
            refUsers.child("\(accountID4)").updateChildValues(
                [FRDKeys.Name: [FRDKeys.FirstName: "Li-Kai\(index)", FRDKeys.LastName: "Wu\(-index)"],
                 FRDKeys.IsNotifying: arc4random_uniform(2) == 1 ? true : false,
                 FRDKeys.AccountID: accountID4,
                 FRDKeys.UUID: UUID().uuidString,
                 FRDKeys.FilterDistance: index])
        }
    }
}
