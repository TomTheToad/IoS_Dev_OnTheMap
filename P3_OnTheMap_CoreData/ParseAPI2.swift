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
    
    // Type Aliases
    typealias ParseResult = ([NSDictionary]?, Error?) -> Void
    typealias ParseResultWithError = ([NSDictionary]?, Error?) throws -> Void
    
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
    func GetParseData(completionHandler: @escaping ParseResult) -> URLSessionDataTask {
        
        // Get a parse request
        var request = ReturnParseRequest()
        
        // Add method specific values
        // order the data from most recently updated to oldest update
        request.addValue("=-updatedAt", forHTTPHeaderField: "order")
        // limit the request to the first 100 entries
        request.addValue("100", forHTTPHeaderField: "limit")
        
        // Create task to handle session
        let task = session!.dataTask(with: request, completionHandler: { (data, response, error) in
            
            let responseCheck = URLResponseCheck()
            if let thisResponse = response {
                let returnTuple = responseCheck.checkReponse(thisResponse)
                if returnTuple.0 != true {
                    completionHandler(nil, OnTheMapCustomErrors.ParseAPI2Errors.PossibleNetworkError)
                    print(returnTuple.1)
                }
            }
            
            guard let data = data else {
                OperationQueue.main.addOperation {
                    completionHandler(nil, error)
                }
                return
            }
            
            do {
                let results = try self.ConvertJSONToStudentInfoDictionary(data: data)
                    OperationQueue.main.addOperation {
                        completionHandler(results, nil)
                }
            } catch {
                OperationQueue.main.addOperation {
                        completionHandler(nil, OnTheMapCustomErrors.ParseAPI2Errors.UnableToParseResultsFromData)
                }
            }

        })
        task.resume()
        return task
    }
    
    
    // Check for existing student user submission
    func getOneStudentLocation(parseID: String, completionHandler: @escaping ParseResult) {
        
        // adapt
        let request = self.ReturnParseRequest(parseID: parseID)
        guard let task = session?.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard let data = data else {
            OperationQueue.main.addOperation {
                    completionHandler(nil, error)
                }
                return
            }
            
            do{
                let results = try self.ConvertJSONToStudentInfoDictionary(data: data)
            OperationQueue.main.addOperation {
                    completionHandler(results, nil)
                }
            } catch {
                OperationQueue.main.addOperation {
                    completionHandler(nil, OnTheMapCustomErrors.ParseAPI2Errors.UnableToParseResultsFromData)
                }
            }
        
        }) else {
            return
        }
        task.resume()
    }
    
    
    // post
    // replace previous postStudentLocationMethod
    // Should this be two methods? post and put?
    func postStudentLocation(studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool) throws -> Void {
        
        // todo: Do these need to throw errors?
        // uniqueKey
        guard let uniqueKey = studentInfo.studentID else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        // firstName
        guard let firstName = studentInfo.firstName else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        // lastName
        guard let lastName = studentInfo.lastName else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        // mediaURL
        guard let mediaURL = studentInfo.mediaURL else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        // latitude
        guard let latitude = studentInfo.latitude else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        // longitude
        guard let longitude = studentInfo.longitude else {
           throw OnTheMapCustomErrors.ParseAPI2Errors.MissingUserData
        }
        
        let parseID: String
        if let ID = studentInfo.parseID {
            parseID = ID
        } else {
            parseID = ""
        }
        
        // Use Post or Put method?
        var httpMethod: String?
        if updateExistingEntry != false {
            httpMethod = "PUT"
        } else {
            httpMethod = "POST"
        }
        
        var request = ReturnParseRequest(parseID: parseID)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        // todo: clean up body with components build
        // let components = NSURLComponents()
        
        let task = session!.dataTask(with: request)

        // task.priority = .
        task.resume()
        
        // todo: replace with QOS or priority?
        while task.state != .completed {
            if task.error != nil {
                throw OnTheMapCustomErrors.ParseAPI2Errors.UnableToPostToParse
            }
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
    
    
    // Parse return data from JSON
    // Takes JSON data
    // Returns [NSDictionary]
    private func ConvertJSONToStudentInfoDictionary(data: Data) throws -> [NSDictionary] {
        
        var parsedData: NSDictionary?
        
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        } catch {
            print("WARNING: Unable to parse data \(data)")
            throw OnTheMapCustomErrors.ParseAPI2Errors.UnableToParseData
        }
        
        guard let results = parsedData!["results"] as? [NSDictionary] else {
            throw OnTheMapCustomErrors.ParseAPI2Errors.UnableToParseResultsFromData
        }
        
        return results
    }
}
