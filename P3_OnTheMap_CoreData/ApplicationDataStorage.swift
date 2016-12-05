//
//  ApplicationDataStorage.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/4/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: keep or delete this class?

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
