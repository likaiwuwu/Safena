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
    var refCoordinates: DatabaseReference!
    var refUsers: DatabaseReference!
    
    let locationManager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D?
    var userLongitude: CLLocationDegrees = 0.0
    var userLatitude: CLLocationDegrees = 0.0
    var notifyVCUUIDBytes: UUID!
    var notifyVCUUIDString: String = ""
    var peripheralData: Dictionary<String, Any> = [:]
    lazy var beaconRegion = createBeaconRegion()
    var isNotifying: Bool = false
    var nearbyUserList = [UserModel]()
    var accountID = ""
    var centralManager: CBCentralManager!
    
    var fakeUser = UserModel()
    
    //MARK:- Outlets
    
    @IBOutlet weak var notifyButtonOutlet: UIButton!
    @IBOutlet weak var bystanderTableView: UITableView!
    
    //MARK:- Actions
    
    @IBAction func notifyButtonAction(_ sender: UIButton) {
        if isNotifying == false {
            advertiseDevice(region: beaconRegion)
            //listenToCoordinatesFromFRD()
            switchState(button: sender, state: !isNotifying)
            updateUserIsNotifyingToFRD(state: isNotifying, user: fakeUser)
            updateUserUUIDToAllUsersFRD(uuid: fakeUser.uuidString)
            bystanderTableView.reloadData()
        } else {
            switchState(button: sender, state: !isNotifying)
            updateUserIsNotifyingToFRD(state: isNotifying, user: fakeUser)
            updateUserUUIDToAllUsersFRD(uuid: "")
            self.bystanderTableView.reloadData()
        }
    }
    
    //MARK:- Structs
    
    struct FRDKeys {
        static let AccountID = "Account ID"
        static let Coordinate = "Coordinate"
        static let Latitude = "Latitude"
        static let Longitude = "Longitude"
        static let FilterDistance = "Filter Distance"
        static let IsNotifying = "Is Notifying"
        static let Name = "Name"
        static let FirstName = "First Name"
        static let LastName = "Last Name"
        static let UUIDString = "UUIDString"
        static let UUID = "UUID"
        static let Users = "Users"
        static let VictimUUID = "Victim UUID"
    }
    
    //MARK:- Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CBCentralManager
        centralManager = CBCentralManager()
        
        // References
        ref = Database.database().reference()
        refUsers = ref.child(FRDKeys.Users)
        
        //DELETE LATER
        refUsers.onDisconnectRemoveValue()
        
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
        
        // *****
        // *****
        //MARK:- FAKE INITIALIZATION (WILL BE REPLACED WITH FIREBASE AUTH)
        let fakeAccountID = refUsers.childByAutoId().key
        let fakeFirstName = "Li-Kai"
        let fakeLastName = "Wu"
        let fakeName = NameModel(firstName: fakeFirstName, lastName: fakeLastName)
        // fakeDistanceFilter set at 1 for testing purposes. Should be set at 1000
        let fakeDistanceFilter = 1
        let fakeIsNotifying = false
        let fakeUUIDString = UUID().uuidString
        let fakeUUID = UUID(uuidString: fakeUUIDString) ?? UUID()
        let fakeVictimUUIDString = ""
        let fakeVictimUUID = UUID()
        fakeUser = UserModel(accountID: fakeAccountID, name: fakeName, filterDistance: fakeDistanceFilter, isNotifying: fakeIsNotifying, uuid: fakeUUID, uuidString: fakeUUIDString, victimUUID: fakeVictimUUID, victimUUIDString: fakeVictimUUIDString)
        convertUserModelToFRDUser(userModel: fakeUser)
        // *****
        // *****

        
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
        observeUserInformationFromFRD()
        //fillRandomCoordinatesToFRD()
        //readCoordinatesFromFRD()
    }
    
    
    
    // MARK:- Location Manager
    
    func configureLocationManager(desiredAccuracy: CLLocationAccuracy, allowsBackgroundLocationUpdates: Bool, distanceFilter: CLLocationDistance) {
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
        locationManager.distanceFilter = distanceFilter
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
            break;
        default:
            break;
        }
    }
    
    func stopMonitoringUser(user: UserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func startMonitoringUser(user: UserModel) {
        let beaconRegion = user.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            userLongitude = locValue.longitude
            userLatitude = locValue.latitude
            userCoordinate = locValue
            updateUserCoordiantesToFRD(withLatitude: userLatitude, withLongitude: userLongitude, withAccountID: fakeUser.accountID)
            print("Locations: \(userLatitude) \(userLongitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //MARK:- iBeacon
    
    func createBeaconRegion() -> CLBeaconRegion {
        let proximityUUID = notifyVCUUIDBytes
        let major : CLBeaconMajorValue = 1
        let minor : CLBeaconMinorValue = 1
        let beaconID = "com.example.lw8291"
        return CLBeaconRegion(proximityUUID: proximityUUID!, major: major, minor: minor, identifier: beaconID)
    }
    
    func advertiseDevice(region : CLBeaconRegion) {
        peripheralData = region.peripheralData(withMeasuredPower: nil) as! Dictionary<String, Any>
        _ = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    //MARK:- Firebase Realtime Database
    
    func convertUserModelToFRDUser(userModel: UserModel?) {
        guard let user = userModel else { return }
        createAndWriteUserInformationToFRD(accountID: user.accountID, state: user.isNotifying, firstName: user.name.firstName, lastName: user.name.lastName, uuidString: user.uuidString)
    }
    
    func updateUserCoordiantesToFRD(withLatitude latitude: CLLocationDegrees, withLongitude longitude: CLLocationDegrees, withAccountID accountID: String) {
        let coordinatePost = [FRDKeys.Latitude: latitude,
                              FRDKeys.Longitude: longitude]
        refUsers.child(accountID).updateChildValues([FRDKeys.Coordinate: coordinatePost])
    }
    
    func updateUserUUIDToAllUsersFRD(uuid: String) {
        nearbyUserList.forEach { (user) in
            print(user.accountID)
            refUsers.child(user.accountID).updateChildValues([FRDKeys.VictimUUID: uuid])
        }
    }
    
    func monitorBeacons(uuidString: String) {
        if CLLocationManager.isMonitoringAvailable(for:
            CLBeaconRegion.self) {
            // Match all beacons with the specified UUID
            let proximityUUID = UUID(uuidString: uuidString)
            let beaconID = "com.example.lw8291"
            
            // Create the region and begin monitoring it.
            let region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                        identifier: beaconID)
            self.locationManager.startMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("ERRORRRR:\(error.localizedDescription) for region \(region.proximityUUID)")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            // Start ranging only if the feature is available.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                print("CONNECTED TO: \(region.identifier)!!!!!!!!!!!!!!!!!!!!!!!!!!")
                // Store the beacon so that ranging can be stopped on demand.
                // beaconsToRange.append(region as! CLBeaconRegion)
            }
        }
    }


    func observeUserVictimUUIDFromFRD() {
        nearbyUserList.forEach { (user) in
            refUsers.child("\(user.victimUUIDString)").observe(.value, with: { (snapshot) in
                if snapshot.hasChildren() {
                    self.monitorBeacons(uuidString: user.victimUUIDString)
                }
            })
        }
    }
    
    
    func observeUserInformationFromFRD() {
        //queryOrdered(byChild: "\(FRDKeys.Coordinate)/\(FRDKeys.Longitude)").queryStarting(atValue: userLongitude-10.0).queryEnding(atValue: userLatitude-10.0)
        refUsers.observe(.value, with: { snapshot in
            //if the reference have some values
            if snapshot.hasChildren() {
                
                //clearing the list
                self.nearbyUserList.removeAll()
                
                //iterating through all the values
                for users in snapshot.children.allObjects as! [DataSnapshot] {
                    print(users)
                    // Getting values
                    let userObject = users.value as? [String: AnyObject]
                    // Getting account id
                    let userAccountID = userObject?[FRDKeys.AccountID] as! String
                    // Getting Name
                    let userName = userObject?[FRDKeys.Name] as! [String: AnyObject]
                    let userFirstName = userName[FRDKeys.FirstName] as! String
                    let userLastName = userName[FRDKeys.LastName] as! String
                    let newUserModel = NameModel(firstName: userFirstName , lastName: userLastName)
                    // Getting desired accuracy
                    let userFilterDistance = userObject?[FRDKeys.FilterDistance] as! Int
                    // Getting is notifying
                    let userIsNotifying = userObject?[FRDKeys.IsNotifying] as! Bool
                    // Getting user UUID
                    let userUUIDString = userObject?[FRDKeys.UUIDString] as! String
                    // Getting user victim UUID
                    let userVictimUUIDString = userObject?[FRDKeys.VictimUUID] as! String
                    
                    
                    //creating artist object with model and fetched values
                    
                    let user = UserModel(accountID: userAccountID, name: newUserModel, filterDistance: userFilterDistance, isNotifying: userIsNotifying, uuid: UUID(uuidString: userUUIDString) ?? UUID(), uuidString: userUUIDString, victimUUID: UUID(uuidString: userVictimUUIDString) ?? UUID(), victimUUIDString: userVictimUUIDString)
                    
                    //appending it to list
                    self.nearbyUserList.append(user)
                }
                
                //reloading the tableview
                self.bystanderTableView.reloadData()
            }
        })
    }
    
    func updateUserIsNotifyingToFRD(state: Bool, user: UserModel) {
        refUsers.child(user.accountID).updateChildValues([FRDKeys.IsNotifying: state])
    }
    
    func generateAndInitializeUUID() {
        // generating a new key inside users node
        // and also getting the generated key
        notifyVCUUIDString = UUID().uuidString
        notifyVCUUIDBytes = UUID(uuidString: notifyVCUUIDString)
    }
    
    
    func createAndWriteUserInformationToFRD(accountID: String, state: Bool, firstName: String, lastName: String, uuidString: String) {
        generateAndInitializeUUID()
        // creating user with the given values
        let user = [FRDKeys.AccountID: accountID,
                    FRDKeys.IsNotifying: state,
                    FRDKeys.FilterDistance: locationManager.distanceFilter,
                    FRDKeys.Name: [FRDKeys.FirstName: firstName,
                                   FRDKeys.LastName: lastName],
                    FRDKeys.UUIDString: uuidString,
                    FRDKeys.VictimUUID: ""
                    ] as [String : Any]
        
        // adding the user inside the generated unique key
        refUsers.child(String(accountID)).setValue(user)
        
        // displaying message
        // labelMessage.text = "User Added"
    }
    
    func switchState(button: UIButton, state: Bool) {
        isNotifying = state
        button.isSelected = state
    }
    
}
