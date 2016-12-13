//
//  TableViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/26/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: list
// 1) clean up code
// 2) reload/ update
// 3) handle errors gracefully

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Fields
    let coreDataHandler = CoreDataHandler()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        fetchedResultsController = coreDataHandler.fetchAllSTudentLocationsResultsController()

    }

    
    fileprivate func setStudentLocationResultsController() {
        fetchedResultsController = coreDataHandler.fetchAllSTudentLocationsResultsController()
    }
    
    
    // update table data
    func updateTableData() {
        setStudentLocationResultsController()
        tableView.reloadData()
    }

    
    // rename method to correspond with similar mapView method.
    @IBAction func reloadTableDataButton(_ sender: AnyObject) {
        // todo: call an actual update, not just a Core Data query
        let parseAPI = ParseAPI()
        parseAPI.updateSavedStudentInfo(updateCompletionHandler)
        
    }
    
    
    @IBAction func logoutButtonFunction(_ sender: AnyObject) {
        let udacityAPI = UdacityAPI()
        udacityAPI.doUdacityLogout()
        
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        
        let alert = UIAlertController(title: "User Status", message: "Logout Successful", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "ok", style: .default, handler: { (action: UIAlertAction) in
            self.present(loginViewController!, animated: false, completion: nil)
        })
        
        alert.addAction(action)
        present(alert, animated: false)
    }
    
    
    // Completion Handler
    func updateCompletionHandler(_ isSuccess:Bool) -> Void {
        DispatchQueue.main.async(execute: { ()-> Void in
            if isSuccess == true {
                self.updateTableData()
            } else {
                let alert = UIAlertController(title: "Alert", message: "This action requires an internet connection.", preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .default, handler: nil)
                alert.addAction(action)
            }
        })
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections?[section].numberOfObjects ?? 0
    }
    
    
    // todo: add link to share
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinNameCell", for: indexPath) as!TableViewCell
        
        let studentLocation = fetchedResultsController?.object(at: indexPath) as! StudentLocation
        
        if let studentFirstName = studentLocation.firstName, let studentLastName = studentLocation.lastName {
            cell.locationTitle.text = "\(studentFirstName) \(studentLastName)"
        } else {
            cell.locationTitle.text = "n/a"
        }
        
        if let studentMediaURL = studentLocation.mediaURL {
            cell.mediaURL = "\(studentMediaURL)"
        } else {
            cell.mediaURL = ""
        }
        
        return cell
    }
}
