//
//  MapManager.swift
//  PizzaList
//
//  Created by Marcello Catelli on 28/07/14.
//  Copyright (c) 2014 Objective C srl. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI
import Contacts
import Parse

@objc protocol MapManagerDelegate {
    optional func incomingUserLocation(region: MKCoordinateRegion)
    optional func incomingPin(pin: Pin)
    optional func didFinishSearchPoi()
    optional func incomingAddress(address: String)
    func incomingError(error: NSError)
}

class MapManager: NSObject, CLLocationManagerDelegate {
    
    var customerName : String! // var per mettere il nome del cliente sopra il Pin quando lo premiamo
    
    class var sharedInstance:MapManager {
        get {
            struct Static {
                static var instance : MapManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) { Static.instance = MapManager() }
            
            return Static.instance!
        }
    }
    
    var controller : MapController!
    var currentMap : MKMapView!
    var locationManager : CLLocationManager!
    var findLocation = false
    var delegate : MapManagerDelegate!
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !findLocation {
            findLocation = true
            if locations.count > 0 {
                let location = locations[0] as CLLocation
                self.delegate.incomingUserLocation!(MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.2, 0.2)))
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error)")
        findLocation = false
        
        let titolo = NSLocalizedString("WARNING", comment: "Warning")
        let messaggio = NSLocalizedString("MAP_ERROR", comment: "Connection fault, check the data network and / or GPS coverage")
        
        let alert = SCLAlertView()
        alert.showError(titolo, subTitle: messaggio, closeButtonTitle: "OK")
        
        /*
        let myAlert = UIAlertController(title: titolo,
            message: messaggio,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        controller.presentViewController(myAlert, animated: true, completion: nil)
        print(error)
        */
    }
    
    func searchPoiWithName(name: String!) {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = name
        searchRequest.region = currentMap.region
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.startWithCompletionHandler { (response:MKLocalSearchResponse?, error:NSError?) -> Void in
            if let errorTest = error {
                self.delegate.incomingError(errorTest)
                return
            }
            
            if let responseTest = response {
                if responseTest.mapItems.count > 0 {
                    for item in responseTest.mapItems {
                        let it = item as MKMapItem
                        let pin  = Pin(coordinate: it.placemark.coordinate)
                        pin.title = it.name
                        pin.subtitle = it.placemark.thoroughfare //it.placemark.addressDictionary[] as? String
                        pin.phone = it.phoneNumber
                        self.delegate.incomingPin!(pin)
                    }
                    
                    self.delegate.didFinishSearchPoi!()
                }
            }
        }
    }
    
    func georeverseAddress(address: String!) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if let errorTest = error {
                self.delegate.incomingError(errorTest)
                return
            }
            
            if placemarks?.count > 0 {
                let cp = placemarks?.first
                
                //self.delegate.incomingUserLocation!(MKCoordinateRegionMake(cp.location.coordinate, MKCoordinateSpanMake(0.005, 0.005)))
                
                if let cpTest = cp {
                    let pin = Pin(coordinate: cpTest.location!.coordinate)
                    
                    //let coordinate = "\(cpTest.location!.coordinate.latitude) \(cpTest.location!.coordinate.longitude)"
                    pin.title = self.customerName
                    pin.subtitle = address
                    self.delegate.incomingPin!(pin)
                }
                
            } else {
                let titolo = NSLocalizedString("WARNING", comment: "Warning")
                let messaggio = NSLocalizedString("MAP_ADDRESS_ERROR", comment: "Can't find this address")
                
                let alert = SCLAlertView()
                alert.showError(titolo, subTitle: messaggio, closeButtonTitle: "OK")
                
                /*
                let myAlert = UIAlertController(title: titolo,
                    message: messaggio,
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.controller.presentViewController(myAlert, animated: true, completion: nil)
                */
            }
        }
    }
    
    func georeverseCoordinate(coord: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if let errorTest = error {
                self.delegate.incomingError(errorTest)
                return
            }
            
            if placemarks?.count > 0 {
                let cp = placemarks?.first
                
                if let cpTest = cp {
                    let address = "\(cpTest.locality) \(cpTest.administrativeArea)"
                    self.delegate.incomingAddress!(address)
                }
                
            } else {
                let titolo = NSLocalizedString("WARNING", comment: "Warning")
                let messaggio = NSLocalizedString("MAP_COORDINATE_ERROR", comment: "Can't find the coordinates")
                
                let alert = SCLAlertView()
                alert.showError(titolo, subTitle: messaggio, closeButtonTitle: "OK")
                
                /*
                let myAlert = UIAlertController(title: titolo,
                    message: messaggio,
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.controller.presentViewController(myAlert, animated: true, completion: nil)
                */
            }
        }
    }
}
