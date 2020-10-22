//
//  SelectLocationViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 18/10/20.
//

import UIKit
import MapKit
import CoreLocation


/// For passing value back when SelectLocation VC is dismissed
protocol SelectLocationDelegate {
    func updateLocation(_ locString: String)
}


class SelectLocationViewController: UIViewController {
    
    var delegate: SelectLocationDelegate?
    
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
    
    // MARK:- IBActions
    @IBAction func backBttnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useCurLocationTapped(_ sender: UIButton) {
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
        
        
    }
    @IBAction func confirmBttnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
extension SelectLocationViewController: CLLocationManagerDelegate {
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


