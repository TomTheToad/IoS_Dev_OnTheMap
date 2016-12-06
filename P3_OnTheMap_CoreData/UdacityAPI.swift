//
//  UdacityLoginController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/2/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: clean up code

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
    func doUdacityLogin (_ userLogin: String, userPassword: String, completionHandler: @escaping ((Bool)->Void)) {
        getSessionID(userLogin, userPassword: userPassword, completionHandler: completionHandler)
    }
    
    // Do logout
    func doUdacityLogout() {
        logOut()
    }


    // Private functions
    fileprivate func getSessionID(_ userLogin: String, userPassword: String, completionHandler: @escaping ((Bool)->Void)) {
        
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
                print(error)
                return
            } else {
                
                let statusCheck = self.responseCheck.checkReponse(response!)
                print("isSuccess = \(statusCheck.0), message = \(statusCheck.1)")
                
                if statusCheck.0 == true {
                
                    // let newData = data?.subdata(in: NSMakeRange(5, data!.count))
                    
                    // Update to deal with new Swift3 Range type
                    let dataRange = 5...Int(data!.count)
                    
                    let dataTruncated = data?.subdata(in: Range(dataRange))
                    
                    var parsedResult: NSDictionary?
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: dataTruncated!, options: .allowFragments ) as? NSDictionary
                        
                    } catch {
                        print("Unable to parse data \(parsedResult as AnyObject)")
                    }
                    
                    let newData = parsedResult
                    
                    print("PARSED RESULT: \(parsedResult)")
                    
                    guard let accountInfo = newData!["account"] as? NSDictionary else {
                        print("Cannot find session key: \(newData)")
                        return
                    }

                    guard let accountKey = accountInfo["key"] as? String else {
                        print("Unable to retrieve account key")
                        return
                    }
                    
                    self.getUserPublicInfo(userLogin, accountID: accountKey, completionHandler: completionHandler)
                
                } else {
                    completionHandler(false)
                }
            }
            
            })
        task.resume()
    }
    
    
    fileprivate func getUserPublicInfo(_ userLogin: String, accountID: String, completionHandler: @escaping ((Bool)->Void)) {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(accountID)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if error != nil { // Handle error...
                return
            }
            
            let statusCheck = self.responseCheck.checkReponse(response!)
            print("isSuccess = \(statusCheck.0), message = \(statusCheck.1)")
            
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
                    print("unable to parse results")
                    isSuccess = false
                }
                
                if let data = parsedResult {
                    
                    // print("User Data: \(data)")
                    let userData = data["user"]! as? NSDictionary
                    
                    // let studentInfo = StudentInfoMethods()
                    var userInfo = StudentInfo()
                    
                    guard let userFirstName = userData?["first_name"]! as? String else {
                        print("Could not located user first name.")
                        return
                    }
                    
                    guard let userLastName = userData?["last_name"]! as? String else {
                        print("Could not located user first name.")
                        return
                    }
                    
                    guard let userKey = userData?["key"]! as? String else {
                        print("Could not located user first name.")
                        return
                    }
                    
                    userInfo.firstName = userFirstName
                    // print("userInfo.firstName: \(userInfo.firstName)")
                    userInfo.lastName = userLastName
                    // print("userInfo.lastName: \(userInfo.lastName)")
                    userInfo.studentID = userKey
                    // print("userInfo.key: \(userInfo.studentID)")
                    
                    // Save to core data
                    // todo: Change to save to plist or remove entirely
                    let coreDataHandler = CoreDataHandler()
                    
                    coreDataHandler.saveUserInfoData(userLogin, studentInfo: userInfo)
                    // dataHandler.saveUserInfoData(userInfo)
                    
                    // run second time to confirm save
                    // dataHandler.saveUserInfoData2(userInfo)
                    
                } else {
                    print("Warning: Unable to save user data")
                }
            
                completionHandler(isSuccess)
                
            } else {
                completionHandler(false)
            }
            
        }) 
        task.resume()
    }
    
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
            if error != nil { // Handle error…
                return
            }
            
            // Update to deal with new Swift3 Range type
            let dataRange = 5...Int(data!.count)
            
            let newData = data!.subdata(in: Range(dataRange)) /* subset response data! */
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue))
        }
        
        task.resume()
    }
}