//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: check for previously inputed location, create alert (maybe in previous class)

import UIKit
import CoreLocation

class InfoPostViewController: UIViewController, CLLocationManagerDelegate {
    
    
    override func viewWillAppear(_ animated: Bool) {
        checkForPreviousUserEntry()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    // Fields
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var userLocationName: String?
    
    
    // IBOutlets
    @IBOutlet weak var locationRequestTextField: UITextField!
    
    
    // IBAction
    @IBAction func cancelButton(_ sender: AnyObject) {
        returnToPreviousView()
    }
    

    @IBAction func FindOnTheMap(_ sender: AnyObject) {
        
        findInputedLocation(locationRequestTextField.text!)
        
        let userLocationVC = storyboard?.instantiateViewController(withIdentifier: "UserLocation") as? UserLocationViewController
        
        userLocationVC?.receivedUserLocation = userLocation
        userLocationVC?.receivedUserLocationName = userLocationName
        
        present(userLocationVC!, animated: false, completion: nil)
        
    }
    

    @IBAction func autoLocateArrowButton(_ sender: AnyObject) {
        
        guard let location = userLocation else {
            print("Unable to determine location.")
            return
        }
        
        findNameOfLocation(location)
    }
    
    
    func displayUserLocation() {
        
       // LocationRequestField.text = userLocationToSend?.description
        
    }
    
    
    func checkForPreviousUserEntry() {
        let coreDataHandler = CoreDataHandler()
        
        let user = coreDataHandler.fetchLastUserData()
        
        if let studentID = user.studentID {
            
            print("studentID: \(user.studentID!) found")
            
            let isSuccess = coreDataHandler.checkLocationExists(studentID: studentID)
            
            if isSuccess != false {
                print("Found user location data")
                
                alertPreviousRecord()
            } else {
                print("No location for user \(studentID) in database.")
            }
            
        } else {
            print("No current user found")
        }
    }
    
    
    func alertPreviousRecord() {
        let message = "It appears that you may already have submitted a location. Do you wish to replace the previous location?"

        let alert = UIAlertController(title: "Found", message: message, preferredStyle: .alert)
        let actionContinue = UIAlertAction(title: "Continue", style: .destructive, handler: nil )
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in self.returnToPreviousView()
        })

        alert.addAction(actionContinue)
        alert.addAction(actionCancel)
        
        present(alert, animated: true)
    }
    
    
    func returnToPreviousView() {
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    func findNameOfLocation(_ location: CLLocation) {
        let geoCode = CLGeocoder()
        var isSuccess = false
        
        geoCode.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if let placemarks = placemarks {
                if let firstLocation = placemarks.first?.locality {
                    self.userLocationName = firstLocation
                    self.locationRequestTextField.text = "\(firstLocation)"
                    isSuccess = true
                    print("name found: \(isSuccess)")
                }
            }
        })
    }
    
    
    func findInputedLocation(_ location: String) {
        
        let geoCode = CLGeocoder()
        geoCode.geocodeAddressString(location, completionHandler: {
            (placemarks, error) -> Void in
            
            var firstLocation: CLPlacemark?
            
            if let placemarks = placemarks {
                firstLocation = placemarks.first
                
                print("Latitude: \(firstLocation?.location?.coordinate.latitude), Longitude: \(firstLocation?.location?.coordinate.longitude)")
                
            } else {
                // add alert here
                print("Unable to locate entry")
            }
        })
    }
    
    
    // MARK: - Location Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        userLocation = location
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }

}
