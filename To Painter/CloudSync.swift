//
//  CloudSync.swift
//  Decorate
//
//  Created by Marco Boldetti on 07/10/15.
//  Copyright (c) 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

protocol CloudSyncDelegate{
    func syncCompleted(success : Bool)
    func syncNetowkAvailable()
}
var tablesArray = ["Customer","Quotation"]

struct Tables {  //struttura per poter richiamare facilmente i nomi delle tabelle dalle altri classi
    let TABLE_CUSTOMERS =    tablesArray[0]
    let TABLE_QUOTATIONS =   tablesArray[1]
    let count = 2
}
class CloudSync: NSObject {
    
    var delegate : CloudSyncDelegate?
    let reachability = Reachability.reachabilityForInternetConnection()
    var timeOut = false
    var quequeCheckCount = 0
    
    func beginSync() -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        if reachability!.isReachable() {
            /*ritardo di 1 sec per permettere di smaltire la cosa di Parse*/
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerQueue", userInfo: nil, repeats: false)
            quequeCheckCount = 0
            beginCheckLocal()
            timeOut = false
            reachability!.stopNotifier()
            return true
        }
        else{
            reachability!.startNotifier()
            return false
        }
    }
    func timerQueue(){ //inizia il sync
        cloudQuery()
    }
    func cloudQuery(){
        if reachability!.isReachable() == false { // controllo se c'è ancora rete
            self.delegate?.syncCompleted(false)
            reachability!.startNotifier()
        }
        let user = PFUser.currentUser()!.username!
        var cloudDictResult = [String : [PFObject]]()
        var resCount = 0
        /*imposto un limite di tempo di 20 sec oltre il quale dichiaro fallito il sync*/
        let timeOutTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: "timerErrorDownload", userInfo: nil, repeats: false)
        timeOut = false
        for tableName in tablesArray {
            let query = PFQuery(className: tableName)
            query.limit = 1000
            query.whereKey("username", equalTo: user)
            query.findObjectsInBackgroundWithBlock{
                (objects : [PFObject]?, error: NSError?) -> Void in
                if self.timeOut == true {
                    return
                }
                if error == nil && objects != nil {
                    ++resCount
                    print("query \(tableName) trovati \(objects!.count) oggetti")
                    cloudDictResult[tableName] = objects
                    if resCount == tablesArray.count {
                        timeOutTimer.invalidate()
                        print("scaricate tutte dal cloud")
                        self.unpinThenPinAll(cloudDictResult)
                    }
                }
                else {
                    self.delegate?.syncCompleted(false)
                    return
                }
            }
        }
    }
    func unpinThenPinAll(dict : [String : [PFObject]]) {
        var resCount = 0
        PFObject.unpinAllObjectsInBackgroundWithBlock {
            (succ : Bool, error : NSError?) -> Void in
            for tableName in tablesArray {
                let arrayToPin = dict[tableName]
                PFObject.pinAllInBackground(arrayToPin, block : {
                    (succeeded : Bool , error : NSError?) -> Void in
                    if error == nil {
                        ++resCount
                        if resCount == tablesArray.count{
                            print("db locale completamente aggiornato")
                            self.delegate?.syncCompleted(true)
                        }
                    }
                    else{
                        self.delegate?.syncCompleted(false)
                    }
                })
            }
        }
    }
    func timerErrorDownload() {
        print("timeout")
        timeOut = true
        self.delegate?.syncCompleted(false)
    }
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        if reachability.isReachable() {
            delegate!.syncNetowkAvailable()
        }
    }
    
    private func beginCheckLocal() {
        Parse.setLogLevel(PFLogLevel.None)
        ++quequeCheckCount
        print("Tentativo Checklocal \(quequeCheckCount)")
        
        // Check non completato
        if quequeCheckCount == 10 {
            self.delegate?.syncCompleted(false)
            return
        }
        print("Controllo local")
        var tableCount = 0
        for table in tablesArray {
            let query = PFQuery(className: table)
            query.fromLocalDatastore()
            query.whereKeyDoesNotExist("objectId") // se in locale non ho id, vuol dire che nel cloud non esiste questo oggetto
            query.getFirstObjectInBackgroundWithBlock({ (result, error) -> Void in
                if error == nil || error?.code == 101 {
                    if result != nil { // ho trovato qualcosa
                        print("C'è qualcosa nel locale non salvato in rete")
                        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timerCheckLocal", userInfo: nil, repeats: false)
                    } else {
                        // trovato niente
                        ++tableCount
                        if tableCount == tablesArray.count {
                            print("è stato salvato tutto nel cloud, comincio query nel cloud")
                            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "timerEndCheckLocal", userInfo: nil, repeats: false)
                            Parse.setLogLevel(PFLogLevel.Debug)
                            self.quequeCheckCount = 0
                        }
                    }
                }
            })
        }
    }
    
    func timerCheckLocal() {
        beginCheckLocal() // rifà il check
    }
    
    func timerEndCheckLocal() {
        self.cloudQuery()
    }
}
