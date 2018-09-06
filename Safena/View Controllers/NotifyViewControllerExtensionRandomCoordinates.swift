//
//  NotifyViewControllerExtension.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/3/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import CoreLocation

extension NotifyViewController {
    
    func fillRandomCoordinatesToFRD() {
        for index in 1...2 {
            
            // AccountID generation.
            let accountID1 = refUsers.childByAutoId().key
            let accountID2 = refUsers.childByAutoId().key
            let accountID3 = refUsers.childByAutoId().key
            let accountID4 = refUsers.childByAutoId().key
            
            // Write coordinates.
            
            let coordinate1 = CLLocationCoordinate2D(latitude: CLLocationDegrees(index), longitude: CLLocationDegrees(index))
            let coordinate2 = CLLocationCoordinate2D(latitude: CLLocationDegrees(-index), longitude: CLLocationDegrees(-index))
            let coordinate3 = CLLocationCoordinate2D(latitude: CLLocationDegrees(index), longitude: CLLocationDegrees(-index))
            let coordinate4 = CLLocationCoordinate2D(latitude: CLLocationDegrees(-index), longitude: CLLocationDegrees(index))
            
            let user1 = UserModel(accountID: accountID1, name: NameModel(firstName: "Ashley", lastName: "Smoker"), coordinate: coordinate1, isNotifying: false)
            let user2 = UserModel(accountID: accountID2, name: NameModel(firstName: "Lichun", lastName: "Wu"), coordinate: coordinate2, isNotifying: false)
            let user3 = UserModel(accountID: accountID3, name: NameModel(firstName: "John", lastName: "Atanacio"), coordinate: coordinate3, isNotifying: false)
            let user4 = UserModel(accountID: accountID4, name: NameModel(firstName: "Edward", lastName: "Sweeney"), coordinate: coordinate4, isNotifying: false)
            
            user1.postAsUserOnFRD()
            user2.postAsUserOnFRD()
            user3.postAsUserOnFRD()
            user4.postAsUserOnFRD()
            
            user1.updateCoordinate(coordinate: coordinate1)
            user2.updateCoordinate(coordinate: coordinate2)
            user3.updateCoordinate(coordinate: coordinate3)
            user4.updateCoordinate(coordinate: coordinate4)
        }
    }
}
