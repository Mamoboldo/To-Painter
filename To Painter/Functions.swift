//
//  Functions.swift
//  MyLocations
//
//  Created by Marco Boldetti on 15/01/15.
//  Copyright (c) 2015 Marco Boldetti. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

func copyToLocal (internetArray: NSMutableArray, var localArray: NSMutableArray) {
    let reachability = Reachability.reachabilityForInternetConnection()
    
    // controllo la presenza della connessione
    if reachability!.isReachable() {
        localArray = internetArray
        print(localArray)
        print("copyToLocal")
    }
}

func copyToInternet (localArray: NSMutableArray, var internetArray: NSMutableArray) {
    let reachability = Reachability.reachabilityForInternetConnection()
    
    // controllo la presenza della connessione
    if reachability!.isReachable() {
        internetArray = localArray
        print(internetArray)
        print("copyToInternet")
    }
}