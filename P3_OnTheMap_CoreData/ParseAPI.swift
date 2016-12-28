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

*/

import UIKit

class ParseAPI {
    
    // Fields
    fileprivate var parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    fileprivate var RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    // public methods
    
    // Retieve student location
    // Takes completion handler
    func getStudentLocations(_ completionHandler: @escaping ([NSDictionary]) -> Void) {
        getParseData(completionHandler)
    }
    
    // Send data to core data handler
    // todo: rename method
    func updateSavedStudentInfo(_ completionHanlder: @escaping (Bool) -> Void) {
        setParseData(completionHanlder)
    }

    // private methods
    // Call to ParseAPI for udacity student locations and associated media.
    fileprivate func getParseData(_ completionHandler: @escaping ([NSDictionary]) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
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
                print("Unable to parse data \(data!)")
            }
            
            guard let results = parsedData!["results"] as? [NSDictionary] else {
                print("unable to parse results from: \(parsedData!)")
                return
            }
            
            completionHandler(results)
        })
        task.resume()
    }
    
    
    // Check for existing student user submission
    // todo: Check parse or check core data? (check core data first then check parse?)
    fileprivate func getStudentLocation(studentID: String) {
        
        // adapt
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
    
    
    
    // Get and Save student location from Udacity Parse Clone to Core Data
    fileprivate func setParseData(_ completionHandler: @escaping ((Bool)->Void)) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
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
                print("Unable to parse data \(data!)")
            }
            
            guard let results = parsedData!["results"] as? [NSDictionary] else {
                print("unable to parse results from \(parsedData)")
                return
            }
            
            let studentInfo = StudentInfoMethods()
            let studentInfoDict = studentInfo.buildStudentDictionary(results)
            
            let coreDataHandler = CoreDataHandler()
            coreDataHandler.saveStudentLocations(studentInfoDict)
            
            completionHandler(true)
            
        })
        task.resume()
    }
    
    
    // replace previous postStudentLocationMethod
    // todo: clean up
    // should this be two methods? post and put?
    func sendStudentLocation(_ studentInfo: StudentInfo, mapString: String, updateExistingEntry: Bool, parseID: String? = "", errorHandler: @escaping (_ isSuccess: Bool)->Void ) {
        
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
            print("ERROR: Student ID missing")
            return
        }
        // firstName
        guard let firstName = studentInfo.firstName else {
            print("ERROR: Student ID missing")
            return
        }
        // lastName
        guard let lastName = studentInfo.lastName else {
            print("ERROR: Student ID missing")
            return
        }
        // mediaURL
        guard let mediaURL = studentInfo.mediaURL else {
            print("ERROR: Student ID missing")
            return
        }
        // latitude
        guard let latitude = studentInfo.latitude else {
            print("ERROR: Student ID missing")
            return
        }
        // longitude
        guard let longitude = studentInfo.longitude else {
            print("ERROR: Student ID missing")
            return
        }
        
        
        print("Parse API received: uniqueKey:\(uniqueKey), firstName:\(firstName), lastName:\(lastName), mediaURL:\(mediaURL), latitude:\(latitude), longitude:\(longitude)")
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = httpMethod
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        print("REQUEST URL: \(request.url)")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil { // Handle error…
                print("ERROR: could not post to parse")
                errorHandler(false)
                return
            } else {
                print("MESSAGE: parse request successful")
                errorHandler(true)
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        })
        task.resume()
        
    }

}

