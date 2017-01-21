//
//  StudentLocationManager.swift
//  OnTheMap
//
//  Class to handle/ Coordinate data requests to ParseAPI and CoreDataHandler.
//
//  Created by VICTOR ASSELTA on 1/16/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

// todo: rename to more relevant name StudentLocationManager?
class StudentLocationManager {
    
    // Fields
    fileprivate var parseAPI2 = ParseAPI2()
    fileprivate var coreDataHandler = CoreDataHandler()
    fileprivate var studentInfoMethods = StudentInfoMethods()
    
    // Class error enum
    enum SLMError: Error {
        case parseError
        case coreDataError
    }
    
    // func Get all available student data
    // 1) Check Parse for updated data
    // 2) Return data and update CoreData
    // 3) If unable to contact Parse check CoreData
    // 4) Send Parse error and advise using saved data, send data
    // 5) Both Parse and CoreData failures, send errors, quit application?
    
 
    
    /*** Parse Methods ***/
    // todo: convert data
    // todo: save to core data
    // todo: logic to choose source
    // todo: react to failure points
    func getStudentLocations() throws -> [StudentInfo] {
        var parseError: Error?
        var studentDict: [StudentInfo]?
        
        parseAPI2.GetParseData(completionHandler: { (error, dict) in
            guard let studentLocations = dict else {
                if let error = error {
                    parseError = error
                    print(error.localizedDescription)
                    return
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
            throw SLMError.parseError
        }
        
        return returnDictionary
    }
    

    
    /*** CoreDataHandler Methods ***/

    
}
