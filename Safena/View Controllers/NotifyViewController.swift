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

var ref = Database.database().reference()
var refUsers = ref.child("Users")

//MARK:- Enums

enum FRDKeys {
    // Just Child
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
    
    // Everything to Child
    
    static let ToFirstName = "Notify Name ModelFirst Name"
    static let ToLastName = "Notify Name ModelLast Name"
    static let ToCoordinate = "Location/Coordinate"
    static let ToLatitude = "Location/Coordinate/Latitude"
    static let ToLongitude = "Location/Coordinate/Longitude"
    static let ToUUIDUser = "Notify UUID Model/User UUID"
    static let ToUUIDVictim = "Notify UUID Model/Victim UUID"
    static let ToUUIDPreviousVictim = "Notify UUID Model/Previous Victim UUID"
    
}

//CBPeripheralManagerDelegate
//CBCentralManagerDelegate
class NotifyViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    
    let locationManager = CLLocationManager()
    var centralManager = CBCentralManager()
    var peripheralManager = CBPeripheralManager()
    
    var myPeripheral: CBPeripheral!
    var peripheralData: Dictionary<String, Any> = [:]
    
    var userList = [NotifyUserModel]()
    var notifyingUserList = [NotifyUserModel]()
    var fakeUser = NotifyUserModel()
    
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
        self.bystanderTableView.reloadData()
    }
    
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fakeUser = NotifyUserModel(accountID: refUsers.childByAutoId().key, name: NotifyNameModel(firstName: "Self-Li-Kai", lastName: "Self-Wu"), location: CLLocation(latitude: 0, longitude: 0), uuid: NotifyUUIDModel())
        fakeUser.postAsUserOnFRD()
        
        //MARK:- FAKE INITIALIZATION (WILL BE REPLACED WITH FIREBASE AUTH)
        
        //        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //        centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
        
        
        locationManager.delegate = self
        peripheralManager.delegate = self
        centralManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            configureLocationManager(desiredAccuracy: kCLLocationAccuracyBest, allowsBackgroundLocationUpdates: true, distanceFilter: 1)
            locationManager.startUpdatingLocation()
            locationManager.showsBackgroundLocationIndicator = true
        }
        
        observeValueUserFromFRD()
        observeVictimUUIDFromUUID()
        
        //DELETE LATER
        refUsers.child(fakeUser.accountID).onDisconnectRemoveValue()
        
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) { [unowned self] in
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                print("UNKNOWN")
                
            case .far:
                self.view.backgroundColor = UIColor.blue
                print("FAR")
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                print("NEAR")
                
            case .immediate:
                self.view.backgroundColor = UIColor.red
                print("IN FRONT")
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch (peripheral.state) {
        case .poweredOn:
            print("peripheral.state is .poweredOn")
            break;
        case .poweredOff:
            print("peripheral.state is .poweredOff")
            break;
        case .unsupported:
            print("peripheral.state is .unsupported")
            break;
        default:
            break;
        }
    }
    
    func stopMonitoringAndRangingUser(user: NotifyUserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: STOP MONITORING FOR: \(beaconRegion.debugDescription)")
        locationManager.stopRangingBeacons(in: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: STOP RANGING FOR: \(beaconRegion.debugDescription)")
    }
    
    func startMonitoringAndRangingUser(user: NotifyUserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: START MONITORING FOR: \(beaconRegion.debugDescription)")
        locationManager.startRangingBeacons(in: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: START RANGING FOR: \(beaconRegion.debugDescription)")
    }
    
    //MARK:- iBeacon
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        //        myPeripheral = peripheral
    }
    
    func advertiseDevice(region : CLBeaconRegion) {
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Peripheral is advertising: \(peripheral.isAdvertising)")
        print("ERROR: \(error?.localizedDescription ?? "No localized description")")
        print("ERROR DEBUG DESCRIPTION: \(error.debugDescription)")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Peripheral delegate is \(String(describing: peripheral.delegate))")
        print("Peripheral is advertisting\(peripheral.isAdvertising)")
    }
    
    //MARK:- Firebase Realtime Database
    
    func observeVictimUUIDFromUUID() {
        refUsers.child("\(fakeUser.accountID)/Notify UUID Model/Victim UUID").observe(DataEventType.value) { (snapshot) in
            let victimUUIDString = snapshot.value as! String
            if (victimUUIDString.count != 0) {
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
    
    func findUserFromUserList(uuid: String) -> NotifyUserModel? {
        for user in userList {
            if user.uuid.uuidString == uuid {
                return user
            }
        }
        return nil
    }
    
    func observeValueUserFromFRD() {
        refUsers.observe(.value, with: { snapshot in
            if snapshot.hasChildren() {
                self.userList.removeAll()
                for userObject in snapshot.children {
                    let user1 = userObject as! DataSnapshot
                    let user = user1.value as! [String: Any]
                    
                    let userAccountID = user[FRDKeys.AccountID] as! String
                    
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
                    //                    let distance: CLLocationDistance = locationManager.distance(from: userModel.location)
                    if (userModel.accountID != self.fakeUser.accountID) {
                        self.userList.append(userModel)
                    }
                }
                //reloading the tableview
                self.bystanderTableView.reloadData()
            }
        })
    }
}
