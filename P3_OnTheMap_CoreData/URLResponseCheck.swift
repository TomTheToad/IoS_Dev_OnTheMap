//
//  URLResponseCheck.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 5/23/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/*
 
 Handles response checking
 
*/

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class URLResponseCheck {
    
    // Fields
    var isSuccess = false
    var message = ""
    
    // Checks response for status code and message
    // Takes URLReponse
    // Takes Completion Handler
    func checkReponse(_ response: URLResponse) -> (Bool, String) {
        
        let httpResponse = response as? HTTPURLResponse
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
