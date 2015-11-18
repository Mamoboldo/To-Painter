//
//  LoginController.swift
//  To Painter
//
//  Created by Marco Boldetti on 16/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class LoginController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

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
            login(self)
            passwordField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Actions
    @IBAction func login(sender: AnyObject) {
        let userName = userNameField.text
        let password = passwordField.text
        
        // Controllo le textfield
        if userName?.characters.count < 5 {
            // Mostro l'alert per l'errore
            SCLAlertView().showError("Invalid", subTitle: "Username must be greater than 5 characters", closeButtonTitle:"OK")
            
        } else if password?.characters.count < 8 {
            SCLAlertView().showError("Invalid", subTitle: "Password must be greater than 8 characters", closeButtonTitle:"OK")
            
        } else {
            // Invio la richiesta di login
            PFUser.logInWithUsernameInBackground(userName!, password: password!, block: { (user, error) -> Void in
                
                // Mostro l'alert di benvenuto
                if ((user != nil)) {
                    let alert = SCLAlertView()
                    let customerController = CustomersTableController()
                    alert.showCloseButton = false
                    alert.addButton("Done", action: { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    customerController.updateTable()
                    customerController.refreshBegin()
                    alert.showInfo ("'To Painters'",
                        subTitle: "Hello \(PFUser.currentUser()!.username!), you are logged in!",
                        closeButtonTitle: nil,
                        duration: 0.0,
                        colorStyle: 0x09A9EB,
                        colorTextButton: 0xffffff)
                } else {
                    // Errore di login
                    SCLAlertView().showError("Error", subTitle: "\(error)", closeButtonTitle:"OK")
                }
            })
        }
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        let resetController : UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("resetPassword") as! UITableViewController
        self.presentViewController(resetController, animated: true, completion: nil)
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
