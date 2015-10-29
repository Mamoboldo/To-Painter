//
//  CustomersModel.swift
//  To Painter
//
//  Created by Marco Boldetti on 19/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class CustomersModel: NSObject {
    
    // Questa classe mi serve solo in locale per Caricare successivamente tutto su Parse
    var name : String!
    var surName : String!
    var address : String!
    var phoneNumber : String!
    var emailAddress : String!
    var webSite : String!
    var customerImage : String!
    var customerObject : PFObject!

}
