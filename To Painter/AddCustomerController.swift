//
//  AddCustomerController.swift
//  To Painter
//
//  Created by Marco Boldetti on 21/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse
import MessageUI

protocol AddCustomerDelegate{
    func customerAdded()
}

class AddCustomerController: UITableViewController, UITextFieldDelegate,
                                MFMailComposeViewControllerDelegate, CameraManagerDelegate {
    
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
    
    var custImage: UIImage!
    
    let fontReg = UIFont(name: "AvenirNext-Regular", size: 17)
    let fontMed = UIFont(name: "AvenirNext-Medium", size: 17)
    
    var customerIsEdit = false
    var delegate: AddCustomerDelegate!
    var customerToEdit: PFObject!
    
    var altezza : CGFloat = 180 // Altezza cella per la foto
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CustomerImage: \(customerImage.image!)")
        
        // CameraManagerDelegate
        CameraManager.sharedInstance.delegate = self
        
        // UITextFieldDelegate
        nameField.delegate = self
        surNameField.delegate = self
        addressField.delegate = self
        phoneField.delegate = self
        emailField.delegate = self
        webSiteField.delegate = self
        
        // Levo quel fastidioso bordo tra la fine del navigation e la prima cella
        tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
        
        // Setto il font dei BarButtonItem
        cancelButtonItem.setTitleTextAttributes([NSFontAttributeName: fontReg!], forState: .Normal)
        doneButtonItem.setTitleTextAttributes([NSFontAttributeName: fontMed!], forState: .Normal)
        
        tableView.separatorStyle = .None
        
        if customerIsEdit {
            let name = customerToEdit["name"] as! String
            let surName = customerToEdit["surName"] as! String
            self.title = "\(name) \(surName)"
            doneButtonItem.title = "Edit"
            lock()
            
            if doneButtonItem.title == "Edit" {
                doneButtonItem.action = "unlockAll:"
            }
            
            // Riempio le textField con i dati presi da parse
            nameField.text = name
            surNameField.text = surName
            addressField.text = customerToEdit["address"] as? String
            phoneField.text = customerToEdit["phoneNumber"] as? String
            emailField.text = customerToEdit["emailAddress"] as? String
            webSiteField.text = customerToEdit["webSite"] as? String
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Rendo l'immagine Tonda
        customerImage.layer.cornerRadius = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextField Delegate Methods
    // questo metodo viene invocato quando viene premuto Invio sulla tastiera
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Faccio lo swtch tra i tag della texfield per dare il focus alla successiva
        switch textField.tag {
        case 101:
            surNameField.becomeFirstResponder()
        case 102:
            addressField.becomeFirstResponder()
        case 103:
            phoneField.becomeFirstResponder()
        case 104:
            emailField.becomeFirstResponder()
            case 105:
            webSiteField.becomeFirstResponder()
        default:
            print("Ciao")
        }
        return true
    }
    
    // Questo scatta quando l'utente inizia la modifica e 
    // faccio apparire una toolbar agganciata alla tastiera
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == nameField) {
            addAccessoryView(true, field: nameField)
        }
        if (textField == surNameField) {
            addAccessoryView(true, field: surNameField)
        }
        if (textField == addressField) {
            addAccessoryView(true, field: addressField)
        }
        if (textField == phoneField) {
            addAccessoryView(true, field: phoneField)
        }
        if (textField == emailField) {
            addAccessoryView(true, field: emailField)
        }
        if (textField == webSiteField) {
            addAccessoryView(true, field: webSiteField)
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
            let next = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "goToFowardField:")
            let previous = UIBarButtonItem(title: "Previous", style: UIBarButtonItemStyle.Done, target: self, action: "goToBackField:")
            keyboardToolbar.setItems([flex, previous, next], animated: false)
            field.inputAccessoryView = keyboardToolbar
        } else {
            // se è false eliminiamo l'accessoryView (quindi togliamo la toolbar dalla tastiera)
            field.inputAccessoryView = nil
        }
    }
    
    func goToBackField(textField: UITextField) {
        if webSiteField.isFirstResponder() {
            emailField.becomeFirstResponder()
        } else if emailField.isFirstResponder() {
            phoneField.becomeFirstResponder()
        } else if phoneField.isFirstResponder() {
            addressField.becomeFirstResponder()
        } else if addressField.isFirstResponder() {
            surNameField.becomeFirstResponder()
        } else if surNameField.isFirstResponder() {
            nameField.becomeFirstResponder()
        }
    }
    
    func goToFowardField(textField: UITextField) {
        if nameField.isFirstResponder() {
            surNameField.becomeFirstResponder()
        } else if surNameField.isFirstResponder() {
            addressField.becomeFirstResponder()
        } else if addressField.isFirstResponder() {
            phoneField.becomeFirstResponder()
        } else if phoneField.isFirstResponder() {
            emailField.becomeFirstResponder()
        } else if emailField.isFirstResponder() {
            webSiteField.becomeFirstResponder()
        }
    }
    
    func lock() -> Bool {
        let indexPath = tableView.indexPathForSelectedRow
        nameField.enabled = false
        surNameField.enabled = false
        addressField.enabled = false
        phoneField.enabled = false
        emailField.enabled = false
        webSiteField.enabled = false
        customerImage.userInteractionEnabled = false
        
        // Mostro la mappa
        if indexPath?.section == 0 && indexPath?.row == 5 {
            performSegueWithIdentifier("showMap", sender: self)
        }
        return true
    }
    
    func unlockAll(sender: AnyObject) -> Bool {
        let indexPath = tableView.indexPathForSelectedRow
        nameField.enabled = true
        surNameField.enabled = true
        addressField.enabled = true
        phoneField.enabled = true
        emailField.enabled = true
        webSiteField.enabled = true
        customerImage.userInteractionEnabled = true
        
        doneButtonItem.title = "Done"
        doneButtonItem.action = "donePressed:"
        if indexPath?.section == 0 && indexPath?.row == 5 {
            // let cell = tableView.cellForRowAtIndexPath(indexPath!)
        }
        
        return false
    }
    
    func sendEmail () {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendEmailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self // Set the delegate
        
        mailComposeVC.setToRecipients([emailField.text!])
        mailComposeVC.setSubject("Mail from To Painters")
        mailComposeVC.setMessageBody("", isHTML: false)
        
        return mailComposeVC
    }
    
    func showSendEmailErrorAlert() {
        let sendMailErrorAlert = SCLAlertView()
        
        sendMailErrorAlert.showError("Could not Send Email", subTitle: "Your device could not send e-mail.  Please check e-mail configuration and try again.", closeButtonTitle: "OK")
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Azione collegata alla gesture del tap fatto sull'immagine
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        CameraManager.sharedInstance.newImageFromLibraryForController(self, editing: true)
    }
    
    // CameraManagerDelegate Method
    func incomingImage(image: UIImage) {
        
        // mettiamo a video l'UIImage contenuta nella var image
        custImage = image
        
        // Arrotondo la UiimageView
        customerImage.layer.masksToBounds = false
        customerImage.layer.cornerRadius = 80
        customerImage.clipsToBounds = true
        
        // Passo l'immagine
        customerImage.image = custImage
        print("\(image)")
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        // Trasformo l'immagine in NSData (Classe contenitore di file)
        //let imageData = UIImagePNGRepresentation(custImage!)
        
        // Creo il PFFile (classe di Parse per i file)
        //let imageFile = PFFile(name: "customerPhoto.png", data: imageData!)
        
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
        //newCustomer["customerImage"] = imageFile
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
        
        //print("Immagine: \(imageFile), CustomerImage: \(customerImage.image!)")
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if lock() {
            addressField.enabled = false
            // Chiamo il numero di telefono
            if indexPath.section == 1 && indexPath.row == 0 {
                print("phoneNumber")
                
                // Creo l'actionSheet che mostrerà le opzioni per la navigazione
                let actionSheet = TOActionSheet()
                
                // Assegno il Titolo
                actionSheet.title = "Options"
                // Indico lo stile
                actionSheet.style = .Dark
                // Indoco il colore di background dei bottoni
                // actionSheet.buttonBackgroundColor = UIColor(red: 0/255.0, green: 196/255.0, blue: 0/255.0, alpha: 1.0)
                // Imposto la font dei testi
                actionSheet.titleFont = fontReg
                actionSheet.buttonFont = fontMed
                actionSheet.cancelButtonFont = fontMed
                
                // Aggiungo i bottoni
                actionSheet.addButtonWithTitle("Call") { () -> Void in
                    print("Calling")
                }
                
                actionSheet.addButtonWithTitle("Send a Message") { () -> Void in
                    print("Sending a Message!")
                }
                
                // Mostro l'ActionSheet
                actionSheet.showFromView(self.view, inView: self.view)
            }
            
            if indexPath.section == 1 && indexPath.row == 1 {
                print("emailAddress")
                sendEmail()
            }
        } else {
            unlockAll(self)
        }
    }
    
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let mapController = segue.destinationViewController as! MapController
            // Passo l'indirizzo alla stringa
            mapController.address = addressField.text
            MapManager.sharedInstance.customerName = self.title // Passo il nome del cliente alla stringa che verrà visualizzata nel pop up
        }
    }
}
