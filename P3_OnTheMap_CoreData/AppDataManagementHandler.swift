//
//  StudentLocationHandler.swift
//  OnTheMap
//
//  Class to handle/ Coordinate data requests to ParseAPI and CoreDataHandler.
//
//  Created by VICTOR ASSELTA on 1/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

class AppDataManagementHandler {
    
    // Fields
    var parseAPI2 = ParseAPI2()
    
    // func Get all available student data
    // 1) Check Parse for updated data
    // 2) Return data and update CoreData
    // 3) If unable to contact Parse check CoreData
    // 4) Send Parse error and advise using saved data, send data
    // 5) Both Parse and CoreData failures, send errors, quit application?
    
    // Call
//    asynchronousWork { (inner: () throws -> NSDictionary) -> Void in
//    do {
//    let result = try inner()
//    } catch let error {
//    print(error)
//    }
//    }
    
    // <#T##(() throws -> [NSDictionary]) -> Void#>)
    
    func getStudentLocations() {
        parseAPI2.GetParseData(completionHandler: { (error, dict) in
            guard let studentLocations = dict else {
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                return
            }
            print("Parse2API result = \(studentLocations)")
        })
    }
    
//    func getStudentLocationsCompletionHandler { (inner: () throws -> NSDictionary) -> Void
//        do {
//            let results = try internalCompletionHandler()
//        } catch let error {
//            print(error)
//        }
//        
//    }
//    }
    
    // func Get all available data for one student?
    
    // func Post Student Data
    
    /* ParseAPI */
    
    /* CoreDataHandler */
    
}
