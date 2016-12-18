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
    var overWritePreviousLocation: Bool?
    var parseID: String?
    var userLocation: CLLocation? // probably delete
    var userLocationName: String? // probably delete
    
    
    // IBOutlets
    @IBOutlet weak var locationRequestTextField: UITextField!
    
    
    // IBAction
    @IBAction func cancelButton(_ sender: AnyObject) {
        returnToPreviousView()
    }
    
    // todo: allow for both methods of location input
    @IBAction func FindOnTheMap(_ sender: AnyObject) {
        
        findInputedLocation(locationRequestTextField.text!)
        

    }
    

    @IBAction func autoLocateArrowButton(_ sender: AnyObject) {
        
        guard let location = userLocation else {
            print("Unable to determine location.")
            return
        }
        
        findNameOfLocation(location)
    }
    
    
    func checkForPreviousUserEntry() {
        let coreDataHandler = CoreDataHandler()
        
        let user = coreDataHandler.fetchLastUserData()
        
        if let studentID = user.studentID {
            
            print("studentID: \(user.studentID!) found")
            
            // this needs to return an objectID (aka parseID)
            let resultTuple = coreDataHandler.checkLocationExists(studentID: studentID)
            
            if resultTuple.0 != false {
                print("Found user location data")
            
                if let ID = resultTuple.1 {
                    parseID = ID
                } else {
                    print("Error: valid id not found; ID received: \(resultTuple.1)")
                    overWritePreviousLocation = false
                }
                
                alertPreviousRecord()
            } else {
                print("No location for user \(studentID) in database.")
                overWritePreviousLocation = false
            }
            
        } else {
            print("No current user found")
            overWritePreviousLocation = false
        }
    }
    
    
    func alertPreviousRecord() {
        let message = "It appears that you may already have submitted a location. Do you wish to replace the previous location?"

        let alert = UIAlertController(title: "Found", message: message, preferredStyle: .alert)
        let actionContinue = UIAlertAction(title: "Continue", style: .destructive, handler: {
            (action: UIAlertAction) in self.overWritePreviousLocation = true
        })
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
        // var isSuccess = false
        
        geoCode.geocodeAddressString(location, completionHandler: {
            (placemarks, error) -> Void in
            
            // var firstLocation: CLPlacemark?
            
            if let placemarks = placemarks {
                if let firstLocation = placemarks.first {
                    self.userLocation = firstLocation.location
                    self.userLocationName = firstLocation.locality
                    self.locationRequestTextField.text = "\(firstLocation.locality)"
                    
                    // isSuccess = true
                    
                    self.presentUserLocationVC(userLocation: firstLocation.location!, userLocationName: firstLocation.locality!)
                }
                
            } else {
                // add alert here
                print("Unable to locate entry")
            }
        })
    }
    
    func presentUserLocationVC (userLocation: CLLocation, userLocationName: String) {
        let userLocationVC = storyboard?.instantiateViewController(withIdentifier: "UserLocation") as? UserLocationViewController
        
        userLocationVC?.receivedUserLocation = userLocation
        userLocationVC?.receivedUserLocationName = userLocationName
        userLocationVC?.receivedOverwritePreviousLocation = overWritePreviousLocation!
        userLocationVC?.receivedParseID = parseID!
        
        present(userLocationVC!, animated: false, completion: nil)
        
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
