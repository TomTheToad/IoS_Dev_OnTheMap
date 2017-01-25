//
//  StudentLocationDataManager.swift
//  OnTheMap
//
//  Class to handle/ Coordinate data requests to ParseAPI and CoreDataHandler.
//
//  Created by VICTOR ASSELTA on 1/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData

// todo: rename to more relevant name StudentLocationManager?
class StudentLocationDataManager {
    
    // Fields
    fileprivate var parseAPI2 = ParseAPI2()
    fileprivate var coreDataHandler = CoreDataHandler2()
    fileprivate var studentInfoMethods = StudentInfoMethods()
    
    fileprivate var parseError: Error?
    fileprivate var coreDataError: Error?
    
    fileprivate var returnStudentLocations: [StudentInfo]?
    fileprivate var returnStudentLocationResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // Class error enum
    enum SLDMError: Error {
        case parseError
        case coreDataError
    }
    
    // func Get all available student data
    // 1) Check Parse for updated data
    // 2) Return data and update CoreData
    // 3) If unable to contact Parse check CoreData
    // 4) Send Parse error and advise using saved data, send data
    // 5) Both Parse and CoreData failures, send errors, quit application?
    
 /* Solution 1: get everything, sort, send.  */
    
    /*** Parse Methods ***/
    func getStudentLocations() throws -> [StudentInfo] {
        var parseError: Error?
        var studentDict: [StudentInfo]?
        
        parseAPI2.GetParseData(completionHandler: { (dict, error) in
            guard let studentLocations = dict else {
                if let error = error {
                    parseError = error
                    print(error.localizedDescription)

                }
                return
            }
            print("Parse2API result = \(studentLocations)")
            
            // todo: create a seperate method
            studentDict = self.studentInfoMethods.buildStudentDictionary(studentLocations)
            
        })
        if let error = parseError {
            throw error
        }
        
        guard let returnDictionary = studentDict else {
            throw SLDMError.parseError
        }
        
        return returnDictionary
    }
    

    
    /*** CoreDataHandler Methods ***/
    func getLocationFromCoreData() -> [StudentInfo] {
        return coreDataHandler.fetchAllStudentLocations()
    }

    func getLocationsFromCoreDataResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        return coreDataHandler.fetchAllStudentLocationsResultsController()
    }
    
}
