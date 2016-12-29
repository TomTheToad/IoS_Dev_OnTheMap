//
//  ApplicationDataStorage.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/4/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/*
 
 This was a requirement at one point.
 This class serves current purpose and can be deleted.
 I'm leaving it for now just in the case that requirement still exists, somewhere.
 
*/

import Foundation

class ApplicationDataStorage {
    
    static let sharedInstance = ApplicationDataStorage()
    
    
    // Fields
    
    // Application User Info
    var userInfo: StudentInfo?
    
    // Student Locations
    var studentInformation: [StudentInfo]?
    
    
    fileprivate init() {
    // Leave to prevent breaking the singleton pattern
    
    }
}
