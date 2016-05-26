//
//  DataHandler.swift
//  P3_OnTheMap_CoreData
//
//  Created by VICTOR ASSELTA on 5/20/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

class DataHandler {
    
    // Fields
    private var coreDataStack = CoreDataStack()
    private var managedObjectContext: NSManagedObjectContext
    
    
    init () {
        managedObjectContext = coreDataStack.managedObjectContext
    }
    
    
    /* User Information Methods */
    func saveUserInfoData(userLogin: String, studentInfo: StudentInfo) {
        
        let userRecord = fetchUserInfoData(userLogin)
            
            userRecord.firstName = studentInfo.firstName
            userRecord.lastName = studentInfo.lastName
            userRecord.latitude = studentInfo.latitude
            userRecord.longitude = studentInfo.longitude
            userRecord.mediaURL = studentInfo.mediaURL
            userRecord.id = studentInfo.studentID

        coreDataStack.saveMainContext()
        
    }
    
    
    func fetchUserInfoData(userLogin: String) -> UdacityUserInfo {
        
        var userRecord = AnyObject?()
        
        let fetchRequest = NSFetchRequest(entityName: "UdacityUserInfo")
        
        let predicate = NSPredicate(format: "userLogin == %@ ", userLogin)
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [UdacityUserInfo]
            
            if let results = results {
                print("count: \(results.count)")
                if results.count > 0 {
                    userRecord = results[0]
                    
                } else {
                
                guard let entity = NSEntityDescription.entityForName("UdacityUserInfo", inManagedObjectContext: managedObjectContext) else {
                    fatalError("Could not find UdacityUserInfo entity")
                }
            
                userRecord = UdacityUserInfo(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
                    
                }
            }
            
        } catch {
            print("unable to retrieve student user information")
        }
        return userRecord as! UdacityUserInfo
    }
    

    /* Student Location Methods */
    func saveStudentLocations(studentInfoDict: [StudentInfo]) {
        // todo: determine if more efficient to wipe all records or update existing ones
        
        for studentInfo in studentInfoDict {
            
            let studentLocation = fetchOneStudentLocation(studentInfo)
            
            studentLocation.firstName = studentInfo.firstName
            studentLocation.lastName = studentInfo.lastName
            studentLocation.latitude = studentInfo.latitude
            studentLocation.longitude = studentInfo.longitude
            studentLocation.mediaURL = studentInfo.mediaURL
            studentLocation.studentID = studentInfo.studentID
            
        }
        
        coreDataStack.saveMainContext()
    }
    
    
    func fetchOneStudentLocation(student: StudentInfo) -> StudentLocation {
        
        var userRecord = AnyObject?()
        
        let studentID = student.studentID
            
        let fetchRequest = NSFetchRequest(entityName: "StudentLocation")
        
        let predicate = NSPredicate(format: "studentID == %@ ", studentID!)
        fetchRequest.predicate = predicate
            
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [StudentLocation]
            
            if let results = results {
                if results.count > 0 {
                    userRecord = results[0]
                    
                } else {
                    
                    guard let entity = NSEntityDescription.entityForName("StudentLocation", inManagedObjectContext: managedObjectContext) else {
                        fatalError("Could not find StudentLocation entity")
                    }
                    
                    userRecord = StudentLocation(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
                    
                }
                
            }
        } catch {
            print("unable to retrieve student user information")
        }
        return userRecord as! StudentLocation
        
    }
    
    
    // Fetch all student location records for table as a fetchedResultsController
    func fetchAllSTudentLocationsResultsController() -> NSFetchedResultsController {
        
        let request = NSFetchRequest(entityName: "StudentLocation")
        
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
    
    
    func fetchAllSTudentLocations() -> [StudentInfo] {
        
        var returnData = [StudentInfo]()
        
        let fetchRequest = NSFetchRequest(entityName: "StudentLocation")
        
        do {
            
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [StudentLocation]
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
    
    
    func convertStudentLocationArrayToStudentInfoArray(studentLocationArray: [StudentLocation]) -> [StudentInfo] {
        var returnData = [StudentInfo]()
        
        for studentLocation in studentLocationArray {
            var studentInfo = StudentInfo()
            
            studentInfo.firstName = studentLocation.firstName
            studentInfo.lastName = studentLocation.lastName
            studentInfo.studentID = studentLocation.studentID
            studentInfo.mediaURL = studentLocation.mediaURL
            studentInfo.latitude = studentLocation.latitude
            studentInfo.longitude = studentLocation.longitude
            
            returnData.append(studentInfo)
        }
        
        return returnData
        
    }
    
}