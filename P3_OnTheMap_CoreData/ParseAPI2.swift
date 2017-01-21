//
//  ParseAP2I.swift
//  version 2.0
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 1/15/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

class ParseAPI2 {
    
    
    // Fields
    fileprivate var parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    fileprivate var RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    fileprivate var urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
    fileprivate let responseCheck = URLResponseCheck()
    
    
    // Computed Field
    fileprivate var session: URLSession?
    
    
    // Intializer
    init() {
        
        // Create session configuration file with custom timeout
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 20
        
        session = URLSession(configuration: sessionConfig)
    }
    

    /*** Main Methods ***/
    // Get Parse Data.
    // Retrieves current parse student/ location information
    // Takes a completion handler as an argument
    func GetParseData(completionHandler: @escaping (_ error: Error?, [NSDictionary]?) -> Void) {
        
        // Get a parse request
        var request = ReturnParseRequest()
        
        // Add method specific values
        // order the data from most recently updated to oldest update
        request.addValue("=-updatedAt", forHTTPHeaderField: "order")
        // limit the request to the first 100 entries
        request.addValue("100", forHTTPHeaderField: "limit")
        
        // Create task to handle session
        guard let task = session?.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Check for data else return error if data = nil
            guard let data = data else {
                completionHandler(error, nil)
                return
            }
            
            do {
                let results = try self.ConvertJSONToStudentInfoDictionary(data: data)
                completionHandler(nil, results)
            } catch {
                completionHandler((ParseAPIError.UnableToParseData), nil)
            }

        }) else {
            completionHandler((ParseAPIError.InternalApplicationError_Session), nil)
            return
        }
        task.resume()
    }
    
    
    // Check for existing student user submission
    func getOneStudentLocation(parseID: String, completionHandler: @escaping (_ internalCompletionHandler: () throws -> [NSDictionary]) -> Void) -> Void {
        
        // adapt
        let request = self.ReturnParseRequest(parseID: parseID)
        guard let task = session?.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do{
                let results = try self.ConvertJSONToStudentInfoDictionary(data: data)
                completionHandler({return results})
            } catch let error {
                completionHandler({throw error})
            }
        
        }) else {
            return
        }
        task.resume()
    }
    
    
    // post
    // replace previous postStudentLocationMethod
    // Should this be two methods? post and put?
    func postStudentLocation(studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool, parseID: String? = "") throws -> Void {
        
        // Use Post or Put method?
        var httpMethod: String?
        if updateExistingEntry != false, parseID != nil {
            httpMethod = "PUT"
        } else {
            httpMethod = "POST"
        }
        
        // uniqueKey
        guard let uniqueKey = studentInfo.studentID else {
            // uniqueKey missing
            throw ParseAPIError.MissingUserData
        }
        
        // firstName
        guard let firstName = studentInfo.firstName else {
            throw ParseAPIError.MissingUserData
        }
        
        // lastName
        guard let lastName = studentInfo.lastName else {
            throw ParseAPIError.MissingUserData
        }
        // mediaURL
        guard let mediaURL = studentInfo.mediaURL else {
            throw ParseAPIError.MissingUserData
        }
        
        // latitude
        guard let latitude = studentInfo.latitude else {
            throw ParseAPIError.MissingUserData
        }
        // longitude
        guard let longitude = studentInfo.longitude else {
            throw ParseAPIError.MissingUserData
        }
        
        var request = ReturnParseRequest(parseID: parseID)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        
        guard let task = session?.dataTask(with: request) else {
            throw ParseAPIError.InternalApplicationError_Session
        }
        task.resume()
        
        while task.state != .completed {
            // do nothing: block transition to next view controller
            // so alert can be presented if necessary.
        }
        
        if task.error != nil {
            throw task.error!
        }
        
    }
    
    
    /*** Helper Methods ***/
    // Returns preformatted parse request
    // Takes a studentID string if one exists for a post/ put request
    private func ReturnParseRequest(parseID: String? = nil) -> URLRequest {
        
        var parseURL: URL
        
        if let id = parseID {
            parseURL = URL(string: urlString.appending(id))!
        } else {
            parseURL = URL(string: urlString)!
        }
        
        var request = URLRequest(url: parseURL)
        
        request.addValue("\(parseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(RESTApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request
    }
    
    
    // Enumeration for application/JSON specific errors
    private enum ParseAPIError: Error {
        case UnableToParseData
        case UnableToParseResultsFromData
        case MissingUserData
        case InternalApplicationError_Session
        case UnableToPostToParse
        case UnknownError
    }
    
    
    // Parse return data from JSON
    // Takes JSON data
    // Returns [NSDictionary]
    private func ConvertJSONToStudentInfoDictionary(data: Data) throws -> [NSDictionary] {
        
        var parsedData: NSDictionary?
        
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        } catch {
            print("WARNING: Unable to parse data \(data)")
            throw ParseAPIError.UnableToParseData
        }
        
        guard let results = parsedData!["results"] as? [NSDictionary] else {
            throw ParseAPIError.UnableToParseResultsFromData
        }
        
        return results
    }
    
}
