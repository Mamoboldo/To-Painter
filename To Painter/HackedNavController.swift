//
//  HackedNavController.swift
//  To Painter
//
//  Created by Marco Boldetti on 15/10/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit

class HackedNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return topViewController!.preferredStatusBarStyle()
    }
}
