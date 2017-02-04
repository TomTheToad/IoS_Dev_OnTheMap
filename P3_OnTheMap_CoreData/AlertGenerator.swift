//
//  AlertGenerator.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 2/4/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit

class OKAlertGenerator {
    
    // fields
    var title = "Error"
    var message: String
    var buttonOneText = "ok"
    var handler: ((UIAlertAction) -> Void)? = nil
    
    
    init(alertMessage: String) {
        message = alertMessage
    }
    
    func getAlertToPresent() -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        
        alert.addAction(alertAction)
        
        return alert
    }
    
}
