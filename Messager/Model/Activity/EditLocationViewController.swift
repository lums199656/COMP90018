//
//  EditLocationViewController.swift
//  Messager
//
//  Created by 王品 on 2020/10/25.
//

import UIKit
import MapKit
import CoreLocation


/// For passing value back when SelectLocation VC is dismissed
protocol EditLocationDelegate {
    func updateLocation(_ locString: String)
}


class EditLocationViewController: UIViewController {
    
    var delegate: EditLocationDelegate?
    
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var locationString: String?
    var locationCoord: CLLocation?
    
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 1. Setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        map.showsUserLocation = true
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func curLocation(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()

    }
    
    @IBAction func confirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func didUpdateMap(_ location: CLLocation) {
        
        // Span controls the Zoom of the map
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        // CLLocation2D
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let location2D: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        // Update map region
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location2D, span: span)
        
        map.setRegion(region, animated: true)
        
        // Update Variable to pass back to previous View
//        locationString =
        coordToAddress(location)
        locationCoord = location
        
    }
    
    func coordToAddress(_ location: CLLocation) {
        // 3. Convert coordinate to Address..?
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error as Any)
            } else {
                
                // Placemark might be nil, because might be in desert without a placemark
                if let placemark = placemarks?[0] {
                    print(placemark)
                    
                    if let region = placemark.region {
                        print("region: ", region)
                    }
                    if let subThoroughfare = placemark.subThoroughfare {
                        print("subThoroughfare: ",subThoroughfare)
                    }
                    if let thoroughfare = placemark.thoroughfare {
                        print("thoroughfare: ",thoroughfare)
                        self.locationString = self.locationString ?? "" + thoroughfare
                    }
                    if let subLocality = placemark.subLocality {
                        print("subLocality: ",subLocality)
                    }
                    if let locality = placemark.locality {
                        print("locality: ",locality)
                    }
                    if let subAdmisistrativeArea = placemark.subAdministrativeArea {
                        print("subAdmisistrativeArea: ", subAdmisistrativeArea)
                    }
                    if let admisistrativeArea = placemark.administrativeArea {
                        print("admisistrativeArea: ", admisistrativeArea)
                        self.locationString = self.locationString ?? "" + admisistrativeArea
                    }
                    if let postCode = placemark.postalCode {
                        print("postCode: ",postCode)
                    }
                    if let country = placemark.country {
                        print("country: ", country)
                    }
                    
                }
                print("locString: ", self.locationString ?? "It's nil")
                if let locString = self.locationString {
                    print("Yes")
                    self.delegate?.updateLocation(locString)
                }
            }
        }
    }
}

// MARK:-
extension EditLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            didUpdateMap(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


