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
    
    
    // Helper Methods
    // Returns preformatted parse request
    // Takes a studentID string if one exists for a post/ put request
    func ReturnParseRequest(parseID: String? = nil) -> URLRequest {
        
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
    enum JSONErrors: Error {
        case UnableToParseData
        case UnableToParseResultsFromData
        case UnknownError
    }
    
    
    // Parse return data from JSON
    // Takes JSON data
    // Returns [NSDictionary]
    func ConvertJSONToStudentInfoDictionary(data: Data) throws -> [NSDictionary] {
        
        var parsedData: NSDictionary?
        
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        } catch {
            print("WARNING: Unable to parse data \(data)")
            throw JSONErrors.UnableToParseData
        }
        
        guard let results = parsedData!["results"] as? [NSDictionary] else {
            throw JSONErrors.UnableToParseResultsFromData
        }
        
        return results
    }
    
    
//    func asynchronousWork(completion: (inner: () throws -> NSDictionary) -> Void) -> Void {
//        NSURLConnection.sendAsynchronousRequest(request, queue: queue) {
//            (response, data, error) -> Void in
//            guard let data = data else { return }
//            do {
//                let result = try NSJSONSerialization.JSONObjectWithData(data, options: [])
//                    as! NSDictionary
//                completion(inner: {return result})
//            } catch let error {
//                completion(inner: {throw error})
//            }
//        }
//    }
    
    // Get Parse Data.
    // Retrieves current parse student/ location information
    // Takes a completion handler as an argument
    func GetParseData(completionHandler: @escaping (_ internalCompletionHandler: () throws -> [NSDictionary]) -> Void) -> Void {
        
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
                return
            }
            
            do{
                let results = try self.ConvertJSONToStudentInfoDictionary(data: data)
                completionHandler({return results})
            } catch let error {
                completionHandler({throw error})
            }
            
// todo: sent this to new class StudentInformationHandler
//            let studentInfo = StudentInfoMethods()
//            let studentInfoDict = studentInfo.buildStudentDictionary(results)
            
        }) else {
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
    // Create a public method for this?
    fileprivate func postStudentLocation(studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool, parseID: String? = "", errorHandler: @escaping (_ isSuccess: Bool,_ errorMessage: String)->Void ) {
        
        // Use Post or Put method?
        var httpMethod: String?
        if updateExistingEntry != false, parseID != nil {
            httpMethod = "PUT"
        } else {
            httpMethod = "POST"
        }
        
        var request = ReturnParseRequest(parseID: parseID)
        
        // uniqueKey
        guard let uniqueKey = studentInfo.studentID else {
            return
        }
        // firstName
        guard let firstName = studentInfo.firstName else {
            return
        }
        // lastName
        guard let lastName = studentInfo.lastName else {
            return
        }
        // mediaURL
        guard let mediaURL = studentInfo.mediaURL else {
            return
        }
        // latitude
        guard let latitude = studentInfo.latitude else {
            return
        }
        // longitude
        guard let longitude = studentInfo.longitude else {
            return
        }
        
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        
        guard let task = session?.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                print("ERROR: could not post to parse")
                errorHandler(false, "Cound not post to parse")
                return
            } else {
                errorHandler(true, "")
            }
        }) else {
            errorHandler(false, "Unknown Session Failure. Please try again later.")
            return
        }
        task.resume()
        
    }
    
}
