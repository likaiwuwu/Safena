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

//CBPeripheralManagerDelegate
//CBCentralManagerDelegate
class NotifyViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    
    var ref: DatabaseReference!
    var refUsers: DatabaseReference!
    
    let locationManager = CLLocationManager()
    var centralManager = CBCentralManager()
    var peripheralManager = CBPeripheralManager()
    
    var myPeripheral: CBPeripheral!
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
        if fakeUser.isNotifying == false {
            print("IS ADVERTISING AFTER ADVERTISE DEVICE: \(peripheralManager.isAdvertising)")
            advertiseDevice(region: fakeUser.asBeaconRegion())
            print("IS ADVERTISING BEFORE ADVERTISE DEVICE: \(peripheralManager.isAdvertising)")
            fakeUser.updateIsNotifying(isNotifying: true)
            fakeUser.updateVictimUUID(userList: userList, uuidString: fakeUser.uuidString)
            print(peripheralManager.isAdvertising)
        } else {
            print("IS ADVERTISING BEFORE STOP ADVERTISING DEVICE: \(peripheralManager.isAdvertising)")
            peripheralManager.stopAdvertising()
            print("IS ADVERTISING AFTER STOP ADVERTISING DEVICE: \(peripheralManager.isAdvertising)")
            fakeUser.updateIsNotifying(isNotifying: false)
            fakeUser.updateVictimUUID(userList: userList, uuidString: "")
            print(peripheralManager.isAdvertising)
        }
        sender.isSelected = fakeUser.isNotifying
        self.bystanderTableView.reloadData()
    }
    
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        refUsers = Database.database().reference().child(FRDKeys.Users)
        
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
            print("Is Monitoring Available: \(CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self))")
            print("Is Ranging Available: \(CLLocationManager.isRangingAvailable())")
        }
        
        
        //MARK:- FAKE INITIALIZATION (WILL BE REPLACED WITH FIREBASE AUTH)
        fakeUser = UserModel(accountID: refUsers.childByAutoId().key, name: NameModel(firstName: "Self-Li-Kai", lastName: "Self-Wu"), coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        fakeUser.postAsUserOnFRD()
        
        
        observeVictimUUIDFromUUID()
        observeValueUserFromFRD()
        
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
    
    func stopMonitoringAndRangingUser(user: UserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: STOP MONITORING FOR: \(beaconRegion.debugDescription)")
        locationManager.stopRangingBeacons(in: beaconRegion)
        print("BEACON REGION: \(beaconRegion.debugDescription) :: STOP RANGING FOR: \(beaconRegion.debugDescription)")
    }
    
    func startMonitoringAndRangingUser(user: UserModel) {
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
        print("In Observe Victim UUID From UUID")
        refUsers.child("\(fakeUser.accountID)/Victim UUID").observe(DataEventType.value) { (snapshot) in
            print(snapshot)
            let uuidString = snapshot.value as! String
            print("uuidString = \(snapshot.value as! String)")
            print("uuidString.count = \(uuidString.count)")
            if (uuidString.count != 0) {
                self.fakeUser.updatePreviousVictimUUID(previousUUID: uuidString)
                print("self.centralManager.state == .poweredon = \(self.centralManager.state == .poweredOn)")
                if let user = self.findUserFromUserList(uuid: snapshot.value as! String), self.centralManager.state == .poweredOn {
                    print("user.accountID = \(user.accountID)")
                    self.startMonitoringAndRangingUser(user: user)
                }
            } else {
                if let user = self.findUserFromUserList(uuid: self.fakeUser.previousVictimUUIDString) {
                    self.stopMonitoringAndRangingUser(user: user)
                }
            }
        }
    }
    
    func findUserFromUserList(uuid: String) -> UserModel? {
        for user in userList {
            if user.uuidString == uuid {
                return user
            }
        }
        return nil
    }
    
    func observeValueUserFromFRD() {
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
                    let distance: CLLocationDistance = locationManager.distance(from: startLocation)
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
