//
//  ActivityManager.swift
//  Messager
//
//  Created by Boyang Zhang on 2/11/20.
//

import UIKit
import CoreLocation
import Firebase


protocol ActivityManagerDelegate {
    func activityManagerDid()
    func activityManager(_ manager: ActivityManager, didUpdateActivityTitle title: String)
    func activityManager(_ manager: ActivityManager, didCheckInUser isAllowed: Bool, distanceToActivityLocation distance: Int?)
}



class ActivityManager: NSObject {
    
    var delegate: ActivityManagerDelegate?
    
    // Firebase
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var activityId: String
    
    var activityTitle: String? {
        didSet {
            print("didSet activityTitle")
            self.delegate?.activityManager(self, didUpdateActivityTitle: activityTitle!)
        }
    }
    var activityDetail: String?
    var activityLocation: CLLocation?
    
    // Location Manager
    var locationManager = CLLocationManager()
    var userLocation: CLLocation? {
        didSet {
            print("didSet userLocation")
            checkIfUserAtActivityLocation()
        }
    }
    
    // ActivityManager Varible
    var isUserAtActivityLocation = false
    
    
    // MARK:- Initialize
    init(_ activityId: String) {
        self.activityId = activityId
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.refreshActivity()
    }
    
    func refreshActivity() {
        
        let docRef = db.collection(K.FStore.act).document(activityId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.activityTitle = data?[K.Activity.title] as? String
                self.activityDetail = data?["actDetail"] as? String
                
                if let point = data?["location"] as? GeoPoint {
                    self.activityLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
                }
            }
        }
    }
    
    func currentUserTryToCheckIn() {
        locationManager.requestLocation()
    }
    
    
    // MARK:- Helper Functions
    func  checkIfUserAtActivityLocation() {
        guard let activityLocation = self.activityLocation else {return}
        guard let userLocation = self.userLocation else {return}
        let distance:CLLocationDistance = activityLocation.distance(from: userLocation) //two point distance
        
        print("🗺 Your are \(Int(distance)) meters from activity Location.🗺 ")
        if Int(distance) < 200 {
            self.delegate?.activityManager(self, didCheckInUser: true, distanceToActivityLocation: Int(distance))
        } else {
            self.delegate?.activityManager(self, didCheckInUser: false, distanceToActivityLocation: Int(distance))
        }
    }
}

// MARK:- Location Manager
extension ActivityManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
