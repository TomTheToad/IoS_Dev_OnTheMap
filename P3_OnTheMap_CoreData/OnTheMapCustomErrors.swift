//
//  OnTheMapCustomErrors.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 1/24/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
public class OnTheMapCustomErrors {

    enum CoreDataErrors: Error {
        case UnableToSaveToCoreData
        case UnableToSaveToMainObjectContext
    }
    
    
    enum ParseAPI2Errors: Error {
        case UnableToParseData
        case NoDataReturned
        case UnableToParseResultsFromData
        case MissingUserData
        case InternalApplicationError_Session
        case UnableToPostToParse
        case UnknownError
    }
    
}
