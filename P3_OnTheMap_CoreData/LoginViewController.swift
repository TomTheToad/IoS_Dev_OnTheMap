//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 3/31/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//


/*
 
 Initial view controller. Handles the user login process.
 Directly dependent upon UdacityAPI.swift
 
 Possible upgrade: Prompt user if no network connection found to use saved data.
 
 */

import UIKit
import SafariServices

class LoginViewController: UIViewController, SFSafariViewControllerDelegate, UITextFieldDelegate {
    
    // Fields
    fileprivate let udacityAPI = UdacityAPI()
    
    // IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginMessages: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Clear text fields. Added for popping back to initial view from logout
        emailTextField.text?.removeAll()
        // emailTextField.becomeFirstResponder()
        passwordTextField.text?.removeAll()
        loginMessages.text?.removeAll()
        
        // Activity animator
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    
        // Add delegate for return functionality
        passwordTextField.delegate = self
    }
    
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    
    // IBActions
    // Login button action
    @IBAction func loginButtonAction(_ sender: AnyObject) {
        guard let login = emailTextField.text else {
            sendMessage("Please Enter A Valid Email", isError: true)
            return
        }
        
        guard let password = passwordTextField.text else {
            sendMessage("Please enter a valid password", isError: true)
            return
        }
        
        sendMessage("Sending Login", isError: false)
        activityIndicator.startAnimating()
        
        // if success, perform Udacity login
        udacityAPI.doUdacityLogin(login, userPassword: password, completionHandler: udacityLoginCompletionHandler)
    }
    

    // Sign Up Button open safari within the app
    @IBAction func signUpOnUdacityWebsite(_ sender: AnyObject) {
        
        let url = udacityAPI.getUdacitySignUpURL()
        
        let safariVC = SFSafariViewController(url: url as URL)
        present(safariVC, animated: true, completion: nil)
    }
    
    
    // Required controller for safari delegate to dismiss safari controller
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // Udacity completion handler
    // Displays Login status (complete or failed) 
    // Dependent upon Udacity authorization result
    // Takes a loginCompletionHandler
    fileprivate func udacityLoginCompletionHandler(isSuccess: Bool, isNetworkError: Bool)->Void {
        // Condition success: login seems to be processed correctly and data is returned
        if isSuccess == true {
            // let parse = ParseAPI2()
            // parse.updateSavedStudentInfo(loginCompletionHandler)
            let studentLocationDataManager = StudentLocationDataManager()
            do {
                try studentLocationDataManager.updateLocalStudentLocations()
            } catch {
                self.sendMessage("Unable to contact server", isError: true)
            }
            DispatchQueue.main.async(execute: { ()-> Void in
                self.sendMessage("Loading Data", isError: false)
                self.completeLogin()
            })
        // Condition failure: either login incorrect of network error
        } else {
            DispatchQueue.main.async(execute: { ()-> Void in
                // Network error most likely
                if isNetworkError == true {
                    self.sendMessage("Unable to contact server", isError: true)
                    self.sendAlert("Network error. Internet connection required")
                // User error most likely
                } else {
                    self.sendMessage("Login Failed", isError: true)
                    self.sendAlert("Login Failed. Username/Password incorrect.")
                }
            })
        }
    }
    
    
    // Parse Completion Handler
    // Allows for loading of map data prior to transitioning to the mapView.
    // Completes login and triggers segue to map else
    // Send failure message to UI
    func loginCompletionHandler(isSuccess:Bool) -> Void {
        DispatchQueue.main.async(execute: { ()-> Void in
            if isSuccess == true {
                self.completeLogin()
            } else {
                self.sendMessage("Failed to load map data", isError: true)
                self.sendAlert("Network Error. Unable to contact server.")
            }
        })
    }
    
    
    // User messages
    // Delivers message to user on login page.
    // Changes message color between red and green.
    fileprivate func sendMessage(_ message: String, isError: Bool) {
        
        // todo: update to handle network vs login error
        if isError == true {
            loginMessages.textColor = UIColor.red

        } else {
            loginMessages.textColor = UIColor.green
        }
        
        loginMessages.text = message
        loginMessages.isEnabled = true
    }
    
    
    // User alerts
    // Call alert Handler formatted for ok, nondestructive message
    fileprivate func sendAlert(_ message: String) {
        
        activityIndicator.stopAnimating()
        let alert = OKAlertGenerator(alertMessage: message)
        present(alert.getAlertToPresent(), animated: false, completion: nil)
    }
    
    
    // Complete login by performing segue
    fileprivate func completeLogin() {
        performSegue(withIdentifier: "completeLogin", sender: self)
    }
    
    
    // MARK: - Location Text Field Delegate Methods
    // Enables enter key to launch loginButtonAction if within password field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        loginButtonAction(textField)
        return true
    }
    
    // MARK: Keyboard notification for view shift.
    // todo: find answer to user tab resulting in view not returning to start position.
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

