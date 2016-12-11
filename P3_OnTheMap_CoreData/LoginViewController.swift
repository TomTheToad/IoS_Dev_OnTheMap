//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 3/31/16.
//  Copyright © 2016 TomTheToad. All rights reserved.
//
// todo: list
// 1) handle errors gracefully
// 2) Check for saved data if no data connection?

import UIKit
import SafariServices

class LoginViewController: UIViewController, SFSafariViewControllerDelegate, UITextFieldDelegate {
    
    // Fields
    fileprivate let udacityAPI = UdacityAPI()
    
    // IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginMessages: UILabel!
    

    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
        loginMessages.text?.removeAll()
    
        passwordTextField.delegate = self
    }
    
    
    // IBActions
    @IBAction func loginButtonAction(_ sender: AnyObject) {
        guard let login = emailTextField.text else {
            // todo: add alert
            sendMessage("Please Enter A Valid Email", isError: true)
            return
        }
        
        guard let password = passwordTextField.text else {
            sendMessage("Please enter a valid password", isError: true)
            return
        }
        
        sendMessage("Sending Login", isError: false)
        
        udacityAPI.doUdacityLogin(login, userPassword: password, completionHandler: udacityLoginCompletionHandler)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        loginButtonAction(textField)
        return true
    }
    

    // Sign Up Button open safari within the app
    @IBAction func signUpOnUdacityWebsite(_ sender: AnyObject) {
        
        let url = udacityAPI.getUdacitySignUpURL()
        
        let safariVC = SFSafariViewController(url: url as URL)
        present(safariVC, animated: true, completion: nil)
    }
    
    
    // required controller for safari delegate to dismiss safari controller
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // Udacity completion handler
    // Displays Login status (complete or failed) 
    // dependent upon Udacity authorization result
    fileprivate func udacityLoginCompletionHandler(_ isSuccess: Bool)->Void {
        if isSuccess == true {
            let parse = ParseAPI()
            parse.updateSavedStudentInfo(loginCompletionHandler)
            DispatchQueue.main.async(execute: { ()-> Void in
                self.sendMessage("Loading Data", isError: false)
            })
        } else {
            DispatchQueue.main.async(execute: { ()-> Void in
            self.sendMessage("Login Failed", isError: true)
            print("unable to complete login process")
            })
        }
    }
    
    // Completion Handler
    // Completes login and triggers segue to map else
    // Send failure message to UI
    func loginCompletionHandler(_ isSuccess:Bool) -> Void {
        DispatchQueue.main.async(execute: { ()-> Void in
            if isSuccess == true {
                self.completeLogin()
            } else {
                self.sendMessage("Failed to load map data", isError: true)
            }
        })
    }
    
    
    // User messages
    // Delivers message to user on login page.
    // Changes message color between red and green.
    fileprivate func sendMessage(_ message: String, isError: Bool) {
        
        if isError == true {
            loginMessages.textColor = UIColor.red
            sendAlert("Invalid Username / Password")
        } else {
            loginMessages.textColor = UIColor.green
        }
        
        loginMessages.text = message
        loginMessages.isEnabled = true
    }
    
    
    // User alerts
    fileprivate func sendAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: false, completion: nil)
    }
    
    
    // Complete login by performing segue
    fileprivate func completeLogin() {
        performSegue(withIdentifier: "completeLogin", sender: self)
    }
}

