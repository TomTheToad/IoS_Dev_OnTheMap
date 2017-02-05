//
//  StudentLocationDataManager.swift
//  OnTheMap
//
//  Class to handle/ Coordinate data requests to ParseAPI and CoreDataHandler.
//  This was part of an attempt to allow each class to handle a very specific job
//
//  Created by VICTOR ASSELTA on 1/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import CoreData

// Class designed to specifically to direct/ manage data
class StudentLocationDataManager: UIViewController {
    
    // Fields
    fileprivate var parseAPI2 = ParseAPI2()
    fileprivate var coreDataHandler = CoreDataHandler2()
    fileprivate var studentInfoMethods = StudentInfoMethods()
    
    
    // Calls for an update, retrieves the data, and returns it
    // Takes no arguments
    // Returns a tuple with StudentInfo and any Errors.
    func getStudentLocations() -> ([StudentInfo]?, Error?) {
        var returnResults: [StudentInfo]?
        var thisError: Error?

        do {
            try updateLocalStudentLocations()
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError
        }
        
        do {
            returnResults = try coreDataHandler.fetchAllStudentLocations()
            if (returnResults?.isEmpty)! {
                thisError = OnTheMapCustomErrors.CoreDataErrors.CompoundError(desciption: "Unknown")
            }
        } catch {
            thisError = OnTheMapCustomErrors.CoreDataErrors.UnexpectedReturn(description: "Missing Data")
        }

        return (returnResults, thisError)
    }
    
    
    // Calls for an update, retrieves the data, and returns it
    // Takes no arguments
    // Returns an NSFetechedResultsController for a TableView and any errors
    func getStudentLocationsFetchedResultsController() -> (NSFetchedResultsController<NSFetchRequestResult>?, Error?) {
        var resultsController: NSFetchedResultsController<NSFetchRequestResult>?
        var thisError: Error?
        

        do {
            try updateLocalStudentLocations()
            
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError
            print(thisError)
        }
        
        do {
            resultsController = try coreDataHandler.fetchAllStudentLocationsResultsController()
            if resultsController?.fetchedObjects?.count == 0 {
                thisError = OnTheMapCustomErrors.CoreDataErrors.CompoundError(desciption: "Unknown Error")
            }
        } catch {
            thisError = OnTheMapCustomErrors.CoreDataErrors.UnexpectedReturn(description: "Missing ResultsController")
        }
        
        return (resultsController, thisError)
    }
    
    
    // Updates local core data storage
    func updateLocalStudentLocations() throws -> Void {
        
        let task = parseAPI2.GetParseData(completionHandler: { (dict, error) in
            
            if error != nil {
                // This will be caught in nil check from calling method
                // todo: more specific error handling
                print("WARNING: \(OnTheMapCustomErrors.ParseAPI2Errors.UnknownError.localizedDescription)")
            }
            
            if let studentLocations = dict {
                let studentDict = self.studentInfoMethods.buildStudentDictionary(studentLocations)
                do {
                    try self.coreDataHandler.saveStudentLocations(studentDict)
                } catch {
                    // This will be caught in nil check from calling function
                }
            }
            
        })
        
        task.resume()
        
        while task.state != .completed {
            if task.error != nil {
                throw OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError
            }
        }

    }
}
