//
//  UserLocationViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/29/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
//  Issue: not necessarily a bug but does not immediatly show user location
//      maybe a little while before updated user info is added to Udacity parse api
//      core data may not immediately show updated information.
//      Should add operation/ completion handler to update table after task complete
//

/* 
 
 Follow up to InfoPostView.
 Locates User shows user's found / submitted location before submission.
 Allows for input of user supplied media url.
 
 */

import UIKit
import MapKit

class UserLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    
    // Fields
    var receivedUserLocation: CLLocation?
    var receivedUserLocationName: String?
    var receivedOverwritePreviousLocation: Bool?
    var receivedParseID: String?
    
    
    // IBOutlets
    // Add "http://" to linkToShareTextView with delegate?
    @IBOutlet weak var linkToShareTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    
    // Upon load show user location from given CLLocation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let latitude = receivedUserLocation?.coordinate.latitude else {
            fatalError("Missing latitude")
        }
        
        guard let longitude = receivedUserLocation?.coordinate.longitude else {
            fatalError("Missing longitude")
        }
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Look Here!"
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        // Set textField delegate to self for return functionality
        linkToShareTextView.delegate = self
        
        // Set first responder
        linkToShareTextView.becomeFirstResponder()

    }
    
    
    // Retrieve user data for submission purposes
    func getUserData() throws -> UdacityUserInfo {
        let coreDataHandler = CoreDataHandler2()

        guard let userRecord = try? coreDataHandler.fetchLastUserData() else {
            throw OnTheMapCustomErrors.CoreDataErrors.UnexpectedReturn(description: "Missing User Data")
        }
        
        return userRecord
    }

    
    // SubmitButton action: post/ put location to parseAPI
    @IBAction func submitButton(_ sender: AnyObject) {

        
        if linkToShareTextView.text == "" {
            AlertLinkToShareEmpty()
        } else {
            activityIndicator.startAnimating()
            let studentInfo = prepareInfoForParse()
            do {
                try postToParse(studentInfo: studentInfo!)
                sendAlert(message: "Location Sent!")
            } catch {
                sendAlert(message: "Post Failed!")
            }
        }
    }
    
    
    // Alert User linkToShare empty
    func AlertLinkToShareEmpty() {
        let message = "Web site link appears to be empty. Continue anyway?"
        
        let alert = UIAlertController(title: "Empty web link", message: message, preferredStyle: .alert)
        
        // add closures
        let actionContinue = UIAlertAction(title: "Continue anyway", style: .destructive, handler: {
            (action: UIAlertAction) in
            
            let studentInfo = self.prepareInfoForParse()
            do {
                try self.postToParse(studentInfo: studentInfo!)
                DispatchQueue.main.async(execute: { (void) in
                    self.sendAlert(message: "Location Sent!")
                })
            } catch {
                DispatchQueue.main.async(execute: { (void) in
                    self.sendAlert(message: "Oops. Failed to Send. Please try again later")
                })
                
            }
        })
        
        let actionCancel = UIAlertAction(title: "Enter a link", style: .default, handler: nil)
        
        alert.addAction(actionContinue)
        alert.addAction(actionCancel)
        
        present(alert, animated: false, completion: nil)
    }
    
    
    // Populate studentInfo
    func prepareInfoForParse() -> StudentInfo? {
        guard let userRecord = try? getUserData() else{
            sendAlert(message: "Oops! Something went wrong. Please restart the application")
            return nil
        }
        var studentInfo = StudentInfo()
        
        studentInfo.firstName = userRecord.firstName
        studentInfo.lastName = userRecord.lastName
        studentInfo.studentID = userRecord.studentID
        
        studentInfo.latitude = receivedUserLocation?.coordinate.latitude.description
        studentInfo.longitude = receivedUserLocation?.coordinate.longitude.description
        
        if let parseID = receivedParseID {
            studentInfo.parseID = parseID
        } else {
            studentInfo.parseID = nil
        }
        
        if let mediaURL = URL(string: linkToShareTextView.text!) {
            studentInfo.mediaURL = mediaURL.absoluteString
        } else {
            studentInfo.mediaURL = ""
        }
        
       return studentInfo
    }
    
    
    // post to parse
    func postToParse(studentInfo: StudentInfo) throws -> Void {
        
        let mapLocation = receivedUserLocationName
        
        let parse = ParseAPI2()
        
        if receivedOverwritePreviousLocation != true {
            receivedOverwritePreviousLocation = false
        }
        
        do {
            try parse.postStudentLocation(studentInfo: studentInfo, mapString: mapLocation!, updateExistingEntry: receivedOverwritePreviousLocation!)
        } catch {
            throw OnTheMapCustomErrors.ParseAPI2Errors.UnableToPostToParse
        }
    }
    
    
    // User alerts
    fileprivate func sendAlert(message: String) {
        activityIndicator.stopAnimating()
        let alert = OKAlertGenerator(alertMessage: message)
        alert.title = "Status"
        alert.handler = { (UIAlertAction) in self.presentMap() }
        present(alert.getAlertToPresent(), animated: false, completion: nil)
    }
    
    
    // Present MapView
    func presentMap() {
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") {
            present(tabBarController, animated: false, completion: nil)
        } else {
            fatalError("Fatal Map Error.")
        }
    }
    
    
    // MARK: - Location Text Field Delegate Methods    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        linkToShareTextView.resignFirstResponder()
        submitButton(textField)
        return true
    }

}
