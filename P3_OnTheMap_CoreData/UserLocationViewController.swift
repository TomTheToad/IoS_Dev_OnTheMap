//
//  UserLocationViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/29/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

import UIKit
import MapKit

class UserLocationViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    var receivedUserLatitude: CLLocationDegrees?
    var receivedUserLongitude: CLLocationDegrees?
    var receivedUserLocation: CLLocation?
    
    // IBOutlets

    @IBOutlet weak var linkToShareTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!

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

    @IBAction func submitButton(_ sender: AnyObject) {
        
//        let parse = ParseAPI()
//
//        if let link = linkToShareTextView.text {
//           parse.postStudentLocation(<#T##studentInfo: StudentInfo##StudentInfo#>, mapString: <#T##String#>)
//            
//        }
        
        
        
    }

}
