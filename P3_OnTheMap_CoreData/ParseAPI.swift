//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: list
// 1) finish checkForExistingEntry function
// 2) clean up code... handle errors?

/* 

 File to handle interaction with Udacity Parse API
 
 Update to use NSOperation
 Update to better error handling. A number of these errors are
    basically fatal or undermine the app entirely. Most of these
    errors are detected in the corresponding VC, however there should
    be alternatives to network connectivity issues given that this app
    is currently using core data. This would work well with NSOPeration.

*/

import UIKit

class ParseAPI {
    
    
    // Fields
    fileprivate var parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    fileprivate var RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    
    /* public methods */
    // Retieve student location
    // Takes completion handler
    func getStudentLocations(_ completionHandler: @escaping ([NSDictionary]) -> Void) {
        getParseData(completionHandler)
    }
    
    
    // Send data to core data handler
    func updateSavedStudentInfo(_ completionHanlder: @escaping (Bool) -> Void) {
        setParseData(completionHanlder)
    }
    
    // Post a student location to Udacity parse api
    func postStudentLocation(studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool, parseID: String? = "", errorHandler: @escaping (Bool)->Void) {
        
        // pass through to private function
        sendStudentLocation(studentInfo, mapString: mapString, updateExistingEntry: updateExistingEntry, parseID: parseID, errorHandler: errorHandler)
    }

    
    // private methods
    // Call to ParseAPI for udacity student locations and associated media.
    fileprivate func getParseData(_ completionHandler: @escaping ([NSDictionary]) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("\(parseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(RESTApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("=-updatedAt", forHTTPHeaderField: "order")
        request.addValue("100", forHTTPHeaderField: "limit")
        
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error != nil {
                fatalError("Critical Application data not found.")
            }
            
            var parsedData: NSDictionary?
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            } catch {
                print("WARNING: Unable to parse data \(data!)")
            }
            
            guard let results = parsedData!["results"] as? [NSDictionary] else {
                print("WARNING: Unable to parse results from: \(parsedData!)")
                return
            }
            
            completionHandler(results)
        })
        task.resume()
    }
    
    
    // Check for existing student user submission
    fileprivate func getStudentLocation(studentID: String) {
        
        // adapt
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
        }
        task.resume()
    }
    
    
    // Get and Save student location from Udacity Parse Clone to Core Data
    fileprivate func setParseData(_ completionHandler: @escaping ((Bool)->Void)) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("=-updatedAt", forHTTPHeaderField: "order")
        request.addValue("100", forHTTPHeaderField: "limit")
        request.addValue("\(parseAppID)", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("\(RESTApiKey)", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error != nil { // Handle error...
                return
            }
            
            var parsedData: NSDictionary?
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            } catch {
                print("WARNING: Unable to parse data \(data!)")
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
            
            let coreDataHandler = CoreDataHandler()
            coreDataHandler.saveStudentLocations(studentInfoDict)
            
            completionHandler(true)
            
        })
        task.resume()
    }
    
    
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

