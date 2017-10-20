//
//  ViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 21/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import UserNotifications
import CoreBluetooth

class ViewController: UIViewController, ARDataSource , CLLocationManagerDelegate, CBCentralManagerDelegate
{
    
    //ibeacon inherit CLLOcationManagerDelegate
    var LocaMan = CLLocationManager()
    
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var major_num: UILabel!
    //@IBOutlet weak var minor_num: UILabel!
    @IBOutlet weak var save_floor: UILabel!
    @IBOutlet weak var save_region: UILabel!
    @IBOutlet weak var imageAlert: UIImageView!
    
    
    var major_data:Double! //掃入的major
    var minor_data:Double! //掃入的minor
    var save_major:Double? //儲存的major
    var save_minor:Double? //儲存的minor
    var judge:Bool = true //判斷save or remove
    var save_info1:String? //引出儲存major
    var save_info2:String? //引出儲存minor
    var remove_info1:String? //重設save major = nil
    var remove_info2:String? //重設svae minor = nil
    
    @IBOutlet weak var audi: UIImageView!
    @IBOutlet weak var background: UIImageView!
    //往第二個view傳資料
    var myUserDefaults :UserDefaults!
    static let FD = "FloorData"
    static let RD = "RegionData"
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        let minor_trans = segue.destination as! DataPage
        let major_trans = segue.destination as! DataPage
        minor_trans.FloorData = self.save_floor.text!
        major_trans.RegionData = self.save_region.text!
    }
    */
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        audi.image = UIImage(named: "audi.jpg")
        background.image = UIImage(named: "bg5.png")
        LocaMan.requestAlwaysAuthorization()//request for location
        LocaMan.delegate = self //assgign delegate
        
        /*for r in LocaMan.rangedRegions {
         LocaMan.stopRangingBeacons(in: r as! CLBeaconRegion)
         }
         for r in LocaMan.monitoredRegions {
         LocaMan.stopMonitoring(for: r)
         }*/
        
        //let uuid = UUID(uuidString: "15345164-67AB-3E49-F9D6-E29000000008")
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let region = CLBeaconRegion(proximityUUID: uuid!, identifier: "")
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        region.notifyOnExit = true
        LocaMan.startRangingBeacons(in: region)
        
        //CLRegion CLBeaconRegion
        myUserDefaults = UserDefaults.standard
        
        //record the floor_region_information in the cellphone local storage
        //每次都從手機抓出之前儲存的Floor與Region的資訊
        //若有資料就把save_floor顯示樓層並存入save_info裡方面之後比較，若無則顯示------
        if let info1 = myUserDefaults.object(forKey: "FloorData") as? String {
            save_floor.text = info1
            save_info1 = info1
        }
        else {
            save_floor.text = "------"
        }
        if let info2 = myUserDefaults.object(forKey: "RegionData") as? String {
            save_region.text = info2
            save_info2 = info2
        }
        else {
            save_region.text = "------"
        }

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //monitor mode --> entry the specail beacon
    func locationManager(_ manager: CLLocationManager,didEnterRegion region: CLBeaconRegion) {
        
        if (save_major == major_data) && (save_minor == minor_data) {
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            print("entry")
            print("Monitor's Major " + String(major_data) + " Minor " + String(minor_data))
            
            let alert = UIAlertController(title: "您已在愛車附近!", message: "請查看APP！", preferredStyle: .alert)
            let sure = UIAlertAction(title: "確認", style: UIAlertActionStyle.default,   handler: nil)
            alert.addAction(sure)
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            
        }
    }

    
    //monitor mode --> leave the special beacon
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLBeaconRegion) {
        print("ExitRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLBeaconRegion){
        print("StartMonitoring")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        guard beacons.count > 0 else {
            major_num.text = "------------"
            major_data = nil
            minor_data = nil
            //minor_num.text = "------"
            //CurrentLocation.text = "------------"
            imageAlert.image = nil
            msg.text = "There is no any one beacon."
            return
        }
        //---------------- Test region---------------
        print("beacon1")
        print(beacons[0].major)
        print(beacons[0].minor)
        print(beacons[0].rssi)
        
        if beacons.count > 1 {
            let a:Int = 2
            if a == 2 {
                print("beacon2")
                print(beacons[1].major)
                print(beacons[1].minor)
                print(beacons[1].rssi)
                
            }
        }
        
        print("---------------------------")
        
        //------------------------------------------
        major_data = Double(beacons[0].major)
        minor_data = Double(beacons[0].minor)
        
        //CurrentLocation.text = String(Int(major_data)) + " F - " + String(Int(minor_data))
        major_num.text = String(Int(major_data)) + " F - " + String(Int(minor_data))
        //minor_num.text = String(minor_data)
        if save_floor.text != "------" {
            if ((save_info1 == String(major_data)) && (save_info2 == String(minor_data))) {
                msg.text = "Your car is nearby!"
                imageAlert.image = UIImage (named: "alert_red.png")
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                
                let content = UNMutableNotificationContent()
                content.title = "NOTICE!!!!!"
                content.subtitle = "Please stop !!!"
                content.body = "Your car is nearby."
                content.badge = 41
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let requestIdentifier = "Car is nearby"
                let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {
                    error in //handle error
                })
                
            }
            else {
                imageAlert.image = nil
                msg.text = "Your car is not here!"
            }
        }
        else {
            imageAlert.image = nil
            msg.text = "You haven't saved any data!"
        }
        
    }
    
    
    @IBAction func RemoveData(_ sender: Any) {
        removeData()
    }
    
    
    
    //the action for save button
    @IBAction func save(_ sender: Any) {
        save_major = major_data
        save_minor = minor_data
        judge = true
        
        LocaMan.delegate = self //assgign delegate
        //let uuid = UUID(uuidString: "15345164-67AB-3E49-F9D6-E29000000008")
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        //let regionForMonitor = CLBeaconRegion(proximityUUID: uuid!, identifier: "")
        
        //if beacons.count > 0 {
        
        
        
        if save_major != nil {
            if save_minor != nil {
                
                let regionForMonitor = CLBeaconRegion(proximityUUID: uuid!, major: CLBeaconMajorValue(save_major!), minor: CLBeaconMajorValue(save_minor!), identifier: "Monitoring")
                
                //Monitor Floor first
                regionForMonitor.notifyEntryStateOnDisplay = true
                regionForMonitor.notifyOnEntry = true
                regionForMonitor.notifyOnExit = true
                LocaMan.startMonitoring(for: regionForMonitor)
                
                save_floor.text = String(save_major!)
                save_region.text = String(save_minor!)
                
                updateData()
                if let info1 = myUserDefaults.object(forKey: "FloorData") as? String {
                    save_floor.text = info1
                    save_info1 = info1
                }
                else {
                    save_floor.text = "------"
                }
                
                if let info2 = myUserDefaults.object(forKey: "RegionData") as? String {
                    save_region.text = info2
                    save_info2 = info2
                }
                else {
                    save_region.text = "------"
                }
            }
        }
        else {
            let alert = UIAlertController(title: "設備偵測失敗!", message: "請確認是否位於停車場", preferredStyle: .alert)
            let sure = UIAlertAction(title: "確認", style: UIAlertActionStyle.default,   handler: nil)
            alert.addAction(sure)
            self.present(alert, animated: true, completion: nil)
        }

    }
    
        
    
    
    //function of shake the cellphone
    func applicationDidBecomeActive(_ application: UIApplication) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    //function of update and remove saveed-data
    func updateData() {
        myUserDefaults.set(save_floor.text, forKey: "FloorData")
        myUserDefaults.synchronize()
        myUserDefaults.set(save_region.text, forKey: "RegionData")
        myUserDefaults.synchronize()
    }
    func removeData() {
        
        judge = false
        imageAlert.image = nil
        
        myUserDefaults.removeObject(forKey: "FloorData")
        save_floor.text = "------"
        myUserDefaults.removeObject(forKey: "RegionData")
        save_region.text = "------"
        
        if let info1 = myUserDefaults.object(forKey: "FloorData") as? String {
            save_floor.text = info1
            remove_info1 = info1
        }
        else {
            save_floor.text = "------"
        }
        if let info2 = myUserDefaults.object(forKey: "RegionData") as? String {
            save_region.text = info2
            remove_info2 = info2
        }
        else {
            save_region.text = "------"
        }
        /*
         print("------remove info------")
         print(remove_info1)
         print(remove_info2)
         print("------save info------")
         print(save_info1)
         print(save_info2)
         */
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }

    
    
    @IBOutlet weak var viewShow: UIView!
    
    
    var i:Int = -1;
    var user_lon:Double?
    var user_lat:Double?
    
    /*func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation:CLLocation = locations[0] as! CLLocation
        let lon = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        user_lon = lon;
        user_lat = lat;
        //Do What ever you want with it
    }
    //
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }*/
    
    /// Creates random annotations around predefined center point and presents ARViewController modally
    func showARViewController()
    {
        i = -1;
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        //
        
       /* let locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        //
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        print("---user_lon---")
        print(user_lon)
        print("---user_lat---")
        print(user_lat)*/
        
        // Create random annotations around center point    //@TODO
        //FIXME: set your initial position here, this is used to generate random POIs
        let lat = 25.014758
        let lon = 121.542277
        let delta = 0.5  //0.05
        let count = 10 //產生多少個隨機的點
        let dummyAnnotations = self.getDummyAnnotations(centerLatitude: lat, centerLongitude: lon, delta: delta, count: count)
   
        // Present ARViewController
        let arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(dummyAnnotations)
        arViewController.uiOptions.debugEnabled = true
        arViewController.uiOptions.closeButtonEnabled = true
        //arViewController.interfaceOrientationMask = .landscape
        arViewController.onDidFailToFindLocation =
        {
            [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
                
            self?.handleLocationFailure(elapsedSeconds: elapsedSeconds, acquiredLocationBefore: acquiredLocationBefore, arViewController: arViewController)
        }
        self.present(arViewController, animated: true, completion: nil)
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    fileprivate func getDummyAnnotations(centerLatitude: Double, centerLongitude: Double, delta: Double, count: Int) -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        var NTUST_name = ["TR","RB","IB","T1","T2","T3","T4","E1","E2","EE"]
        
        srand48(3)
        for i in stride(from: 0, to: count, by: 1)
        {
            let annotation = ARAnnotation()
            annotation.location = self.getRandomLocation(centerLatitude: centerLatitude, centerLongitude: centerLongitude, delta: delta)
            annotation.title = NTUST_name[i]
            annotations.append(annotation)
        }
        return annotations
    }
    
    fileprivate func getRandomLocation(centerLatitude: Double, centerLongitude: Double, delta: Double) -> CLLocation
    {
        //var lat = centerLatitude
        //var lon = centerLongitude
        
        
        
        var NTUST_lat=[25.014952,25.014216,25.013084,25.014258,25.012099,25.013429,25.013807,25.013550,25.012661,25.012085]
        //TR,RB,IB,T1,T2,T3,T4,E1,E2,EE
        var NTUST_lon=[121.542859,121.541465,121.540246,121.541886,121.540967,121.542930,121.541740,121.541963,121.540936,121.541656]
        //TR,RB,IB,T1,T2,T3,T4,E1,E2,EE

        i = i + 1;
        //let latDelta = -(delta / 2) + drand48() * delta
        //let lonDelta = -(delta / 2) + drand48() * delta
        //lat = lat + latDelta
        //lon = lon + lonDelta
        //return CLLocation(latitude: lat, longitude: lon)
        
        return CLLocation(latitude: NTUST_lat[i], longitude: NTUST_lon[i])
    }
    
    @IBAction func buttonTap(_ sender: AnyObject)
    {
        showARViewController()
    }
    
    func handleLocationFailure(elapsedSeconds: TimeInterval, acquiredLocationBefore: Bool, arViewController: ARViewController?)
    {
        guard let arViewController = arViewController else { return }
        
        NSLog("Failed to find location after: \(elapsedSeconds) seconds, acquiredLocationBefore: \(acquiredLocationBefore)")
        
        // Example of handling location failure
        if elapsedSeconds >= 20 && !acquiredLocationBefore
        {
            // Stopped bcs we don't want multiple alerts
            arViewController.trackingManager.stopTracking()
            
            let alert = UIAlertController(title: "Problems", message: "Cannot find location, use Wi-Fi if possible!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Close", style: .cancel)
            {
                (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
