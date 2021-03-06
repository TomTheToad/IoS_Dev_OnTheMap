//
//  TableViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/26/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/* 
 
 Controller for tableView displaying udacity user names.

*/

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Fields
    // let coreDataHandler = CoreDataHandler()
    var studentLocationDataManager = StudentLocationDataManager()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        setStudentLocationResultsController()

    }

    
    // Results controller for table data update
    fileprivate func setStudentLocationResultsController() {
        
        let fetchedResultsTuple = studentLocationDataManager.getStudentLocationsFetchedResultsController()
        
        if fetchedResultsTuple.1 != nil {
            let alert = OKAlertGenerator(alertMessage: "No Data. Please check your net connection.")
            present(alert.getAlertToPresent(), animated: false)
        }
        
        fetchedResultsController = fetchedResultsTuple.0

    }
    
    
    // small macro to update table data
    func updateTableData() {
        setStudentLocationResultsController()
        tableView.reloadData()
    }

    
    // reload table data
    @IBAction func reloadTableDataButton(_ sender: AnyObject) {
        setStudentLocationResultsController()
    }
    
    
    // Call udacity logout
    @IBAction func logoutButtonFunction(_ sender: AnyObject) {
        let udacityAPI = UdacityAPI()
        udacityAPI.doUdacityLogout()
        
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        
        let alert = OKAlertGenerator(alertMessage: "Logout Successful")
        alert.title = "Status"
        alert.handler = {(action: UIAlertAction) in self.present(loginViewController!, animated: false, completion: nil)}
        
        present(alert.getAlertToPresent(), animated: false)
    }
    
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections?[section].numberOfObjects ?? 0
    }
    
    
    // configure table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinNameCell", for: indexPath) as!TableViewCell
        
        let studentLocation = fetchedResultsController?.object(at: indexPath) as! StudentLocation
        
        var title: String?
        
        // Checking student's first name is not nil
        // Maybe add check for "" as some of these seem to make it into the database.
        if let studentFirstName = studentLocation.firstName {
            title = "\(studentFirstName)"
        }
        
        // Checking student's last name is not nil and updating
        // title accordingly.
        if let studentLastName = studentLocation.lastName {
            if title != nil {
                title = title! + " \(studentLastName)"
            } else {
                title = " \(studentLastName)"
            }
        }
        
        // Making sure title is not nil and change to
        // Udacity User if it is.
        if let thisTitle = title {
            cell.locationTitle.text = thisTitle
        } else {
            cell.locationTitle.text = "Udacity User"
        }
        
        
        // Checking for non nil URL link.
        if let studentMediaURL = studentLocation.mediaURL {
            cell.mediaURL = "\(studentMediaURL)"
        } else {
            cell.mediaURL = nil
        }
        
        return cell
    }
    
    
    // Alternative to didSelectRow, seems to be working
    // didSelectRow was creating an issue with unintended rows being selected
    // during basic navigation.
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        
        let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
        
        if let urlString = cell?.mediaURL {
            if let url = URL(string: urlString) {
                // app.openURL(url)
                app.open(url, options: [:], completionHandler: nil)
            } else {
                // print("Invalid URL")
            }
        } else {
            // print("No URL given")
        }
    }
}
