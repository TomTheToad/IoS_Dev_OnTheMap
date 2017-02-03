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

    
    // get locations
    func getStudentLocations() -> ([StudentInfo]?, Error?) {
        var thisError: Error?

        do {
            try updateLocalStudentLocations()
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError
        }
        
        // make coreData function throw
        let returnResults = coreDataHandler.fetchAllStudentLocations()

        return (returnResults, thisError)
    }
    
    
    // get fetched results controller
    func getStudentLocationsFetchedResultsController() -> (NSFetchedResultsController<NSFetchRequestResult>, Error?) {
        var thisError: Error?
        

        do {
            try updateLocalStudentLocations()
        } catch {
            thisError = OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError
        }
        
        
        let returnResults = coreDataHandler.fetchAllStudentLocationsResultsController()
        
        return (returnResults, thisError)
    }
    
    
    // update local
    func updateLocalStudentLocations() throws -> Void {
        
        let task = parseAPI2.GetParseData(completionHandler: { (dict, error) in
            // removed error handling so task will throw an error in the event
            guard let studentLocations = dict else {
                if error != nil {
                    print(OnTheMapCustomErrors.ParseAPI2Errors.NoDataReturned.localizedDescription)
                }
                return
            }
            
            let studentDict = self.studentInfoMethods.buildStudentDictionary(studentLocations)
                
            do {
                try self.coreDataHandler.saveStudentLocations(studentDict)
            } catch {
                print(OnTheMapCustomErrors.CoreDataErrors.UnableToSaveToCoreData.localizedDescription)
                return
            }
            
        })
        task.resume()
        while task.state != .completed {
            if task.error != nil {
                throw OnTheMapCustomErrors.ParseAPI2Errors.UnknownError
            }
        }
    }

}
