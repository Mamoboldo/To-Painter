//
//  CustomersTableController.swift
//  To Painter
//
//  Created by Marco Boldetti on 15/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Bolts
import Parse
import ParseUI

class CustomersTableController: UITableViewController, CloudSyncDelegate, AddCustomerDelegate {
    
    let cloudSync = CloudSync()
    var customersArray = [CustomersModel]()
    var refresh : UIRefreshControl!
    
    var editCustomer = false
    var rowIndexToEdit = -1 // Indice per capire il cliente da modificare

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontReg = UIFont(name: "AvenirNext-Regular", size: 17)
        
        //Personalizzo la font dei pulsanti del navigationItem
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: fontReg!], forState: .Normal)
        
        let logoutButton = UIBarButtonItem (title: "Logout", style: .Plain, target: self, action: "userLogout")
        self.navigationItem.leftBarButtonItem = logoutButton
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refreshBegin", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        
        cloudSync.delegate = self
        
        // Mi collego a Parse, se non ci sono utenti loggati, chiedo il login o Registrazione
        if (PFUser.currentUser() != nil) {
            cloudSync.beginSync()
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Login", target: self, selector: "showLoginView")
                alert.addButton("Register", target: self, selector: "showRegisterView")
                
                alert.showError("To Painters", subTitle: "Not users are logged in, please make a login or register!")
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let fontReg = UIFont(name: "AvenirNext-Regular", size: 17)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: fontReg!], forState: .Normal)
        updateTable() // Riempio la tableView con i dati locali
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Setto la StatusBar a LightContent cioè bianca
        return UIStatusBarStyle.LightContent
    }
    
    func showLoginView() {
        let loginController : UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("login") as! UITableViewController
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    
    func showRegisterView() {
        let registerController : UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("register") as! UITableViewController
        self.presentViewController(registerController, animated: true, completion: nil)
    }
    
    func userLogout() {
        let alert = SCLAlertView()
        alert.addButton("Logout", action: { () -> Void in
            PFUser.logOut()
            self.showLoginView()
        })
        alert.showWarning("Attention!", subTitle: "Are you sure you want to log out?", closeButtonTitle: "Cancel")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - CloudSyncDelegate
    func syncCompleted(success: Bool) {
        refresh.endRefreshing()
        if success {
            print("Nel locale ci sono nuovi dati")
            updateTable()
            // Qui si può dare l'ordine di ricaricarsi anche a QuotationsController
        } else {
            print("Non  c'è rete, nel locale ci sono i vecchi dati")
        }
    }
    
    // MARK: - Parse loader
    func updateTable() {
        let query = PFQuery(className: Tables().TABLE_CUSTOMERS)
        query.limit = 1000 // Limito i clienti a 1000
        query.orderByAscending("name")
        query.fromLocalDatastore()
        //query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.customersArray.removeAll(keepCapacity: false)
                for obj in objects! {
                    let newCustomer = CustomersModel()
                    newCustomer.name = obj["name"] as? String
                    newCustomer.surName = obj["surName"] as? String
                    newCustomer.address = obj["address"] as? String
                    newCustomer.phoneNumber = obj["phoneNumber"] as? String
                    newCustomer.emailAddress = obj["emailAddress"] as? String
                    newCustomer.webSite = obj["webSite"] as? String
                    newCustomer.customerObject = obj
                    self.customersArray.append(newCustomer)
                }
                self.tableView.reloadData()
            } else {
                print(error?.description)
            }
        }
    }
    
    func refreshBegin() {
        cloudSync.beginSync()
    }
    
    // MARK: - AddCustomerDelegate Methods
    func customerAdded() {
        updateTable()
    }
    
    func syncNetowkAvailable() {
        print("La rete è nuovamente disponibile, carico il database")
        cloudSync.beginSync()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (PFUser.currentUser() != nil) {
            return customersArray.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customerCell", forIndexPath: indexPath) as! CustomerCell
        
        cell.customerNameLabel.text = "\(customersArray[indexPath.row].name) \(customersArray[indexPath.row].surName)"
        cell.addressLabel.text = "\(customersArray[indexPath.row].address)"

        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showCustQuotation", sender: self)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            
            self.editCustomer = true // Passo alla modalità modifica del cliente
            self.rowIndexToEdit = indexPath.row // Assegno l'indice della cella selezionata
            
            // Richiamo il segue
            self.performSegueWithIdentifier("addCustomerSegue", sender: self)
        }
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            
            self.customersArray[indexPath.row].customerObject.unpinInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if error == nil {
                    self.customersArray[indexPath.row].customerObject.deleteEventually()
                    self.updateTable()
                }
            }
        }
        
        editAction.backgroundColor = UIColor.grayColor()
        return [deleteAction, editAction]
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCustomerSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let addCustomerVC = navController.topViewController as! AddCustomerController
            
            //Assegno il delegate
            addCustomerVC.delegate = self
            if editCustomer {
                editCustomer = false
                addCustomerVC.customerIsEdit = true
                
                // Assegno l'oggetto da modificare all'indice dell'array
                addCustomerVC.customerToEdit = customersArray[rowIndexToEdit].customerObject
            }
            
        }
        
        if segue.identifier == "showCustQuotation" {
            let quotationVC = segue.destinationViewController as! QuotationsViewController
            let indexPath = tableView.indexPathForSelectedRow!
            quotationVC.title = "\(customersArray[indexPath.row].name) \(customersArray[indexPath.row].surName)"
        }
    }
}
