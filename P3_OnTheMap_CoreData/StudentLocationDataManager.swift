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

    
    /*** Public Methods ***/
    func getStudentLocations() -> ([StudentInfo]?, Error?) {
        var returnResults: [StudentInfo]?
        var thisError: Error?
        
        do {
            returnResults = try getParseStudentLocations()
            thisError = nil
            try coreDataHandler.saveStudentLocations(returnResults!)
        } catch {
            returnResults = coreDataHandler.fetchAllStudentLocations()
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
        }
        
        return (returnResults, thisError)
    }
    
    // seeds core data
    func updateSavedStudentLocations() -> Error? {
        var thisError: Error?
        
        do {
            let returnResults = try getParseStudentLocations()
            try coreDataHandler.saveStudentLocations(returnResults)
            thisError = nil
        } catch {
            thisError = OnTheMapCustomErrors.CoreDataErrors.CompoundError(desciption: "Broken Data Pipe")
        }
        return thisError
    }
    
    
    
    // update name
    func getStudentLocationsFetchedResultsController() -> (NSFetchedResultsController<NSFetchRequestResult>, Error?) {
        var thisError: Error?
        
        do {
            let results = try getParseStudentLocations()
            thisError = nil
            try coreDataHandler.saveStudentLocations(results)
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
        }
        
        let returnResults = coreDataHandler.fetchAllStudentLocationsResultsController()
        
        return (returnResults, thisError)
    }
    
    
    /*** Parse Methods ***/
    func getParseStudentLocations() throws -> [StudentInfo] {
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
            
            studentDict = self.studentInfoMethods.buildStudentDictionary(studentLocations)
            
        })
        if let error = parseError {
            throw error
        }
        
        guard let returnDictionary = studentDict else {
            throw OnTheMapCustomErrors.ParseAPI2Errors.UnableToParseData
        }
        
        return returnDictionary
    }
    
}
