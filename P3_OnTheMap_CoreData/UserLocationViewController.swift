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
    
    // IBOutlets

    @IBOutlet weak var linkToShareTextView: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = CLLocationCoordinate2D(latitude: receivedUserLatitude!, longitude: receivedUserLongitude!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        let coordinate = CLLocationCoordinate2D(latitude: receivedUserLatitude!, longitude: receivedUserLongitude!)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Look Here!"
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)

    }

    @IBAction func submitButton(sender: AnyObject) {
        
//        let parse = ParseAPI()
//
//        if let link = linkToShareTextView.text {
//           parse.postStudentLocation(<#T##studentInfo: StudentInfo##StudentInfo#>, mapString: <#T##String#>)
//            
//        }
    }

}
