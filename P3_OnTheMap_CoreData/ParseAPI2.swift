//
//  ParseAP2I.swift
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
    
    // Helper Methods
    func ReturnParseRequest(studentID: String? = nil) -> URLRequest {
        
        var parseURL: URL
        
        if let id = studentID {
            parseURL = URL(string: urlString.appending(id))!
        } else {
            parseURL = URL(string: urlString)!
        }
        
        var request = URLRequest(url: parseURL)
        
        request.addValue("\(parseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(RESTApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request
    }
    
    
    init() {
        
        // Create session configuration file with custom timeout
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 20
        
        session = URLSession(configuration: sessionConfig)
    }
    
    
    // Get Parse Data.
    // Takes a completion handler as an argument
    func GetParseData(_ completionHandler: @escaping (([StudentInfo])->Void)) throws {
        
        // Get a parse request
        var request = ReturnParseRequest()
        
        // Add method specific values
        // ask api to order the data from most recently updated to oldest update
        request.addValue("=-updatedAt", forHTTPHeaderField: "order")
        // limit the request to the first 100 entries
        request.addValue("100", forHTTPHeaderField: "limit")
        
        // Create task to handle session
        let task = session?.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Check for data else return error if data = nil
            guard let data = data else {
                // todo: throw error?
                print(error)
            }
            
            var parsedData: NSDictionary?
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
            } catch {
                print("WARNING: Unable to parse data \(data)")
            }
            
            guard let results = parsedData!["results"] as? [NSDictionary] else {
                print("WARNING: Unable to parse results from \(parsedData)")
                return
            }
            
            
            print("### Begin Results ###")
            print(results)
            print("### End Results ###")
            
            let studentInfo = StudentInfoMethods()
            let studentInfoDict = studentInfo.buildStudentDictionary(results)
            
            
            completionHandler(true)
            
        })
        task.resume()
    }
    
    
    // Check for existing student user submission
    fileprivate func getStudentLocation(studentID: String) {
        
        // adapt
        let request = NSMutableURLRequest(url: ParseURL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
        }
        task.resume()
    }
    
    
    // post
    // replace previous postStudentLocationMethod
    // Should this be two methods? post and put?
    // Create a public method for this?
    fileprivate func sendStudentLocation(_ studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool, parseID: String? = "", errorHandler: @escaping (_ isSuccess: Bool)->Void ) {
        
        // Use Post or Put method?
        var httpMethod: String?
        var urlString: URL?
        if updateExistingEntry == true {
            httpMethod = "PUT"
            if let ID = parseID {
                urlString = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(ID)")
            } else {
                print("ERROR: Invalid objectID, switching to POST method")
                httpMethod = "POST"
                urlString = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")
            }
        } else {
            httpMethod = "POST"
            urlString = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")
        }
        
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
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = httpMethod
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                print("ERROR: could not post to parse")
                errorHandler(false)
                return
            } else {
                errorHandler(true)
            }
        })
        task.resume()
        
    }
    
}
