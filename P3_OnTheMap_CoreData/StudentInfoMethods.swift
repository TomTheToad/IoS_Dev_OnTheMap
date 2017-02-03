//
//  StudentInfoMethods.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/3/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

/* 

Methods to support working with StudentInfo struct data.

*/

import Foundation

class StudentInfoMethods {
    
    // Convert NSDict for user to StudentInfo
    func convertDictToStudentUserInfo(_ dict: NSDictionary) -> StudentInfo {
            var thisStudent = StudentInfo()
            
            // firstName
            if let first = dict["firstName"] {
                thisStudent.firstName = String(describing: first)
            }
            
            // lastName
            if let last = dict["lastName"] {
                thisStudent.lastName = String(describing: last)
            }
            
            // mediaURL
            if let url = dict["mediaURL"] {
                thisStudent.mediaURL = String(describing: url)
            }
            
            // latitude
            if let lat = dict["latitude"] {
                thisStudent.latitude = String(describing: lat)
            }
            
            // longitude
            if let long = dict["longitude"] {
                thisStudent.longitude = String(describing: long)
            }
            
            // studentID
            if let studentID = dict["uniqueKey"] {
                thisStudent.studentID = String(describing: studentID)
            }
        
            // objectID
            if let parseID = dict["objectId"] {
                thisStudent.parseID = String(describing: parseID)
            }

        return thisStudent

    }
        
    
    // Convert an array of NSDictionaries to an array of StudentInfo
    func buildStudentDictionary(_ dict: [NSDictionary]) -> [StudentInfo] {
        
        var studentArray = [StudentInfo]()
        
        // Convert and add students
        for student in dict {
            let thisStudent = convertDictToStudentUserInfo(student)
            
            studentArray.append(thisStudent)
        }

        return studentArray
    }
        
}
