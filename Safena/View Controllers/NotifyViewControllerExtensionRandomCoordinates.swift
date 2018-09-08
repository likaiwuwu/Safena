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
            
            let user1 = NotifyUserModel(accountID: accountID1, name: NotifyNameModel(firstName: "Ashley", lastName: "Smoker"), location: CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude), isNotifying: false)
            let user2 = NotifyUserModel(accountID: accountID2, name: NotifyNameModel(firstName: "Li-Chun", lastName: "Wu"), location: CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude), isNotifying: false)
            let user3 = NotifyUserModel(accountID: accountID3, name: NotifyNameModel(firstName: "John", lastName: "Atanacio"), location: CLLocation(latitude: coordinate3.latitude, longitude: coordinate3.longitude), isNotifying: false)
            let user4 = NotifyUserModel(accountID: accountID4, name: NotifyNameModel(firstName: "Edward", lastName: "Sweeney"), location: CLLocation(latitude: coordinate4.latitude, longitude: coordinate4.longitude), isNotifying: false)

            user1.postAsUserOnFRD()
            user2.postAsUserOnFRD()
            user3.postAsUserOnFRD()
            user4.postAsUserOnFRD()
            
            user1.updateLocationCoordinate(coordinate: coordinate1)
            user2.updateLocationCoordinate(coordinate: coordinate2)
            user3.updateLocationCoordinate(coordinate: coordinate3)
            user4.updateLocationCoordinate(coordinate: coordinate4)
        }
    }
}
