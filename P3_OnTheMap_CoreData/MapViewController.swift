//
//  MapViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

// todo: list
// 1) update map - handle reload
// 2) handle errors

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    let coreDataHandler = CoreDataHandler()
    // var allStudentLocations: [StudentInfo]?

    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let locations = getStudentLocations()
        
        // make map
        makeMap(locations)
        
    }
    
    func makeMap(_ locations: [StudentInfo]) {
        
        var annotations = [MKPointAnnotation]()
        
        print("LOCATIONS.COUNT = \(locations.count)")
        for item in locations {
            print("Location Last Name: \(item.lastName)")
        }
        
        for dictionary in locations {
            if dictionary.latitude != nil && dictionary.longitude != nil {
                let lat = CLLocationDegrees(Double(dictionary.latitude!)!)
                let long = CLLocationDegrees(Double(dictionary.longitude!)!)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // let first = dictionary.firstName
                guard let first = dictionary.firstName else {
                    print("Error: First Name not found in student data.")
                    return
                }
                // let last = dictionary.lastName
                guard let last = dictionary.lastName else {
                    print("Error: Last Name not found in student data.")
                    return
                }
                
                // let mediaURL = dictionary.mediaURL
                guard let mediaURL = dictionary.mediaURL else {
                    print("Error: mediaURL not found in student data.")
                    return
                }
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            // When the array is complete, we add the annotations to the map.
            DispatchQueue.main.async(execute: { ()-> Void in
                self.mapView.addAnnotations(annotations)
            })
            
        }
    }
    
    
    func updateMap() {
        let locations = getStudentLocations()
        makeMap(locations)
        // loadView()
        
        // hot fix for reload with delegates
        // attempt to remove all annotations then add back?
        let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController")
        present(tabBarController!, animated: false, completion: nil)
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    // Completion Handler
    func updateCompletionHandler(_ isSuccess:Bool) -> Void {
        DispatchQueue.main.async(execute: { ()-> Void in
            if isSuccess == true {
                self.updateMap()
            } else {
                let alert = UIAlertController(title: "Alert", message: "This action requires an internet connection.", preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default, handler: nil)
                alert.addAction(action)
            }
        })
    }
    
    
    @IBAction func reloadMapButton(_ sender: AnyObject) {
        let parseAPI = ParseAPI()
        parseAPI.updateSavedStudentInfo(updateCompletionHandler)
    }

    
    func getStudentLocations() -> [StudentInfo] {
        // let dataHandler = DataHandler()
        let allStudentLocations = coreDataHandler.fetchAllSTudentLocations()
        return allStudentLocations
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
}
