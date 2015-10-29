//
//  ResetPasswordController.swift
//  To Painter
//
//  Created by Marco Boldetti on 18/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
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
        emailField.delegate = self
        
        // Faccio apparire la tastiera e do il focus alla usernameField
        emailField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextField Delegate Methods
    // questo metodo viene invocato quando viene premuto Invio sulla tastiera
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == emailField) {
            emailField.resignFirstResponder()
        }
        
        return true
    }

    // MARK: - Actions
    @IBAction func resetPassword(sender: AnyObject) {
        let email = self.emailField.text
        
        // Creo una stringa da quella dell'email senza eventuali spazi
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Invio a Parse la richiesta di reset della password
        PFUser.requestPasswordResetForEmailInBackground(finalEmail)
        
        // Chiudo la tastiera
        emailField.resignFirstResponder()
        
        // Mostro l'alert
        let alert = SCLAlertView()
        alert.showCloseButton = false
        alert.addButton("Done", target: self, selector: "cancel:")
        alert.showNotice("Password Reset", subTitle: "An email containing information on how to reset your password has been sent to " + finalEmail + ".")
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
