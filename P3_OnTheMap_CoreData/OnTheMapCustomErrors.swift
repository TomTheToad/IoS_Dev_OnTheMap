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
        case UnexpectedReturn(description: String)
        case CompoundError(desciption: String)
        case DataConversionError
    }
    
    
    enum ParseAPI2Errors: Error {
        case UnableToParseData
        case NoDataReturned
        case UnableToParseResultsFromData
        case MissingUserData
        case InternalApplicationError_Session
        case UnableToPostToParse
        case PossibleNetworkError
        case UnknownError
    }
    
}
