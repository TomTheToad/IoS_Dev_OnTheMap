//
//  AlertHandler.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 12/26/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// Handles repetitive UIAlertController build for OnTheMap application

import UIKit

class AlertHandler {
    
    // Fields
    private let alert = UIAlertController()
    
    
    // Request an alert with message to acknowlege
    // Argument: takes a message to display as String
    // Returns: a UIAlertController ready for presentation
    func alertOK(message: String) -> UIAlertController {

        alert.title = "Error"
        alert.message = message
        
        let action = UIAlertAction(title: "continue", style: .default, handler: nil)

        alert.addAction(action)
        
        return alert
    }
    
    
    // Request an alert with two options, continue (destructive) and cancel.
    // Argument: takes a message to display as String
    // Returns: a UIAlertController ready for presentation
    func alertContinueDestructive(message: String) -> UIAlertController {
        alert.title = "Overwrite?"
        alert.message = message
        
        let action = UIAlertAction(title: "Continue", style: .default, handler: nil)
        let action2 = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(action)
        alert.addAction(action2)
        
        return alert
    }
    
}
