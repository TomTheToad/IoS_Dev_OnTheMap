//
//  UdacityLoginController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: clean up code

/*

 File to handle the interaction with the Udacity API for this application.
 
 Update this file to use NSOperation.
 
*/

import UIKit
import CoreData

class UdacityAPI: UIViewController {
    
    
    // Fields
    fileprivate let udacityLoginURL = URL(string: "https://www.udacity.com/account/auth#!/signup")
    fileprivate let responseCheck = URLResponseCheck()
    fileprivate let LoginIsSuccess = false
    
    
    // Getters
    func getUdacitySignUpURL() -> URL {
        return udacityLoginURL!
    }
    
    
    /* Main Public Function Calls */
    // Do Login
    func doUdacityLogin (_ userLogin: String, userPassword: String, completionHandler: @escaping ((Bool, Bool)->Void)) {
        getSessionID(userLogin, userPassword: userPassword, completionHandler: completionHandler)
    }
    
    // Do logout
    func doUdacityLogout() {
        logOut()
    }


    /* Private functions */
    // Retrieve session ID for given login information
    // Takes argument userLogin as String
    // Takes argument userPassword as String
    // Takes completion handler
    // Completion Handler isSuccessful: Bool, isNetworkError: Bool
    fileprivate func getSessionID(_ userLogin: String, userPassword: String, completionHandler: @escaping ((Bool, Bool)->Void)) {
        
        // create NSUrl
        let UdacitySessionAPIURL = URL(string: "https://www.udacity.com/api/session")
        
        // Create request
        var request = URLRequest(url: UdacitySessionAPIURL!)
        
        // add request values
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(userLogin)\", \"password\": \"\(userPassword)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                completionHandler(false, true)
                return
            } else {
                
                let statusCheck = self.responseCheck.checkReponse(response!)
                
                if statusCheck.0 == true {
                    
                    
                    // Update to deal with new Swift3 Range type
                    let dataRange = 5...Int(data!.count)
                    
                    let dataTruncated = data?.subdata(in: Range(dataRange))
                    
                    var parsedResult: NSDictionary?
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: dataTruncated!, options: .allowFragments ) as? NSDictionary
                        
                    } catch {
                        print("WARNING: Unable to parse data \(parsedResult as AnyObject)")
                    }
                     
                    let newData = parsedResult
                    
                    guard let accountInfo = newData!["account"] as? NSDictionary else {
                        return
                    }

                    guard let accountKey = accountInfo["key"] as? String else {
                        print("WARNING: Unable to retrieve account key")
                        return
                    }
                    
                    self.getUserPublicInfo(userLogin, accountID: accountKey, completionHandler: completionHandler)
                
                } else {
                    completionHandler(false, false)
                }
            }
            
            })
        task.resume()
    }
    
    
    // Retrieve public user information from Udacity api with give account id
    // Takes userLogin as String
    // Takes account ID as String
    // Takes Completion Handler
    // Completion Handler isSuccessful: Bool, isNetworkError: Bool
    fileprivate func getUserPublicInfo(_ userLogin: String, accountID: String, completionHandler: @escaping ((Bool, Bool)->Void)) {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(accountID)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil { // Handle error...
                completionHandler(false, true)
                return
            }
            
            let statusCheck = self.responseCheck.checkReponse(response!)
            
            if statusCheck.0 == true {
                
                // Update to deal with new Swift3 Range type
                let dataRange = 5...Int(data!.count)
                
                let newData = data!.subdata(in: Range(dataRange))
                var parsedResult: NSDictionary?
                var isSuccess = false
                
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? NSDictionary
                    isSuccess = true
                } catch {
                    // print("unable to parse results")
                    isSuccess = false
                }
                
                if let data = parsedResult {
                    
                    let userData = data["user"]! as? NSDictionary
                    
                    // let studentInfo = StudentInfoMethods()
                    var userInfo = StudentInfo()
                    
                    guard let userFirstName = userData?["first_name"]! as? String else {
                        return
                    }
                    
                    guard let userLastName = userData?["last_name"]! as? String else {
                        return
                    }
                    
                    guard let userKey = userData?["key"]! as? String else {
                        return
                    }
                    
                    userInfo.firstName = userFirstName
                    userInfo.lastName = userLastName
                    userInfo.studentID = userKey
                    
                    let coreDataHandler = CoreDataHandler()
                    
                    coreDataHandler.saveUserInfoData(userLogin, studentInfo: userInfo)
                    
                } else {
                    print("WARNING: Unable to save user data")
                }
            
                completionHandler(isSuccess, false)
                
            } else {
                completionHandler(false, false)
            }
            
        }) 
        task.resume()
    }
    
    
    // Deletes shared cookie to allow for "logout"
    fileprivate func logOut() {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                // Will need to figure out what to do with this error?
                // Ultimately the user is brought back to login
                // regardless.
                return
            }
        } 
        task.resume()
    }
}
