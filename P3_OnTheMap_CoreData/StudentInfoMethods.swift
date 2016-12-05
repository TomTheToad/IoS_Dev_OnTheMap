//
//  StudentInfoMethods.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 4/3/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//

import Foundation

class StudentInfoMethods {
    
    // Convert NSDict for user to StudentInfo
    func convertDictToStudentUserInfo(_ dict: NSDictionary) -> StudentInfo {
            var thisStudent = StudentInfo()
            
            // firstName
            if let first = dict["firstName"] {
                thisStudent.firstName = String(describing: first)
                print("First Name: \(first)")
            }
            
            // lastName
            if let last = dict["lastName"] {
                thisStudent.lastName = String(describing: last)
                print("Last Name: \(last)")
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
                print("Unique Key: \(studentID)")
            }

        return thisStudent

    }
        
    
    // Reconfigure
    func buildStudentDictionary(_ dict: [NSDictionary]) -> [StudentInfo] {
        
        var studentArray = [StudentInfo]()
        
        // Convert and add students
        for student in dict {
            let thisStudent = convertDictToStudentUserInfo(student)
            
            studentArray.append(thisStudent)
        }
        
        // Convert and add the student user of this app from udacity login info
//        let thisStudentUser = convertDictToStudentUserInfo(studentUser)
//        studentArray.append(thisStudentUser)

        return studentArray
    }
        
}
