//
//  AppDelegate.swift
//  To Painter
//
//  Created by Marco Boldetti on 15/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    func customizeAppearance() {
        let tintColor = UIColor(red: 9/255.0, green: 169/255.0, blue: 235/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
       customizeAppearance()
        
        // Avvio il collegamento a Parse
        Parse.enableLocalDatastore()
        
        // Mi collego a Parse
        Parse.setApplicationId("Oqx4kFD6y8Uech66gJNkDYDYViE5HaT7hUNZchiv",
            clientKey: "AxngT2a2JZ8avNKbN90j2FIMP30g4jbk70q9l8cp")
        
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

