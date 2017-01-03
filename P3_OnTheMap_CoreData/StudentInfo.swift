//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/3/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/*
 
Basic struct for student information management.

*/

import Foundation

struct StudentInfo {
    
    // Basic student information
    var studentID: String?
    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var parseID: String?
    
    // Student location
    var latitude: String?
    var longitude: String?
    
    init() {
        
    }
    
    //init method
    init(studentDictionary: [String: String] ) {
        
        // studentID
        if let thisID = studentDictionary["studentID"] {
            studentID = thisID
        }
        
        // firstName
        if let thisFirstName = studentDictionary["firstName"] {
            firstName = thisFirstName
        }
        
        // lastName
        if let thisLastName = studentDictionary["lastName"] {
            lastName = thisLastName
        }
        
        // mediaURL
        if let thisMediaURL = studentDictionary["mediaURL"] {
            mediaURL = thisMediaURL
        }
        
        // parseID
        if let thisParseID = studentDictionary["parseID"] {
            parseID = thisParseID
        }
        
        // latitude
        if let thisLatitude = studentDictionary["latitude"] {
            latitude = thisLatitude
        }
        
        // longitude
        if let thisLongitude = studentDictionary["longitude"] {
            longitude = thisLongitude
        }
    }

}
