//
//  UserLocationViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/29/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo:
//  1) clean up
//  2) prepopulate mediaURL?
//  3) comments
//  4) give submit button a background
//  5) Issue: not necessarily a bug but does not immediatly show user location
//      maybe a little while before updated user info is added to Udacity parse api
//      core data may not immediately show updated information.
//      could manually add new user location to annotations

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

    // Upon load show user location from given CLLocation
    // todo: break up this method
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
    // todo: Get from previous submission?
    func getUserData() -> UdacityUserInfo {
        let coreDataHandler = CoreDataHandler()
        let userRecord = coreDataHandler.fetchLastUserData()
        return userRecord
    }

    
    // submitButton action: post/ put location to parseAPI
    // todo: Break this method up ... too long
    @IBAction func submitButton(_ sender: AnyObject) {
        
        let isLinkToShareEmtpy = checkForEmptyLink()
        
        if isLinkToShareEmtpy == true {
            AlertLinkToShareEmpty()
        } else {
            let studentInfo = prepareInfoForParse()
            postToParse(studentInfo: studentInfo)
            
            // add an alert if successful?
            
            presentMap()
        }
    }
    
    
    // Check for empty linkToShare textfield
    func checkForEmptyLink() -> Bool {
        if linkToShareTextView.text == "" {
            return true
        } else {
            return false
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
            self.postToParse(studentInfo: studentInfo)
            
            // add an alert if successful?
            
            DispatchQueue.main.async(execute: { (void) in
                self.presentMap()
            })
        })
        
        let actionCancel = UIAlertAction(title: "Enter a link", style: .default, handler: nil)
        
        alert.addAction(actionContinue)
        alert.addAction(actionCancel)
        
        present(alert, animated: false, completion: nil)
    }
    
    
    // populate studentInfo
    func prepareInfoForParse() -> StudentInfo {
        let userRecord = getUserData()
        var studentInfo = StudentInfo()
        
        studentInfo.firstName = userRecord.firstName
        studentInfo.lastName = userRecord.lastName
        studentInfo.studentID = userRecord.studentID
        
        studentInfo.latitude = receivedUserLocation?.coordinate.latitude.description
        studentInfo.longitude = receivedUserLocation?.coordinate.longitude.description
        studentInfo.mediaURL = linkToShareTextView.text
        
       return studentInfo
    }
    
    
    // post to parse
    // todo: return isSuccess
    func postToParse(studentInfo: StudentInfo) {
        let mapLocation = receivedUserLocationName
        
        let parse = ParseAPI()
        
        if let usePutMethod = receivedOverwritePreviousLocation {
            if usePutMethod == true {
                parse.sendStudentLocation(studentInfo, mapString: mapLocation!, updateExistingEntry: true, parseID: receivedParseID)
            } else {
                parse.sendStudentLocation(studentInfo, mapString: mapLocation!, updateExistingEntry: false)
            }
        }
        
    }
    
    // present MapView when parse post is comeplete
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
