//
//  DataHandler.swift
//  P3_OnTheMap_CoreData
//
//  Created by VICTOR ASSELTA on 5/20/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: clean up code

/* 
 
 Custom class which handles interactions with core data for this specific application.
 Uses custom coreDataStack singleton which provides a single managed object context.
 
 */

import Foundation
import CoreData

class CoreDataHandler {
    
    // Fields
    // Custom Core Data Stack and MOC
    var coreDataStack = AppDelegate().getCoreDataStack()
    fileprivate var managedObjectContext: NSManagedObjectContext
    
    
    init () {
        managedObjectContext = coreDataStack.managedObjectContext
    }
    

    /* User Information Methods */
    // Save users Information to Core Data
    // Takes user's login and user information formatted as StudentInfo
    func saveUserInfoData(_ userLogin: String, studentInfo: StudentInfo) {
        
        let userRecord = fetchUserInfoData(userLogin)
            
            userRecord.firstName = studentInfo.firstName
            userRecord.lastName = studentInfo.lastName
            userRecord.latitude = studentInfo.latitude
            userRecord.longitude = studentInfo.longitude
            userRecord.mediaURL = studentInfo.mediaURL
            userRecord.studentID = studentInfo.studentID

        coreDataStack.saveMainContext()
    }
    
    
    // Get last added user, current user, information
    // Returns UdacityUserInfo
    func fetchLastUserData() -> UdacityUserInfo {
        
        var userRecord: UdacityUserInfo?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UdacityUserInfo")
        
        do {
            userRecord = try managedObjectContext.fetch(fetchRequest).last as? UdacityUserInfo
        } catch {
            fatalError("Unable to located user data")
        }
        
        return userRecord!
    }
    
    
    // Fetch a specific users information
    // todo: delete this?
    // takes userLogin as String
    // Returns UdacityUserInfo
    func fetchUserInfoData(_ userLogin: String) -> UdacityUserInfo {
        
        // todo: syntax change for Swift3. May have to rework type
        var userRecord = AnyObject?(self)
        
        // Updated to Swift3 syntax
        //  let fetchRequest = NSFetchRequest(entityName: "UdacityUserInfo")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UdacityUserInfo")
        
        let predicate = NSPredicate(format: "userLogin == %@ ", userLogin)
        fetchRequest.predicate = predicate
        // print("predicate: \(predicate)")
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as? [UdacityUserInfo]
            print("results: \(results)")
            
            if let results = results {
                print("count: \(results.count)")
                print("results: \(results)")
                
                if results.count > 0 {
                    userRecord = results[0]
                    
                } else {
                
                guard let entity = NSEntityDescription.entity(forEntityName: "UdacityUserInfo", in: managedObjectContext) else {
                    fatalError("Could not find UdacityUserInfo entity")
                }
            
                userRecord = UdacityUserInfo(entity: entity, insertInto: managedObjectContext)
                    
                }
            }
            
        } catch {
            print("unable to retrieve student user information")
        }
        print("userRecord keys: \(userRecord?.allKeys), userRecord values: \(userRecord?.allValues)")
        
        return userRecord as! UdacityUserInfo
    }
    

    /* Student Location Methods */
    // Saves an array of student location information
    // takes an array of StudentInfo dictionaries
    func saveStudentLocations(_ studentInfoDict: [StudentInfo]) {
        // todo: determine if more efficient to wipe all records or update existing ones
        
        for studentInfo in studentInfoDict {
            
            let studentLocation = fetchOneStudentLocation(studentInfo)
            
            studentLocation.firstName = studentInfo.firstName
            studentLocation.lastName = studentInfo.lastName
            studentLocation.latitude = studentInfo.latitude
            studentLocation.longitude = studentInfo.longitude
            studentLocation.mediaURL = studentInfo.mediaURL
            studentLocation.studentID = studentInfo.studentID
            studentLocation.parseID = studentInfo.parseID
            
        }
        
        coreDataStack.saveMainContext()
    }
    
    
    // Check to see if a previous entry exists based on studentID
    // takes studentID as String
    // Returns a tuple of Bool (location found) and String (Given parse ID)
    func checkLocationExists(studentID: String) -> (Bool, String?) {
        
        var isSuccess: Bool?
        var userParseID: String?
        
        // Updated to Swift3 syntax
        // let fetchRequest = FetchRequest(entityName: "StudentLocation")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StudentLocation")

        let predicate = NSPredicate(format: "studentID == %@ ", studentID)
        fetchRequest.predicate = predicate
        
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest).last as? StudentLocation
            
            if let result = results {
                print("Alert: Previous student location for user found: \(result.studentID)")
                isSuccess = true
                userParseID = result.parseID
                
            } else {
                isSuccess = false
            }
            
        } catch {
            print("unable to retrieve student user information")
            isSuccess = false
        }
        
        return (isSuccess!, userParseID)
        
    }
    
    
    // Fetch a single student's location
    // todo: is this used?
    // Takes StudentInfo
    // Returns StudentLocation
    func fetchOneStudentLocation(_ student: StudentInfo) -> StudentLocation {
        
        var userRecord = AnyObject?(self)
        
        // Updated to Swift3 syntax
        // let fetchRequest = FetchRequest(entityName: "StudentLocation")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StudentLocation")
        
        
        if let ID = student.studentID {
            let predicate = NSPredicate(format: "studentID == %@ ", ID)
            fetchRequest.predicate = predicate
        }
        
            
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as? [StudentLocation]
            
            if let results = results {
                if results.count > 0 {
                    userRecord = results[0]
                    
                } else {
                    
                    guard let entity = NSEntityDescription.entity(forEntityName: "StudentLocation", in: managedObjectContext) else {
                        fatalError("Could not find StudentLocation entity")
                    }
                    
                    userRecord = StudentLocation(entity: entity, insertInto: managedObjectContext) 
                }
                
            }
        } catch {
            print("unable to retrieve student user information")
        }
        return userRecord as! StudentLocation
        
    }
    
    
    // Fetch all student location records for table as a fetchedResultsController
    // Returns NSFetchResultsController (still uses NS prefix) of student locations.
    func fetchAllSTudentLocationsResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        // let request = NSFetchRequest(entityName: "StudentLocation")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StudentLocation")
        
        let lastNameSort = NSSortDescriptor(key: "lastName", ascending: true)
        
        request.sortDescriptors = [lastNameSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to fetch student location data")
        }
        
        return fetchedResultsController
    }
    
    
    // Fetch all student location
    // Returns an array of StudentInfo
    func fetchAllSTudentLocations() -> [StudentInfo] {
        
        var returnData = [StudentInfo]()
        
        // let fetchRequest = NSFetchRequest(entityName: "StudentLocation")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StudentLocation")
        
        do {
            
            let results = try managedObjectContext.fetch(fetchRequest) as? [StudentLocation]
            if let results = results {
                returnData = convertStudentLocationArrayToStudentInfoArray(results)
            } else {
                print("Unable to convert returnedData to array of StudentLocation")
            }
        } catch {
            print("unable to retrieve student user information")
        }
        
        return returnData
    }
    
    
    // Helper function to convert student location to student information format
    // Takes and array of StudentLcation
    // Returns and array of StudentInfo
    func convertStudentLocationArrayToStudentInfoArray(_ studentLocationArray: [StudentLocation]) -> [StudentInfo] {
        var returnData = [StudentInfo]()
        
        for studentLocation in studentLocationArray {
            var studentInfo = StudentInfo()
            
            studentInfo.firstName = studentLocation.firstName
            studentInfo.lastName = studentLocation.lastName
            studentInfo.studentID = studentLocation.studentID
            studentInfo.mediaURL = studentLocation.mediaURL
            studentInfo.latitude = studentLocation.latitude
            studentInfo.longitude = studentLocation.longitude
            studentInfo.parseID = studentLocation.parseID
            
            returnData.append(studentInfo)
        }
        
        return returnData
        
    }
    
}
