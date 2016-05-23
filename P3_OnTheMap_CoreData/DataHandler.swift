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
    private var appDelegate = AppDelegate()
    
    func saveUserInfoData(studentInfo: StudentInfo) {
        
        let MOC = appDelegate.managedObjectContext
        guard let entity = NSEntityDescription.entityForName("UdacityUserInfo", inManagedObjectContext: MOC) else {
            fatalError("Could not find UdacityUserInfo entity")
        }
        
        let udacityUser = UdacityUserInfo(entity: entity, insertIntoManagedObjectContext: MOC)
    
        udacityUser.firstName = studentInfo.firstName
        udacityUser.lastName = studentInfo.lastName
        udacityUser.latitude = studentInfo.latitude
        udacityUser.longitude = studentInfo.longitude
        udacityUser.mediaURL = studentInfo.mediaURL
        udacityUser.id = studentInfo.studentID
        

        do {
            try MOC.save()
        } catch {
            print("Error saving udacityUser with managed object context")
        }
        
    }
    
    func fetchUserInfoData() {
        
        let MOC = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "UdacityUserInfo")
        
        do {
            if let results = try MOC.executeFetchRequest(fetchRequest) as? [UdacityUserInfo] {
                for result in results {
                    if let student = result.lastName {
                        print("Student name returned: \(student)")
                    }
                }
            }
        } catch {
            print("unable to retrieve student user information")
        }
    }
    
}