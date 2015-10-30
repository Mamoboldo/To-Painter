//
//  QuotationsModel.swift
//  To Painter
//
//  Created by Marco Boldetti on 29/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

class QuotationsModel: NSObject {
    
    var paintersName    : String! // Nome Imbianchino
    var customerName    : String! // Nome Cliente
    var date            : NSDate! // Data del preventivo
    
    var quotationTitle  : String! // Descrizione del preventivo
    
    var quotationObject : PFObject!
}
