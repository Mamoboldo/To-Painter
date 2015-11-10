//
//  CameraManager.swift
//  PizzaList
//
//  Created by Marcello Catelli on 27/07/14.
//  Copyright (c) 2014 Objective C srl. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc protocol CameraManagerDelegate {
    optional func incomingImage(image: UIImage)
    optional func incomingVideo(video: String)
    optional func cancelImageSelection()
}

// il singleton per facilitare l'uso della fotocamera / libreria
class CameraManager: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   
    class var sharedInstance:CameraManager {
        get {
            struct Static {
                static var instance : CameraManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) { Static.instance = CameraManager() }
            
            return Static.instance!
        }
    }
    
    //nel controller che deve ricevere l'immagine aggingere il delegato CameraManagerDelegate
    //e scrivere nel vieDidLoad CameraManager.sharedInstance.delegate = self
    var delegate : CameraManagerDelegate!
    
    //IMMAGINI
    //questi metodi vanno invocati SOLO da un controller, e solo dopo aver implementato il delegato
    //nel controller che li chiama devi implementare il metodo func incomingImage(image: UIImage) { }
    //se no l'App va in crash
    
    //scegli una foto dalla libreria di iOS
    func newImageFromLibraryForController(controller: UIViewController, editing: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        picker.allowsEditing = editing
        
        controller.presentViewController(picker, animated: true, completion: nil)
    }
    
    //scatta una nuova foto
    func newImageShootForController(controller: UIViewController, editing: Bool, overlay: UIImageView?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.Camera;
        let arra : [AnyObject] = [kUTTypeImage]
        picker.mediaTypes = arra as! [String]
        picker.allowsEditing = editing

        if let test = overlay {
            picker.cameraOverlayView = test
        }

        controller.presentViewController(picker, animated: true, completion: nil)
    }
    
    //VIDEO
    //questi metodi vanno invocati SOLO da un controller, e solo dopo aver implementato il delegato
    //nel controller che li chiama devi implementare il metodo func incomingVideo(video: String) { }
    //se no l'App va in crash
    
    //scegli un video dalla libreria
    func newVideoFromLibraryForController(controller: UIViewController, editing: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        let arra : [AnyObject] = [kUTTypeMovie]
        picker.mediaTypes = arra as! [String]
        picker.allowsEditing = editing
        
        controller.presentViewController(picker, animated: true, completion: nil)
    }
    
    //gira un nuovo video
    func newVideoShootForController(controller: UIViewController, editing: Bool, maxDuration: NSTimeInterval) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        let arra : [AnyObject] = [kUTTypeMovie]
        picker.mediaTypes = arra as! [String]
        picker.videoMaximumDuration = maxDuration
        picker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
        picker.allowsEditing = editing
        
        controller.presentViewController(picker, animated: true, completion: nil)
    }
    
    //SANDBOX
    //restituisce il percorso della cartella documents della sandbox dell'App
    func cartellaDocuments() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        //println(paths[0] as String)
        return paths[0] as String
    }
    
    //metodi del delegato dell'UIImagePickerController
    //NON USARLI, servono solo internamente a questo Manager
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
    
        if mediaType == kUTTypeImage {
            
            let imageEdited : UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
            
            if let test = imageEdited {
                self.delegate.incomingImage?(test)
            } else {
                let imageOriginal = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.delegate.incomingImage?(imageOriginal)
            }
            
        } else if mediaType == kUTTypeMovie {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
                let filePath = videoURL.absoluteString
                self.delegate.incomingVideo?(filePath)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        delegate.cancelImageSelection?()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
