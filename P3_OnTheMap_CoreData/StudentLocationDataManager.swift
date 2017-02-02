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

    // Use core data to return results
    // Use specific errors to control return
    /*** Public Methods ***/
    func getStudentLocations() -> ([StudentInfo]?, Error?) {
        var thisError: Error?
        
        do {
            try setParseStudentLocations()
            thisError = nil
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
        }
        
        let returnResults = coreDataHandler.fetchAllStudentLocations()
        
        return (returnResults, thisError)
    }
    
    // seeds core data
    func updateSavedStudentLocations() -> Error? {
        var thisError: Error?
        
        do {
            try setParseStudentLocations()
            thisError = nil
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
        }
        return thisError
    }
    
    
    
    // update name
    func getStudentLocationsFetchedResultsController() -> (NSFetchedResultsController<NSFetchRequestResult>, Error?) {
        var thisError: Error?
        
        do {
            try setParseStudentLocations()
            thisError = nil
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
        }
        
        let returnResults = coreDataHandler.fetchAllStudentLocationsResultsController()
        
        return (returnResults, thisError)
    }
    
    
    /*** Parse Methods ***/
    private func setParseStudentLocations() throws -> Void {
        var parseError: Error?
        
        // todo: Error: not escaping the closure!
        parseAPI2.GetParseData(completionHandler: { (dict, error) in
            guard let studentLocations = dict else {
                if let error = error {
                    parseError = error
                    print(error.localizedDescription)
                }
                return
            }
            
            let thisStudentDict = self.studentInfoMethods.buildStudentDictionary(studentLocations)
            
            print("studentDict within closure nil? = \(thisStudentDict.isEmpty)")
            
            if let error = parseError {
                print(error)
            }
            
            do{
                try self.coreDataHandler.saveStudentLocations(thisStudentDict)
            } catch {
                if parseError == nil {
                    parseError = OnTheMapCustomErrors.CoreDataErrors.UnableToSaveToCoreData
                }
            }
        })
    }
    
//    private func parseResultsHandler(studentInfo: [StudentInfo]) -> Void {
//        parseStudentLocations = studentInfo
//        
//        do {
//            try coreDataHandler.saveStudentLocations(studentInfo)
//        } catch {
//            print("Unable to save to core data")
//        }
//    }

}
