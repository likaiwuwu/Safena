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
    
    let locationManager = CLLocationManager()
    var peripheralManager = CBPeripheralManager()
    
    // MARK:- Properties
    
    var userList = [NotifyUserModel]() {
        didSet {
            self.bystanderTableView.reloadData()
        }
    }
    var fakeUser = NotifyUserModel()
    var temporaryUser: NotifyUserModel!
    var decision: Bool!

    
    //MARK:- Outlets
    
    @IBOutlet weak var notifyButtonOutlet: UIButton!
    @IBOutlet weak var bystanderTableView: UITableView!
    
    //MARK:- Actions
    
    @IBAction func notifyButtonAction(_ sender: UIButton) {
        if fakeUser.isNotifying == false {
            advertiseDevice(region: fakeUser.asBeaconRegion())
            fakeUser.updateIsNotifying(isNotifying: true)
            fakeUser.updateVictimUUID(userList: userList, victimUUIDString: fakeUser.uuid.uuidString)
        } else {
            peripheralManager.stopAdvertising()
            fakeUser.updateIsNotifying(isNotifying: false)
            fakeUser.updateVictimUUID(userList: userList, victimUUIDString: "")
        }
        sender.isSelected = fakeUser.isNotifying
    }
    
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Managers
        locationManager.delegate = self
        peripheralManager.delegate = self
        
        let accountID = Auth.auth().currentUser?.uid
        let name = Auth.auth().currentUser?.displayName
        let splitName = name?.split(separator: " ")
        let firstName = String(splitName?[0] ?? "N/A")
        let lastName = String(splitName?[1] ?? "N/A")
        fakeUser = NotifyUserModel(accountID: accountID!, name: NotifyNameModel(firstName: firstName, lastName: lastName), location: locationManager.location!, uuid: NotifyUUIDModel())
        fakeUser.postAsUserOnFRD()
        
        // TableView
        bystanderTableView.delegate = self
        bystanderTableView.dataSource = self
        bystanderTableView.rowHeight = 44.0
        
        // Button Configuration
        notifyButtonOutlet.setTitle("Notifying", for: .selected)
        notifyButtonOutlet.setTitle("Notify", for: .normal)
        
        // Nib Registration
        let cellNib = UINib(nibName: "BystanderTableViewCell", bundle: nil)
        bystanderTableView.register(cellNib, forCellReuseIdentifier: "BystanderTableViewCell")
        
        // Location Manager Configurations
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.distanceFilter = 0.1
        }
        
        // Firebase Realtime Database Configurations
        observeValueUserFromFRD()
        observeVictimUUIDNew()
        
        //DELETE LATER
        refUsers.child(fakeUser.accountID).onDisconnectRemoveValue()
        
    }
    
    
    //Starts both monitoring and ranging for parameter user beacon.
    func startMonitoringAndRangingUser(user: NotifyUserModel) {
        printt("Started Monitoring: \(user)")
        let beaconRegion = user.beaconRegion
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    //Stops both monitoring and ranging for parameter user beacon.
    func stopMonitoringAndRangingUser(user: NotifyUserModel) {
        printt("Stopped Monitoring: \(user)")
        let beaconRegion = user.beaconRegion
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    // Begins advertising parameter CLBeaconRegion.
    func advertiseDevice(region : CLBeaconRegion) {
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    //MARK:- Firebase Realtime Database
    
    // Observes the victim uuid from the user's Firebase Realtime Database. When a change is observed,
    // starts/stops monitoring/ranging and updates previous victim UUID, as well.
    func observeVictimUUIDNew() {
        refUsers.child("\(fakeUser.accountID)/Notify UUID Model/Victim UUID").observe(.value) { (snapshot) in
            let victimUUIDString = snapshot.value as! String
            if (!victimUUIDString.isEmpty) {
                guard self.askForConnectionOnIBeacon() == true else { return }
                if let user = self.findUserFromUserList(uuid: victimUUIDString) {
                    self.fakeUser.updatePreviousVictimUUID(previousUUID: victimUUIDString)
                    self.startMonitoringAndRangingUser(user: user)
                }
            } else {
                if let user = self.findUserFromUserList(uuid: self.fakeUser.uuid.uuidPreviousVictimString) {
                    self.stopMonitoringAndRangingUser(user: user)
                }
            }
        }
    }
    
    func createUserFromFRD(accountID: String) -> NotifyUserModel? {
        refUsers.child(accountID).observeSingleEvent(of: .value) { (snapshot) in
            let userValues = snapshot.value as! [String: Any]
            // Getting Account ID
            let userAccountID = userValues[FRDKeys.AccountID] as! String
            
            // Getting Notify Name Model
            let userName = userValues[FRDKeys.NotifyNameModel] as! [String: Any]
            let userNameFirst = userName[FRDKeys.FirstName] as! String
            let userNameLast = userName[FRDKeys.LastName] as! String
            let name = NotifyNameModel(firstName: userNameFirst , lastName: userNameLast)
            
            // Getting Location
            let userLocation = userValues[FRDKeys.Location] as! [String: Any]
            let userCoordinate = userLocation[FRDKeys.Coordinate] as! [String: Any]
            let userLatitude = userCoordinate[FRDKeys.Latitude] as! CLLocationDegrees
            let userLongitude = userCoordinate[FRDKeys.Longitude] as! CLLocationDegrees
            let location = CLLocation(latitude: userLatitude, longitude: userLongitude)
            
            let userUUID = userValues[FRDKeys.NotifyUUIDModel] as! [String: Any]
            // Getting user UUID
            let userUUIDUser = userUUID[FRDKeys.UUIDUser] as! String
            // Getting user victim UUID
            let userUUIDVictim = userUUID[FRDKeys.UUIDVictim] as! String
            // Getting use previous victim UUID
            let userUUIDPreviousVictim = userUUID[FRDKeys.UUIDPreviousVictim] as! String
            let uuid = NotifyUUIDModel(uuid: userUUIDUser, uuidVictim: userUUIDVictim, uuidPreviousVictim: userUUIDPreviousVictim)
            
            // Getting is notifying
            let userIsNotifying = userValues[FRDKeys.IsNotifying] as! Bool
            
            // Creating artist object with model and fetched values
            self.temporaryUser = NotifyUserModel(accountID: userAccountID, name: name, location: location, uuid: uuid, isNotifying: userIsNotifying)
        }
        return temporaryUser
    }
    
    // Observes users Firebase Realtime Database. When a change is observed,
    // userList is updated.
    func observeValueUserFromFRD() {
        refUsers.observe(.value, with: { snapshot in
            if snapshot.hasChildren() {
                self.userList.removeAll()
                for userObject in snapshot.children {
                    let user1 = userObject as! DataSnapshot
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
                    let userIsNotifying = user[FRDKeys.IsNotifying] as! Bool
                    
                    let userUUID = user[FRDKeys.NotifyUUIDModel] as! [String: Any]
                    // Getting user UUID
                    let userUUIDUser = userUUID[FRDKeys.UUIDUser] as! String
                    // Getting user victim UUID
                    let userUUIDVictim = userUUID[FRDKeys.UUIDVictim] as! String
                    // Getting use previous victim UUID
                    let userUUIDPreviousVictim = userUUID[FRDKeys.UUIDPreviousVictim] as! String
                    let uuid = NotifyUUIDModel(uuid: userUUIDUser, uuidVictim: userUUIDVictim, uuidPreviousVictim: userUUIDPreviousVictim)
                    
                    // Creating artist object with model and fetched values
                    let userModel = NotifyUserModel(accountID: userAccountID, name: name, location: location, uuid: uuid, isNotifying: userIsNotifying)
                    //appending it to list
                    if (userModel.accountID != self.fakeUser.accountID) {
                        self.userList.append(userModel)
                    }
                }
            }
        })
    }
    
    // Finds user object from userList.
    func findUserFromUserList(uuid: String) -> NotifyUserModel? {
        for user in userList {
            if user.uuid.uuidString == uuid {
                return user
            }
        }
        return nil
    }
    
    func askForConnectionOnIBeacon() -> Bool {
        let alert = UIAlertController(title: "Request for Connection", message: "A nearby user is in danger! Agree to connect and share location information with the user?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Connect", style: UIAlertAction.Style.default, handler: { action in
            self.decision = true
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertAction.Style.cancel, handler: { action in
            self.decision = false
        }))
        self.present(alert, animated: true, completion: nil)
        return decision
    }
}
