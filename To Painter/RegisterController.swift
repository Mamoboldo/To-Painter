//
//  RegisterController.swift
//  To Painter
//
//  Created by Marco Boldetti on 16/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class RegisterController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Riduco l'immagine se si tratta di un iPhone 4S
        if (UIScreen.mainScreen().bounds.height == 480) {
            logoImageView.frame = CGRectMake((self.view.bounds.midX - 55), 30, 110, 110)
        } else {
            print("Non è un iPhone 4s")
        }
        
        // Imposto i delagati per le TextField
        userNameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        
        // Faccio apparire la tastiera e do il focus alla usernameField
        userNameField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextField Delegate Methods
    
    // questo metodo viene invocato quando viene premuto Invio sulla tastiera
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == userNameField) {
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField) {
            passwordField.becomeFirstResponder()
        } else if (textField == emailField) {
            register(self)
            emailField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Actions
    @IBAction func register(sender: AnyObject) {
        let userName =  userNameField.text
        let password =  passwordField.text
        let email    =  emailField.text
        
        // Controllo le textfield
        if userName?.characters.count < 5 {
            // Mostro l'alert per l'errore
            SCLAlertView().showError("Invalid", subTitle: "Username must be greater than 5 characters", closeButtonTitle:"OK")
            
        } else if password?.characters.count < 8 {
            SCLAlertView().showError("Invalid", subTitle: "Password must be greater than 8 characters", closeButtonTitle:"OK")
            
        } else if email?.characters.count < 8 {
            SCLAlertView().showError("Invalid", subTitle: "Please enter a valid email address", closeButtonTitle:"OK")
        } else {
            // Register a new User
            let newUser = PFUser()
            
            newUser.username = userName
            newUser.password = password
            newUser.email    = email
            
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                if ((error) != nil) {
                    // Errore di registrazione
                    SCLAlertView().showError("Error", subTitle: "\(error)", closeButtonTitle:"OK")
                } else {
                    let alert = SCLAlertView()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    alert.showSuccess("'To Painters'", subTitle: "Hello \(PFUser.currentUser()!.username!), you are signed up!")
                }
            })
        }
    }
    
    @IBAction func cancel (sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
