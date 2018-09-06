//
//  NotifyViewController.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/1/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import CoreBluetooth

class NotifyViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {
    
    var ref: DatabaseReference!
    var refUsers: DatabaseReference!
    
    let locationManager = CLLocationManager()
    let centralManager = CBCentralManager()
    
    var peripheralData: Dictionary<String, Any> = [:]
    
    var userList = [UserModel]()
    var notifyingUserList = [UserModel]()
    var fakeUser = UserModel()
    
    //MARK:- Enums
    
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
    
    //MARK:- Outlets
    
    @IBOutlet weak var notifyButtonOutlet: UIButton!
    @IBOutlet weak var bystanderTableView: UITableView!
    
    //MARK:- Actions
    
    @IBAction func notifyButtonAction(_ sender: UIButton) {
//        print(" ")
//        print(" ")
//        print("BEFORE-- ||Notify Button Action||")
        if fakeUser.isNotifying == false {
//            print("IN -- ||Notify Button Action: isNotifying == false||")//            print()
//            print("BEFORE -- ||advertiseDevice(region: \(fakeUser.asBeaconRegion().debugDescription)||")
            advertiseDevice(region: fakeUser.asBeaconRegion())
//            print("AFTER -- ||advertiseDevice(region: \(fakeUser.asBeaconRegion().debugDescription)||")
//            print()
//            print("BEFORE -- ||fakeUser.updateIsNotifying(isNotifying: true)|| fakeUser.isNotifying == \(fakeUser.isNotifying)")
            fakeUser.updateIsNotifying(isNotifying: true)
//            print("AFTER -- ||fakeUser.updateIsNotifying(isNotifying: true)|| fakeUser.isNotifying == \(fakeUser.isNotifying)")
//            print()
//            print("BEFORE -- fakeUser.updateVictimUUID(userList: \(userList.debugDescription), uuidString: \(fakeUser.uuidString.debugDescription)")
            fakeUser.updateVictimUUID(userList: userList, uuidString: fakeUser.uuidString)
//            print("AFTER -- fakeUser.updateVictimUUID(userList: \(userList.debugDescription), uuidString: \(fakeUser.uuidString.debugDescription)")
        } else {
//            print("IN -- ||Notify Button Action: isNotifying == true||")
//            print()
//            print("BEFORE -- ||fakeUser.updateIsNotifying(isNotifying: false)|| fakeUser.isNotifying == \(fakeUser.isNotifying)")
            fakeUser.updateIsNotifying(isNotifying: false)
//            print("AFTER -- ||fakeUser.updateIsNotifying(isNotifying: false)|| fakeUser.isNotifying\(fakeUser.isNotifying)")
//            print()
//            print("BEFORE -- ||fakeUser.updateVictimUUID(userList: \(userList.debugDescription), uuidString: ||")
            fakeUser.updateVictimUUID(userList: userList, uuidString: "")
//            print("AFTER -- ||fakeUser.updateVictimUUID(userList: \(userList.debugDescription), uuidString: ||")
        }
//        print()
//        print("Out of Notify Button Action if/else statement")
//        print()
//        print("BEFORE -- ||sender.isSelected = fakeUser.isNotifying||")
//        print("BEFORE -- sender.isSelected = \(sender.isSelected.description)")
//        print("BEFORE -- fakeUser.isNotifying = \(fakeUser.isNotifying)")
        sender.isSelected = fakeUser.isNotifying
//        print("AFTER -- ||sender.isSelected = fakeUser.isNotifying||")
//        print("AFTER -- sender.isSelected = \(sender.isSelected.description)")
//        print("AFTER -- fakeUser.isNotifying = \(fakeUser.isNotifying)")
//        print()
//        print("BEFORE -- ||self.bystanderTableView.reloadData()|| self.bystanderTableView == \(self.bystanderTableView.description)")
        self.bystanderTableView.reloadData()
//        print("AFTER -- ||self.bystanderTableView.reloadData()|| self.bystanderTableView == \(self.bystanderTableView.description)")
//        print()
//        print(" ")
//        print(" ")
    }
    
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // References
        refUsers = Database.database().reference().child(FRDKeys.Users)
        
        
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            configureLocationManager(desiredAccuracy: kCLLocationAccuracyBest, allowsBackgroundLocationUpdates: true, distanceFilter: 1)
            locationManager.startUpdatingLocation()
            locationManager.showsBackgroundLocationIndicator = true
            // TODO: Desired Accuracy should be edited through the settings.
        }
        
        // Initializiation
        //TODO:- accountID here should be an ID from Firebase Authentication.
        //        accountID = refUsers.childByAutoId().key
        
        //MARK:- FAKE INITIALIZATION (WILL BE REPLACED WITH FIREBASE AUTH)
        fakeUser = UserModel(accountID: refUsers.childByAutoId().key, name: NameModel(firstName: "Self-Li-Kai", lastName: "Self-Wu"), coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        fakeUser.postAsUserOnFRD()
        
        // TableView
        bystanderTableView.delegate = self
        bystanderTableView.dataSource = self
        bystanderTableView.rowHeight = 44.0
        
        // Nib Registration
        let cellNib = UINib(nibName: "BystanderTableViewCell", bundle: nil)
        bystanderTableView.register(cellNib, forCellReuseIdentifier: "BystanderTableViewCell")
        
        // Button Configuration
        notifyButtonOutlet.setTitle("Notifying", for: .selected)
        notifyButtonOutlet.setTitle("Notify", for: .normal)
        
        // Location Manager Configuration
        //fillRandomCoordinatesToFRD()
        observeValueUserInformationFromFRD()
        //readCoordinatesFromFRD()
        
        //DELETE LATER
        refUsers.child(fakeUser.accountID).onDisconnectRemoveValue()

    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch (peripheral.state) {
        case .poweredOn:
            peripheral.startAdvertising(peripheralData)
            break;
        case .poweredOff:
            peripheral.stopAdvertising()
            break;
        case .unsupported:
            print("Device is unsupported!")
            break;
        default:
            break;
        }
    }
    
    func stopMonitoringUser(user: UserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        print("STOP MONITORING FOR: \(beaconRegion.debugDescription)")
        locationManager.stopRangingBeacons(in: beaconRegion)
        print("STOP RANGING FOR: \(beaconRegion.debugDescription)")
    }
    
    func startMonitoringUser(user: UserModel) {
        print("IN startMonitoringUser Function")
        let beaconRegion = user.asBeaconRegion()
        print("BEACON REGION: \(beaconRegion.debugDescription)")
        locationManager.startMonitoring(for: beaconRegion)
        print("START MONITORING FOR: \(beaconRegion.debugDescription)")
        locationManager.startRangingBeacons(in: beaconRegion)
        print("START RANGING FOR: \(beaconRegion.debugDescription)")
    }
    
    //MARK:- iBeacon
    
    func advertiseDevice(region : CLBeaconRegion) {
        peripheralData = region.peripheralData(withMeasuredPower: nil) as! Dictionary<String, Any>
        _ = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    //MARK:- Firebase Realtime Database
    
    func observeValueUserInformationFromFRD() {
        refUsers.observe(.value, with: { snapshot in
            //if the reference have some values
            if snapshot.hasChildren() {
                //clearing the list
                self.userList.removeAll()
                
                //iterating through all the values
                for userObject in snapshot.children {
                    // Getting let userObject = user.value as? [String: AnyObject]
                    // Getting account id
                    let user1 = userObject as! DataSnapshot
                    let user = user1.value as! [String: Any]
                    
                    let userAccountID = user[FRDKeys.AccountID] as? String ?? "N/A"

                    let userCoordinate = user[FRDKeys.Coordinate] as? CLLocationCoordinate2D
                    // Getting Name
                    let userName = user[FRDKeys.Name] as! [String: String]
                    let userFirstName = userName[FRDKeys.FirstName] ?? ""
                    let userLastName = userName[FRDKeys.LastName] ?? ""
                    let newUserModel = NameModel(firstName: userFirstName , lastName: userLastName)
                    // Getting is notifying
                    let userIsNotifying = user[FRDKeys.IsNotifying] as! Bool
                    // Getting user UUID
                    let userUUIDString = UUID(uuidString: (user[FRDKeys.UUID] as! String))
                    // Getting user victim UUID
                    let userVictimUUIDString = UUID(uuidString: user[FRDKeys.VictimUUID] as! String)
                    
                    // Creating artist object with model and fetched values
                    let userModel = UserModel(accountID: userAccountID, name: newUserModel, coordinate: userCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), isNotifying: userIsNotifying, uuid: userUUIDString ?? UUID(), victimUUID: userVictimUUIDString ?? UUID())
                    //appending it to list
                    self.userList.append(userModel)
                }
                print(self.userList.debugDescription)
                //reloading the tableview
                self.bystanderTableView.reloadData()
            }
        })
    }
}
