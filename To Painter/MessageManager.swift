//
//  MessageManager.swift
//  Fastacts
//
//  Created by Marcello Catelli on 12/08/14.
//  Copyright (c) 2014 Objective C srl. All rights reserved.
//

import UIKit
import MobileCoreServices
import MessageUI

class MessageManager: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    class var sharedInstance:MessageManager {
        get {
            struct Static {
                static var instance : MessageManager? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) { Static.instance = MessageManager() }
            
            return Static.instance!
        }
    }
    
    func sendMailTo(dest dest : String,
        subject : String,
        body : String,
        attachment : NSData?,
        mime : String,
        fname : String,
        controller : UIViewController) {
        
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([dest])
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(body, isHTML: false)
            
            if let atta = attachment {
                mailComposer.addAttachmentData(atta,
                                           mimeType: mime,
                                           fileName: fname)
            }
            controller.presentViewController(mailComposer,
                animated: true,
                completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func sendMessageTo(phone phone : String, messg : String, controller: UIViewController) {
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = [phone]
        messageComposer.body = messg
        controller.presentViewController(messageComposer,
            animated: true,
            completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
