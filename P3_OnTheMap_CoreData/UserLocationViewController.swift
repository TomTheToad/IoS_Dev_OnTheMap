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

class UserLocationViewController: UIViewController, MKMapViewDelegate {
    
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
        
        let userRecord = getUserData()
        var studentInfo = StudentInfo()
        
        studentInfo.firstName = userRecord.firstName
        studentInfo.lastName = userRecord.lastName
        studentInfo.studentID = userRecord.studentID
        
        studentInfo.latitude = receivedUserLocation?.coordinate.latitude.description
        studentInfo.longitude = receivedUserLocation?.coordinate.longitude.description
        studentInfo.mediaURL = linkToShareTextView.text
        
        let mapLocation = receivedUserLocationName
        
        let parse = ParseAPI()
        
        if let usePutMethod = receivedOverwritePreviousLocation {
            if usePutMethod == true {
                parse.sendStudentLocation(studentInfo, mapString: mapLocation!, updateExistingEntry: true, parseID: receivedParseID)
            } else {
                parse.sendStudentLocation(studentInfo, mapString: mapLocation!, updateExistingEntry: false)
            }
        }
        
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") {
            present(tabBarController, animated: false, completion: nil)
        } else {
            fatalError("Fatal Map Error.")
        }
    }

}
