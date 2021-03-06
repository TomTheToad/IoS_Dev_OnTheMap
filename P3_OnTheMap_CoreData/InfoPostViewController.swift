//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: check for previously inputed location, create alert (maybe in previous class)

/* 
 
 First of two views necessary to add / update user parse data.
 Checks for previous submission, 
    query user for overwrite permission if found,
    finds location,
    and passes on to UserLocationController.
 
 This version also includes an autolocate option.
 
 This was originally a single view but was quickly overloaded.
 
 */

import UIKit
import CoreLocation

class InfoPostViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    
    // Check for previous entry prior to starting process.
    override func viewWillAppear(_ animated: Bool) {
        checkForPreviousUserEntry()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Text Field delegate
        locationRequestTextField.delegate = self
        
        // Set first repsonder
        locationRequestTextField.becomeFirstResponder()
        
    }
    
    
    // Fields
    let locationManager = CLLocationManager()
    var overWritePreviousLocation: Bool?
    var parseID: String?
    var userLocation: CLLocation? // probably delete
    var userLocationName: String? // probably delete
    
    
    // IBOutlets
    @IBOutlet weak var locationRequestTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // IBAction
    // Cancel Button Action: return to previous view
    @IBAction func cancelButton(_ sender: AnyObject) {
        returnToPreviousView()
    }
    
    
    // Find given user location
    @IBAction func FindOnTheMap(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        findInputedLocation(locationRequestTextField.text!)
    }
    

    // Auto locate button action
    @IBAction func autoLocateButton(_ sender: AnyObject) {
        guard let location = userLocation else {
            sendAlert(message: "Oops. Something went wrong. Please try again later")
            return
        }
        
        // Gets the name of the found location
        findNameOfLocation(location)
    }
    
    
    // Checks for previous entry by current user, calls alert function if found.
    func checkForPreviousUserEntry() {
        
        let coreDataHandler = CoreDataHandler2()
        
        guard let user = try? coreDataHandler.fetchLastUserData() else {
            sendAlert(message: "Application Error! Please restart the application")
            return
        }

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
                // Change to nil to avoid potential data trap, probably redundant but safe
                parseID = nil
            }
            
        } else {
            print("No current user found")
            overWritePreviousLocation = false
            // Change to nil to avoid potential data trap
            parseID = nil
        }
    }
    
    
    // Presents an alert to the user if previous location is found.
    // If overwrite continue with submission else roll back to previous view.
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
    
    
    // Returns to previous view in stack
    func returnToPreviousView() {
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    // Uses reverse GeoCodeLcation to find name of a given location and sets placemark
    // todo: break this method up?
    // Takes a CLLocation
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
                } else {
                    self.sendAlert(message: "Oops. Something went wrong. Please check your connection and try again.")
                }
            }
        })
    }
    
    
    // Attempts to find a location inputed by user
    // todo: add alert
    func findInputedLocation(_ location: String) {
        
        let geoCode = CLGeocoder()
        // var isSuccess = false
        
        geoCode.geocodeAddressString(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if let placemarks = placemarks {
                if let firstLocation = placemarks.first {
                    self.userLocation = firstLocation.location
                    self.userLocationName = firstLocation.locality
                    self.locationRequestTextField.text = "\(firstLocation.locality)"
                    self.activityIndicator.stopAnimating()
                    self.presentUserLocationVC(userLocation: firstLocation.location!, userLocationName: firstLocation.locality!)
                }
                
            } else {
                self.sendAlert(message: "Could not locate entry. Please try again")
        
            }
        })
    }
    
    
    // Prep for, and transition to UserLocationView
    func presentUserLocationVC (userLocation: CLLocation, userLocationName: String) {
        let userLocationVC = storyboard?.instantiateViewController(withIdentifier: "UserLocation") as? UserLocationViewController
        
        userLocationVC?.receivedUserLocation = userLocation
        userLocationVC?.receivedUserLocationName = userLocationName
        userLocationVC?.receivedOverwritePreviousLocation = overWritePreviousLocation!
        
        if let id = parseID {
            userLocationVC?.receivedParseID = id
        }
        
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
    
    
    // MARK: - Location Text Field Delegate Methods
    // Allows for return key to execute submit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationRequestTextField.resignFirstResponder()
        findInputedLocation(locationRequestTextField.text!)
        return true
    }
    
    fileprivate func sendAlert(message: String) {
        activityIndicator.stopAnimating()
        let alert = OKAlertGenerator(alertMessage: message)
        present(alert.getAlertToPresent(), animated: false, completion: nil)
    }

}
