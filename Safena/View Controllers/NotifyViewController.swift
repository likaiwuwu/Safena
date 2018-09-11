//
//  NotifyViewController.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/1/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import CoreBluetooth
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class NotifyViewController: UIViewController {
    
    // MARK:- Managers
    
    var locationManager: CLLocationManager!
    var peripheralManager: CBPeripheralManager!
    
    // MARK:- Properties
    
    var userList = [NotifyUserModel]() {
        didSet {
            self.bystanderTableView.reloadData()
        }
    }
    var currentUser = NotifyUserModel()
    var temporaryUser: NotifyUserModel!
    var temporaryDecision: Bool!
    var temporaryUsers = [NotifyUserModel]()
    
    //MARK:- Outlets
    
    @IBOutlet weak var notifyButtonOutlet: UIButton!
    @IBOutlet weak var bystanderTableView: UITableView!
    
    //MARK:- Actions
    
    @IBAction func notifyButtonAction(_ sender: UIButton) {
        if currentUser.isNotifying == false {
            advertiseDevice(region: currentUser.asBeaconRegion())
            currentUser.updateIsNotifying(isNotifying: true)
            currentUser.addAccountIDToNearbyUsersMonitoringAndRangingBeacons()
        } else {
            peripheralManager.stopAdvertising()
            currentUser.updateIsNotifying(isNotifying: false)
            currentUser.removeAccountIDToNearbyUsersMonitoringAndRangingBeacons()
            for monitoringBeacon in currentUser.uuid.monitoringRangingBeacons {
                if let user = findUserFromUserList(accountID: monitoringBeacon.key) {
                    locationManager.stopMonitoring(for: user.asBeaconRegion())
                    locationManager.stopRangingBeacons(in: user.asBeaconRegion())
                }
            }
        }
        sender.isSelected = currentUser.isNotifying
    }
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        peripheralManager = CBPeripheralManager()
        
        // Managers
        locationManager.delegate = self
        peripheralManager.delegate = self
        
        // Location Manager Configurations
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.distanceFilter = 0.1
        }
        
        //                let accountID = Auth.auth().currentUser?.uid
        //                let name = Auth.auth().currentUser?.displayName
        //                let splitName = name?.split(separator: " ")
        //                let firstName = String(splitName?[0] ?? "N/A")
        //                let lastName = String(splitName?[1] ?? "N/A")
        currentUser = NotifyUserModel(accountID: refUsers.childByAutoId().key, name: NotifyNameModel(firstName: "Li-Kai", lastName: "Wu"), location: locationManager.location!, uuid: NotifyUUIDModel(), isOnline: false)
        currentUser.postAsUserOnFRD()
        
        // TableView
        bystanderTableView.delegate = self
        bystanderTableView.dataSource = self
        bystanderTableView.rowHeight = 88
        
        // Button Configuration
        notifyButtonOutlet.setTitle("Notifying", for: .selected)
        notifyButtonOutlet.setTitle("Notify", for: .normal)
        
        // Nib Registration
        let cellNib = UINib(nibName: "BystanderTableViewCell", bundle: nil)
        bystanderTableView.register(cellNib, forCellReuseIdentifier: "BystanderTableViewCell")
        
        // Firebase Realtime Database Configurations
        observeValueUserFromFRD()
        observeAddedMonitoringRangingBeacons()
        observeRemovedMonitoringBeacon()
        
        //DELETE LATER
        refUsers.child(currentUser.accountID).onDisconnectRemoveValue()
        
    }
    
    
    //Starts both monitoring and ranging for parameter user beacon.
    //    func startMonitoringAndRangingUser(user: NotifyUserModel) {
    //        printt("Started Monitoring: \(user)")
    //        let beaconRegion = user.beaconRegion
    //        locationManager.startMonitoring(for: beaconRegion)
    //        locationManager.startRangingBeacons(in: beaconRegion)
    //    }
    //
    //    //Stops both monitoring and ranging for parameter user beacon.
    //    func stopMonitoringAndRangingUser(user: NotifyUserModel) {
    //        printt("Stopped Monitoring: \(user)")
    //        let beaconRegion = user.beaconRegion
    //        locationManager.stopMonitoring(for: beaconRegion)
    //        locationManager.stopRangingBeacons(in: beaconRegion)
    //    }
    
    // Begins advertising parameter CLBeaconRegion.
    func advertiseDevice(region : CLBeaconRegion) {
        printt("advertiseDevice")
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    //MARK:- Firebase Realtime Database
    
    // Observes the victim uuid from the user's Firebase Realtime Database. When a change is observed,
    // starts/stops monitoring/ranging and updates previous victim UUID, as well.
    func observeAddedMonitoringRangingBeacons() {
        refUsers.child("\(currentUser.accountID)/\(FRDKeys.NotifyUUIDModel)/\(FRDKeys.MonitoringRangingBeacons)").observe(.childAdded) { (snapshot) in
            let addedMonitoringBeaconAccountID = snapshot.value as! String
            guard let user = self.findUserFromUserList(accountID: addedMonitoringBeaconAccountID) else {
                printt("Unable to create NotifyUserModel from provided Account ID")
                return }
            if (self.currentUser.isNotifying == false) {
                let alert = UIAlertController(title: "Request for Connection", message: "A nearby user is in danger! Agree to connect and share location information with the user?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Connect", style: UIAlertAction.Style.default, handler: { action in
                    user.addMonitoringAccountID(forAccountID: self.currentUser.accountID)
                    self.advertiseDevice(region: self.currentUser.asBeaconRegion())
                    self.locationManager.startMonitoring(for: user.asBeaconRegion())
                    self.locationManager.startRangingBeacons(in: user.asBeaconRegion())
                }))
                alert.addAction(UIAlertAction(title: "Reject", style: UIAlertAction.Style.default, handler: { action in
                    print("Rejected")
                    self.currentUser.removeMonitoringAccountID(forAccountID: addedMonitoringBeaconAccountID)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.locationManager.startMonitoring(for: user.asBeaconRegion())
                self.locationManager.startRangingBeacons(in: user.asBeaconRegion())
            }
        }
    }
    
//    func observeAddedRangingBeacon() {
//        printt("observeAddedRangingBeacon()")
//        refUsers.child("\(currentUser.accountID)/\(FRDKeys.NotifyUUIDModel)/\(FRDKeys.RangingBeacons)").observe(.childAdded) { (snapshot) in
//            let addedRangingBeaconAccountID = snapshot.value as! String
//            guard let user = self.findUserFromUserList(accountID: addedRangingBeaconAccountID) else {
//                printt("Unable to create NotifyUserModel from provided Account ID")
//                return }
//            if (self.currentUser.isOnline == false) {
//                    self.advertiseDevice(region: self.currentUser.asBeaconRegion())
//                    self.locationManager.startMonitoring(for: user.asBeaconRegion())
//                    self.currentUser.removeMonitoringAccountID(forAccountID: addedMonitoringBeaconAccountID)
//                    self.currentUser.removeRangingAccountID(forAccountID: addedMonitoringBeaconAccountID)
//                }))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                self.locationManager.startMonitoring(for: user.asBeaconRegion())
//            }
//        }
//    }
    
    func observeRemovedMonitoringBeacon() {
        refUsers.child("\(currentUser.accountID)/\(FRDKeys.NotifyUUIDModel)/\(FRDKeys.MonitoringRangingBeacons)").observe(.childRemoved) { (snapshot) in
            let removedMonitoringBeaconAccountID = snapshot.value as! String
            guard let user = self.findUserFromUserList(accountID: removedMonitoringBeaconAccountID) else {
                printt("Unable to create NotifyUserModel from provided Account ID")
                return
            }
            if (self.currentUser.uuid.monitoringRangingBeacons.isEmpty) {
                self.peripheralManager.stopAdvertising()
            }
            self.locationManager.stopMonitoring(for: user.asBeaconRegion())
            self.locationManager.stopRangingBeacons(in: user.asBeaconRegion())
        }
    }
    
//    func observeRemovedRangingBeacon() {
//        refUsers.child("\(currentUser.accountID)/\(FRDKeys.NotifyUUIDModel)/\(FRDKeys.RangingBeacons)").observe(.childRemoved) { (snapshot) in
//            let removedRangingBeaconAccountID = snapshot.value as! String
//            self.currentUser.removeRangingAccountID(forAccountID: removedRangingBeaconAccountID)
//            if let user = self.findUserFromUserList(accountID: removedRangingBeaconAccountID) {
//                self.locationManager.stopRangingBeacons(in: user.asBeaconRegion())
//            } else {
//                printt("Unable to create NotifyUserModel from provided Account ID")
//            }
//        }
//    }
    
    // Observes users Firebase Realtime Database. When a change is observed,
    // userList is updated.
    func observeValueUserFromFRD() {
        refUsers.observe(.value, with: { snapshot in
            if (snapshot.hasChildren()) {
                self.userList.removeAll()
                for userObject in snapshot.children {
                    let user1 = userObject as! DataSnapshot
                    let userModel = self.readUserInformation(user1: user1)
                    if (userModel.accountID != self.currentUser.accountID) {
                        self.userList.append(userModel)
                    }
                }
            }
        })
    }
    
    func readUserInformation(user1: DataSnapshot) -> NotifyUserModel {
        let user = user1.value as! [String: Any]
        
        // Getting Account ID
        let userAccountID = user[FRDKeys.AccountID] as! String
        
        // Getting Location
        let userLocation = user[FRDKeys.Location] as! [String: Any]
        let userCoordinate = userLocation[FRDKeys.Coordinate] as! [String: Any]
        let userLatitude = userCoordinate[FRDKeys.Latitude] as! CLLocationDegrees
        let userLongitude = userCoordinate[FRDKeys.Longitude] as! CLLocationDegrees
        let location = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        // Getting Notify Name Model
        let userName = user[FRDKeys.NotifyNameModel] as! [String: Any]
        let userNameFirst = userName[FRDKeys.FirstName] as! String
        let userNameLast = userName[FRDKeys.LastName] as! String
        let name = NotifyNameModel(firstName: userNameFirst , lastName: userNameLast)
        
        // Getting is notifying
        let userIsNotifying = user[FRDKeys.isNotifying] as! Bool
        
        let userUUID = user[FRDKeys.NotifyUUIDModel] as! [String: Any]
        // Getting user UUID
        let userUUIDUser = userUUID[FRDKeys.UUIDUser] as! String
        
        // Getting monitoring beacons
        var monitoringRangingBeacons = [String:String]()
        if (userUUID[FRDKeys.MonitoringRangingBeacons] != nil) {
            let userMonitoringRangingBeaconsDictionary1 = userUUID[FRDKeys.MonitoringRangingBeacons] as! [String:String]
            for pair in userMonitoringRangingBeaconsDictionary1 {
                monitoringRangingBeacons.updateValue(pair.value, forKey: pair.key)
            }
        }
        let uuid = NotifyUUIDModel(uuid: userUUIDUser, monitoringRangingBeacons: monitoringRangingBeacons)
        
        // Creating artist object with model and fetched values
        return NotifyUserModel(accountID: userAccountID, name: name, location: location, uuid: uuid, isOnline: userIsNotifying)
    }
    
    // Finds user object from userList.
    func findUserFromUserList(accountID: String) -> NotifyUserModel? {
        for user in userList {
            if user.accountID == accountID {
                return user
            }
        }
        return nil
    }
    
}
