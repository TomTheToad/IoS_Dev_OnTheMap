//
//  UserLocationViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/29/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: clean up

import UIKit
import MapKit

class UserLocationViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    var receivedUserLocation: CLLocation?
    var receivedUserLocationName: String?
    var receivedOverwritePreviousLocation: Bool?
    var receivedParseID: String?
    
    // IBOutlets

    @IBOutlet weak var linkToShareTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MESSAGE3: recievedUserLocation:\(receivedUserLocation?.description) recieveduserLocationName\(receivedUserLocationName)")
        
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
    
    func getUserData() -> UdacityUserInfo {
        let coreDataHandler = CoreDataHandler()
        let userRecord = coreDataHandler.fetchLastUserData()
        return userRecord
    }

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
