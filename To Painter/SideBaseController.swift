//
//  SideBaseController.swift
//  Side Panel
//
//  Created by Marcello Catelli on 29/08/14.
//  Copyright (c) 2014 Objective C srl. All rights reserved.
//

import UIKit

// per far funzionare il sistema a pannelli occorre creare una sottoclasse di SidePanelSystem.swift
// come questo file di esempio
// nello storyboard il controller con l'entry point (la freccia grigia) ha questa classe come pilota
class SideBaseController: SidePanelSystem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // carichiamo in memoria il SideTableController
        // nello storyboard è un controller non direttamente connesso a nulla che ha come Storyboard ID il nome di 'side'
        let leftPanel = self.storyboard!.instantiateViewControllerWithIdentifier("side") as! UINavigationController
        
        // aggiungiamolo al sistema dei pannelli
        self.addLeftPanelViewController(leftPanel)
        
        // idem con il pannello centrale in cui carichiamo GreenController
        let centerPanel = self.storyboard!.instantiateViewControllerWithIdentifier("customer") as! UINavigationController
        self.addCenterPanelViewController(centerPanel)
        
        // per disabilitare le gesture decommentare questa riga
        //self.gestureEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
