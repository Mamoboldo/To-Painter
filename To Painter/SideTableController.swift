//
//  SideTableController.swift
//  To Painter
//
//  Created by Marco Boldetti on 15/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class SideTableController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Tolgo il separatore dalla tableView
        self.tableView.separatorStyle = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
                
            case 0:
                let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("customer") as! UINavigationController
                //Aggiungo il centerPanel al sistema di gestione
                self.sidePanelSystem().addCenterPanelViewController(centerPanel)
                
            case 1:
                let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("estimate") as! UINavigationController
                self.sidePanelSystem().addCenterPanelViewController(centerPanel)
                
            case 2:
                let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("color") as! UINavigationController
                self.sidePanelSystem().addCenterPanelViewController(centerPanel)
                
            case 3:
                let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("settings") as! UINavigationController
                self.sidePanelSystem().addCenterPanelViewController(centerPanel)
                
            case 4:
                let alert = SCLAlertView()
                alert.addButton("Logout", action: { () -> Void in
                    let customersController = CustomersTableController()
                    customersController.customersArray.removeAll()
                    //Rimetto come centerPanel, il Customer controller
                    let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("customer") as! UINavigationController
                    //Aggiungo il centerPanel al sistema di gestione
                    self.sidePanelSystem().addCenterPanelViewController(centerPanel)
                    
                    PFUser.logOut()
                    
                    /*
                    // Faccio apparire la view di login
                    let loginController : UITableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("login") as! UITableViewController
                    self.presentViewController(loginController, animated: true, completion: nil)
                    */
                })
                alert.showError("Attention!", subTitle: "Are you sure you want to log out?", closeButtonTitle: "Cancel")
                
            default: "Nothing selected"
            }
            // questo serve per evitare che la cella rimanga selezionata
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
