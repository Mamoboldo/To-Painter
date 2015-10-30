//
//  AddCustomerController.swift
//  To Painter
//
//  Created by Marco Boldetti on 21/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

protocol AddCustomerDelegate{
    func customerAdded()
}

class AddCustomerController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var addPictureSwitch: UISwitch!
    @IBOutlet weak var customerImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surNameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var webSiteField: UITextField!
    
    var customerIsEdit = false
    var delegate: AddCustomerDelegate!
    var customerToEdit: PFObject!
    
    var altezza : CGFloat = 180 // Altezza cella per la foto
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fontReg = UIFont(name: "AvenirNext-Regular", size: 17)
        let fontBold = UIFont(name: "AvenirNext-Medium", size: 17)
        
        // Levo quel fastidioso bordo tra la fine del navication e la prima cella
        tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
        
        // Setto il font dei BarButtonItem
        cancelButtonItem.setTitleTextAttributes([NSFontAttributeName: fontReg!], forState: .Normal)
        doneButtonItem.setTitleTextAttributes([NSFontAttributeName: fontBold!], forState: .Normal)
        
        tableView.separatorStyle = .None
        customerImage.layer.cornerRadius = 80
        
        if customerIsEdit {
            let name = customerToEdit["name"] as! String
            let surName = customerToEdit["surName"] as! String
            self.title = "\(name) \(surName)"
            doneButtonItem.title = "Edit"
            
            
            // Riempio le textField con i dati presi da parse
            nameField.text = name
            surNameField.text = surName
            addressField.text = customerToEdit["address"] as? String
            phoneField.text = customerToEdit["phoneNumber"] as? String
            emailField.text = customerToEdit["emailAddress"] as? String
            webSiteField.text = customerToEdit["webSite"] as? String
            
            // Verifico se nel cliente c'è la foto
            let customerPicture = customerToEdit["customerImage"] as? String
            
            if customerPicture == nil {
                addPictureSwitch.on = false
                hidePhotoCell()
            }
        }
        
        // UITextFieldDelegate Methods
        nameField.delegate = self
        surNameField.delegate = self
        addressField.delegate = self
        phoneField.delegate = self
        emailField.delegate = self
        webSiteField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextField Delegate Methods
    // questo metodo viene invocato quando viene premuto Invio sulla tastiera
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == nameField) {
            surNameField.becomeFirstResponder()
        } else if (textField == surNameField) {
            addressField.becomeFirstResponder()
        } else if (textField == addressField) {
            phoneField.becomeFirstResponder()
            addAccessoryView(true, field: phoneField)
        } else if (textField == phoneField) {
            emailField.becomeFirstResponder()
        } else if (textField == emailField) {
            webSiteField.becomeFirstResponder()
        } else if (textField == webSiteField) {
            webSiteField.resignFirstResponder()
        }
        
        return true
    }
    
    // Questo scatta quando l'utente inizia la modifica
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == phoneField) {
            addAccessoryView(true, field: phoneField)
        }
    }
    
    // MARK: - Metodi
    
    // questo metodo serve per mettere un UIToolBar con dentro un pulsante come "cappello" della tastiera
    // notare come il metodo ha 2 variabili che gli possiamo passare:
    // metti serve per dirgli se vogliamo mettere il cappello oppure no
    // field serve per dirgli a quale textField mettere il cappello sulla tastiera
    func addAccessoryView(metti : Bool, field : UITextField) {
        
        // controlliamo il Bool
        if metti {
            // se è true costruiamo la toolbar + il button + il flex (come in PizzaList) e lo mettiamo nell'accessoryView del TextField
            let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
            let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            let save = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "goToFowardField:")
            keyboardToolbar.setItems([flex, save], animated: false)
            field.inputAccessoryView = keyboardToolbar
        } else {
            // se è false eliminiamo l'accessoryView (quindi togliamo la toolbar dalla tastiera)
            field.inputAccessoryView = nil
        }
    }
    
    func goToBackField(textFielf: UITextField) {
        print("Go Back")
        
    }
    
    func goToFowardField(textField: UITextField) {
        emailField.becomeFirstResponder()
        
    }
    
    // MARK: - Actions
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        var newCustomer = PFObject(className: Tables().TABLE_CUSTOMERS)
        if customerIsEdit {
            newCustomer = customerToEdit!
        }
        newCustomer["username"]     = PFUser.currentUser()!.username
        newCustomer["name"]         = nameField.text
        newCustomer["surName"]      = surNameField.text
        newCustomer["address"]      = addressField.text
        newCustomer["phoneNumber"]  = phoneField.text
        newCustomer["emailAddress"] = emailField.text
        newCustomer["webSite"]      = webSiteField.text
        newCustomer.pinInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                newCustomer.saveEventually()
                self.delegate.customerAdded()
            }
        }
        
        if (customerIsEdit) {
            hudView.text = "Updated"
            afterDelay(0.6, closure: { () -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            hudView.text = "Saved"
            afterDelay(0.6, closure: { () -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }

    }
    
    @IBAction func showAddPictureCell(sender: UISwitch) {
        if addPictureSwitch.on {
            showPhotoCell()
        } else {
            hidePhotoCell()
        }
    }
    
    func showPhotoCell() {
        if altezza == 0 {
            altezza = 180
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func hidePhotoCell() {
        if altezza == 180 {
            altezza = 0
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Uso un metodo switch per riconoscere la cella che mostrerà la foto
        // e ne definisco le varie altezze
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 60
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return altezza
        } else {
            return 60
        }
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
