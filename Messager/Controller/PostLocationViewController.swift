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
protocol PostLocationDelegate {
    func updateLocation(location: CLLocation?, locString: String?)
}


class PostLocationViewController: UIViewController {
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var suggestionController: SuggestionsTableViewController!
    private var searchController: UISearchController!

    
    var locationString: String?
    var locationCoord: CLLocation?
    var delegate: PostLocationDelegate?
    
    @IBOutlet weak var map: MKMapView!
    
    private var locationManager = CLLocationManager()
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    
    @IBOutlet weak var tableView: UITableView!
    
    
    private var foregroundRestorationObserver: NSObjectProtocol?

    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    // MARK:-
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        locationManager.delegate = self
//        
//        suggestionController = SuggestionsTableViewController(style: .grouped)
//        suggestionController.tableView.delegate = self
//        
//        searchController = UISearchController(searchResultsController: suggestionController)
//        searchController.searchResultsUpdater = suggestionController
//        
//        let name = UIApplication.willEnterForegroundNotification
//        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [unowned self] (_) in
//            // Get a new location when returning from Settings to enable location services.
//            self.requestLocation()
//        })
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManagerSetup()
        
        mapSetup()
        
        longPressSetup()
        
        searchSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocation()
    }
    
    func searchSetup() {
        self.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the
         presented view controller hierarchy.
         */
        definesPresentationContext = true
    }
    
    func locationManagerSetup() {
        // 1. Setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 2. Center Map if Location Authorized.
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func mapSetup() {
        map.showsUserLocation = true
    }
    
    func longPressSetup() {
        let uiLPG = UILongPressGestureRecognizer(target: self, action: #selector(longpress))
        
        uiLPG.minimumPressDuration = 1
        
        map.addGestureRecognizer(uiLPG)
    }
    
    // MARK:- IBActions
    @IBAction func backBttnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func anyLocationTapped(_ sender: UIButton) {
        locationString = nil
        locationCoord = nil
        map.removeAnnotations(map.annotations)
    }
    
    @IBAction func useCurLocationTapped(_ sender: UIButton) {
        
        // TODO: Check if location Service is turned on, if not, show alert.
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func confirmBttnTapped(_ sender: UIButton) {
        delegate?.updateLocation(location: locationCoord, locString: locationString)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension PostLocationViewController {
    func updateMap(_ location: CLLocation) {
        
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
        coordToAddress(location, useCase: 1)
        locationCoord = location
        
    }
    
    /// Convert CLLocation to Street Name
    func coordToAddress(_ location: CLLocation, useCase: Int) {
        locationCoord = location
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if error != nil {
                print(error as Any)
            } else {
                
                var resultLocationString = ""
                func appendResultLocString(_ str:String) {
                    if resultLocationString == "" {
                        resultLocationString += str
                    } else {
                        resultLocationString += ", "
                        resultLocationString += str
                    }
                }
                
                // Placemark might be nil, because might be in desert without a placemark
                if let placemark = placemarks?[0] {
                    print(placemark)
                    
                    if let region = placemark.region {
                        print("region: ", region)
                    }
                    if let subThoroughfare = placemark.subThoroughfare {
                        print("subThoroughfare: ",subThoroughfare)
                        appendResultLocString(subThoroughfare)
                    }
                    if let thoroughfare = placemark.thoroughfare {
                        print("thoroughfare: ",thoroughfare)
                        appendResultLocString(thoroughfare)
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
                    }
                    if let postCode = placemark.postalCode {
                        print("postCode: ",postCode)
                    }
                    if let country = placemark.country {
                        print("country: ", country)
                    }
                }
                
                self.locationString = resultLocationString

                if useCase == 1 {  //
                    print("resultLocationString: ", resultLocationString)
                }
                if useCase == 2 {  // longPress handling
                    let annotation = MKPointAnnotation()
                    annotation.title = resultLocationString
                    let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    annotation.coordinate = coordinate
                    
                    self.map.removeAnnotations(self.map.annotations)
                    self.map.addAnnotation(annotation)
                }
                
                
            }
        }
    }
}

extension PostLocationViewController {
    private func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
//        let status = CLLocationManager.authorizationStatus
//
//        guard status != .denied else {
//            displayLocationServicesDeniedAlert()
//            return
//        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocationServicesDisabledAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayLocationServicesDeniedAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- Extension >>> Search
extension PostLocationViewController {
    private func search(for suggestionCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestionCompletion)
        search(using: searchRequest)
    }
    
    private func search (for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    private func search (using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = boundingRegion
        
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start(completionHandler: { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            
            self.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`
            if let updatedRegion = response?.boundingRegion {
                self.boundingRegion = updatedRegion
            }
        })
    }
}

// MARK:-
extension PostLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            updateMap(location)
            
            coordToAddress(location, useCase: 2)
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


// MARK:- Extension for longPress Recognizer
extension PostLocationViewController {
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.location(in: self.map)
        
        let coordinate = map.convert(touchPoint, toCoordinateFrom: self.map)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        coordToAddress(location, useCase: 2)

    }
}

// MARK:- TableView
extension PostLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath)
        
        if let mapItem = places?[indexPath.row] {
            cell.textLabel?.text = mapItem.name
            cell.detailTextLabel?.text = mapItem.placemark.formattedAddress
        }
        
        return cell
    }
    
}

// MARK:- UI Search Bar Delegate
extension PostLocationViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // TODO: search(for: searchBar.text)
    }
    
    
    
}


import Contacts

extension MKPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress).replacingOccurrences(of: "\n", with: " ")
    }
}
