//
//  URLResponseCheck.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/23/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

import Foundation

class URLResponseCheck {
    
    // Fields
    var isSuccess = false
    var message = ""
    
    func checkReponse(response: NSURLResponse) -> (Bool, String) {
        
        let httpResponse = response as? NSHTTPURLResponse
        let statusCode = httpResponse?.statusCode
        
        if statusCode <= 299 {
            isSuccess = true
        } else {
            isSuccess = false
        }
        
        message = "Status code: \(String(statusCode!))"
        return (isSuccess, message)
    }
}
