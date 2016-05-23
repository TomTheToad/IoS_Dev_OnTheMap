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
    
    func saveUserInfoData(userLogin: String, studentInfo: StudentInfo) {
        
        if let existingUser = fetchUserInfoData(userLogin) as? UdacityUserInfo {
            
            existingUser.firstName = studentInfo.firstName
            existingUser.lastName = studentInfo.lastName
            existingUser.latitude = studentInfo.latitude
            existingUser.longitude = studentInfo.longitude
            existingUser.mediaURL = studentInfo.mediaURL
            existingUser.id = studentInfo.studentID
            
            print("Updating existing record")
            
        } else {
        
            guard let entity = NSEntityDescription.entityForName("UdacityUserInfo", inManagedObjectContext: managedObjectContext) else {
                fatalError("Could not find UdacityUserInfo entity")
            }
            
            let udacityUser = UdacityUserInfo(entity: entity, insertIntoManagedObjectContext: managedObjectContext)

            udacityUser.firstName = studentInfo.firstName
            udacityUser.lastName = studentInfo.lastName
            udacityUser.latitude = studentInfo.latitude
            udacityUser.longitude = studentInfo.longitude
            udacityUser.mediaURL = studentInfo.mediaURL
            udacityUser.id = studentInfo.studentID
            udacityUser.userLogin = userLogin
            
            print("Adding new record")
            
            }

        coreDataStack.saveMainContext()
        
    }
    
    func fetchUserInfoData(userLogin: String? = nil) -> AnyObject {
        
        var firstUserRecord = AnyObject?()
        
        let fetchRequest = NSFetchRequest(entityName: "UdacityUserInfo")
        
        if let userLogin = userLogin {
            let predicate = NSPredicate(format: "userLogin == %@ ", userLogin)
            fetchRequest.predicate = predicate
        }
        
        do {
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [UdacityUserInfo] {
                firstUserRecord = results[0]
//                for result in results {
//                    if let login = result.userLogin {
//                        print("Found login: \(login)")
//                    }
//                }
            }
        } catch {
            print("unable to retrieve student user information")
        }
        print("First user record found: \(firstUserRecord!.userLogin)")
        return firstUserRecord!
    }
    
}