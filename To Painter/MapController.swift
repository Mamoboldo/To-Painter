//
//  MapController.swift
//  To Painter
//
//  Created by Marco Boldetti on 02/11/15.
//  Copyright © 2015 Marco Boldetti. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class MapController: UIViewController, MKMapViewDelegate, MapManagerDelegate {
    @IBOutlet var customerAddressMap : MKMapView!
    
    // Font per la actionsheet
    let fontReg = UIFont(name: "AvenirNext-Regular", size: 14)
    let fontMed = UIFont(name: "AvenirNext-Medium", size: 15)
    let fontBold = UIFont(name: "AvenirNext-Bold", size: 15)
    
    var address : String! // Indirizzo che verrà passato dalla textField

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerAddressMap.delegate = self
        customerAddressMap.userTrackingMode = MKUserTrackingMode.Follow

        // Aggancio il delegate
        MapManager.sharedInstance.delegate = self
        MapManager.sharedInstance.controller = self
        
        // Chiedo di "Rovesciare" l'indirizzo contenuto nel textfield
        MapManager.sharedInstance.georeverseAddress(address)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // quando appare il controller sistemiamo un vecchio bug di CoreLocation
        MapManager.sharedInstance.findLocation = false
        
        // diciamo a MapManager di trovare dove sta l'utente
        // MapManager.sharedInstance.startUpdateLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MapManagerDelegate Methods
    func incomingUserLocation(region: MKCoordinateRegion) {
        // Imposto la regione della mappa
        customerAddressMap.setRegion(region, animated: false)
        
        // Dico al MapManager la mappa da usare
        MapManager.sharedInstance.currentMap = customerAddressMap
    }
    
    func incomingPin(pin: Pin) {
        customerAddressMap.setRegion(MKCoordinateRegionMake(pin.coordinate, MKCoordinateSpanMake(0.005, 0.005)), animated: true)
        
        customerAddressMap.addAnnotation(pin)
    }
    
    func incomingError(error: NSError) {
        let alert = SCLAlertView()
        alert.showError("Warning!", subTitle: "\(error.description)", closeButtonTitle: "OK")
    }
    
    // MARK: - MKMapViewDelegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let annotationView : MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "currentLocation")
        annotationView.pinTintColor = MKPinAnnotationView.purplePinColor()
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        annotationView.calloutOffset = CGPointMake(-8, 0)
        
        annotationView.autoresizesSubviews = true
        annotationView.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        var pin = view.annotation as! Pin
        
        func openMaps(action: TOActionSheet!) {
            
            let endLocation = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
            let endItem = MKMapItem(placemark: endLocation)
            endItem.name = view.annotation!.title!
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            
            endItem.openInMapsWithLaunchOptions(launchOptions)
        }
        
        // Creo l'actionSheet che mostrerà le opzioni per la navigazione
        let actionSheet = TOActionSheet()
        
        // Assegno il Titolo
        actionSheet.title = "Options"
        // Indico lo stile
        actionSheet.style = .Dark
        // Indoco il colore di background dei bottoni
        actionSheet.buttonBackgroundColor = UIColor(red: 0/255.0, green: 196/255.0, blue: 0/255.0, alpha: 1.0)
        // Imposto la font dei testi
        actionSheet.titleFont = fontReg
        actionSheet.buttonFont = fontMed
        actionSheet.cancelButtonFont = fontMed
        
        // Aggiungo i bottoni
        actionSheet.addButtonWithTitle("Get Directions") { () -> Void in
            openMaps(actionSheet)
        }
        
        // Mostro l'ActionSheet
        actionSheet.showFromView(self.view, inView: self.view)
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
