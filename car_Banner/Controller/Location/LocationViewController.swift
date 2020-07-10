import UIKit
import CoreLocation
import UserNotifications
import MapKit
import SwiftKeychainWrapper
import Foundation
import SystemConfiguration

class LocationViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MKMapViewDelegate{
    // MARK: - Variable
    let locationManager:CLLocationManager = CLLocationManager()
    var oldLocation:CLLocation? = nil
    var start = true
    let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
    var idOfHisoryRoute = ""
    let endpoint = Settings.shered.endpoint
    var saveCoordinate: Array<Any> = []
    var traveledDistance: Double = 0
    
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var startStopButton: UIButton!
   
    // MARK: - user Location
    @IBAction func userLocation(_ sender: Any) {
        let location = MKUserLocation()
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapKitView.setRegion(region, animated: true)
        mapKitView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    // MARK: - start Traking GPS
    @IBAction func startTrakingGPS(_ sender: UIButton) {
        if sender.isSelected {
            let alertController = UIAlertController(
                 title: "Alert",
                 message: "Are you sure to finish riding?",
                 preferredStyle: .alert)
             
             let OKAction = UIAlertAction(
                 title: "Yes",
                 style: .default) { (action:UIAlertAction!) in
                    print ("Yes button prassed")
                    if self.createRoute(httpMethod: "POST", router: "api/traking/createRoute", location: self.saveCoordinate) {
                        sender.isSelected = false
                        self.start = true
                        self.oldLocation = nil
                        self.saveCoordinate.removeAll()
                        self.traveledDistance = 0
                        for poll in self.mapKitView.overlays {
                            self.mapKitView.removeOverlay(poll)
                        }
                    }
                }
            let CancelAction = UIAlertAction(
                  title: "Cancel",
                  style: .cancel) { (action:UIAlertAction!) in
                      print ("Cancel button prassed")
                      DispatchQueue.main.async{
                          self.dismiss(animated: true, completion: nil)
                      }
              }
             
            alertController.addAction(OKAction)
            alertController.addAction(CancelAction)

            self.present(alertController, animated: true, completion: nil)
        } else {
            if Reachability.isConnectedToNetwork(){
                self.displayMessage(userMessage: "Internet Connection Available!")
                print("Internet Connection Available!")
                let alertController = UIAlertController(
                   title: "Alert",
                   message: "Are you sure to start riding?",
                   preferredStyle: .alert)

                let OKAction = UIAlertAction(
                   title: "Yes",
                   style: .default) { (action:UIAlertAction!) in
                      print ("Yes button prassed")
                      sender.isSelected = true
                      self.start = false
                      sender.isSelected = true
                      self.start = false
                }
                let CancelAction = UIAlertAction(
                    title: "Cancel",
                    style: .cancel) { (action:UIAlertAction!) in
                        print ("Cancel button prassed")
                        DispatchQueue.main.async{
                            self.dismiss(animated: true, completion: nil)
                        }
                }

                alertController.addAction(OKAction)
                alertController.addAction(CancelAction)

                self.present(alertController, animated: true, completion: nil)
            }else{
                self.displayMessage(userMessage: "Internet Connection not Available!")
                print("Internet Connection not Available!")
            }
        }
        
    }
    
    // MARK: - view DidLoad
    override func viewDidLoad() {

        super.viewDidLoad()
        Settings.shered.buttonsParametrs(obj: startStopButton, rad: 15)
        
        requestPermissionNotifications()
        
        mapKitView.delegate = self
        mapKitView.showsPointsOfInterest = true
        mapKitView.showsUserLocation = true
        mapKitView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)

        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 10
        }
        
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(50.4546600, 30.5238000), radius: 10000, identifier: "Kiev")
        
        locationManager.startMonitoring(for: geoFenceRegion)
      
        
//        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for currentLocation in locations{
            print("\(index): \(currentLocation)")
                
        }
        
        if !self.start {
            guard let newLocation = locations.last else {
                return
            }
            for currentLocation in locations{
                
                let postString = [
                "longitude": currentLocation.coordinate.longitude,
                "latitude": currentLocation.coordinate.latitude,
                "distanceInThisLocation": traveledDistance,
                "speed": currentLocation.speed] as [String : Any]
                self.saveCoordinate.append(postString)
//                print(saveCoordinate)
            }
            
            guard let oldLocation = oldLocation as? CLLocation else {
                // Save old location
                self.oldLocation = newLocation
                return
            }

            traveledDistance += oldLocation.distance(from: newLocation)
            let oldCoordinates = oldLocation.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            mapKitView.addOverlay(polyline)

            // Save old location
            self.oldLocation = newLocation
        }
//        let location = locations.first!
//        let coordinationRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//        mapKitView.setRegion(coordinationRegion, animated: true)
//        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        postLocalNotifications(eventTitle: "Entered: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited: \(region.identifier)")
        postLocalNotifications(eventTitle: "Exited: \(region.identifier)")
    }
    
    // MARK: - map View
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
               let pr = MKPolylineRenderer(overlay: overlay)
               pr.strokeColor = UIColor.black
               pr.lineWidth = 5
           return pr
       }
    
    // MARK: - Permission Notifications
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let LocationViewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                LocationViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

    // MARK: - Local Notifications
    func postLocalNotifications(eventTitle:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "You've entered a new region"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    // MARK: - createRoute
    func createRoute(httpMethod: String, router: String, location: Array<Any>) -> Bool {
        var check = true
        let myUrl = URL(string: self.endpoint + router)
        
        var request              = URLRequest(url: myUrl!)
        request.httpMethod       = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
        
            let dataSave = [
                "distance": traveledDistance,
                "coordinate": location
                ] as [String : Any]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: dataSave, options: [])
//                self.displayMessage(userMessage: "Perfect, your disctance is:  \(traveledDistance)")
//                return true
            } catch let error {
                print(error.localizedDescription)
                displayMessage(userMessage: error.localizedDescription)
                check = false
            }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater! ERROR: \(String(describing: error))")
                print("error=\(String(describing: error))")
                return
            }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                } catch {
                    self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater! Error: \(error)")
                    print(error)
                    check = false
                }
        }
        task.resume()
        return check
    }
    
    // MARK: - Message
    func displayMessage(userMessage: String) -> Void {
         DispatchQueue.main.async{
           let alertController = UIAlertController(
                 title: "Alert",
                 message: userMessage,
                 preferredStyle: .alert)
             
           let OKAction = UIAlertAction(
                 title: "OK",
                 style: .default) { (action:UIAlertAction!) in
                   print ("Ok button prassed")
             }
           alertController.addAction(OKAction)
           self.present(alertController, animated: true, completion: nil)
             
         }
     }
    
    // MARK: - Receive Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
