//
//  ErrorHandler.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 12/31/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/* Error handling class for api completion handlers */

import Foundation

class ErrorHandler {
    
    // Fields
    var isSuccess: Bool?
    var message: String?
    
    // is necessary?
    init() {
        // set arguments
    }
    
    func errorHandler(isSuccess: Bool, message: String) {
        
    }
    
    
    
//    func loginCompletionHandler(isSuccess:Bool) -> Void {
//        DispatchQueue.main.async(execute: { ()-> Void in
//            if isSuccess == true {
//                self.completeLogin()
//            } else {
//                self.sendMessage("Failed to load map data", isError: true)
//                self.sendAlert("Network Error. Unable to contact server.")
//            }
//        })
}
