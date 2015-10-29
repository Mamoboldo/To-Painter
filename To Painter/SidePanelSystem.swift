//
//  SidePanelSystem.swift
//  SidePanelSystem
//
//  Created by Marcello Catelli on 2015
//  Copyright (c) 2015 Objective C srl
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

class SidePanelSystem: UIViewController, UIGestureRecognizerDelegate {
    
    var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var centerViewController: UIViewController!
    var leftViewController: UIViewController!
    var rightViewController: UIViewController!
    
    var gestureEnabled : Bool!
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    var panGestureRecognizer : UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureEnabled = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    }
    
    // MARK: Open / Close Methods
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func fullScreenLeftEnter() {
        if centerViewController != nil {
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(self.view.frame))
            showShadowForCenterViewController(false)
        }
    }
    
    func fullScreenLeftExit() {
        if centerViewController != nil {
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerViewController.view.frame) - centerPanelExpandedOffset)
            showShadowForCenterViewController(true)
        }
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    // MARK: - Panel Insertion
    
    func addCenterPanelViewController(controller: UIViewController) {
        if centerViewController != nil {
            UIView.animateWithDuration(0.25, animations: { () in
                self.centerViewController.view.frame.origin.x = (CGRectGetWidth(self.centerViewController.view.frame) + 10)
                }, completion: { (finish:Bool) -> Void in
                    self.centerViewController.view.removeFromSuperview()
                    self.centerViewController.removeFromParentViewController()
                    self.centerViewController = nil
                    
                    self.centerViewController = controller
                    self.view.insertSubview(self.centerViewController.view, atIndex: 2)
                    
                    self.addChildViewController(self.centerViewController)
                    self.centerViewController.didMoveToParentViewController(self)
                    self.centerViewController.view.addGestureRecognizer(self.panGestureRecognizer)
                    
                    self.centerViewController.view.frame.origin.x = (CGRectGetWidth(self.centerViewController.view.frame) - self.centerPanelExpandedOffset)
                    
                    self.animateCenterPanelXPosition(targetPosition: 0) { finished in
                        self.currentState = .BothCollapsed
                    }
            })
            
            return
        }
        
        centerViewController = controller
        view.insertSubview(centerViewController.view, atIndex: 2)
        
        addChildViewController(centerViewController)
        centerViewController.didMoveToParentViewController(self)
        centerViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func addLeftPanelViewController(controller: UIViewController) {
        if leftViewController != nil {
            leftViewController.removeFromParentViewController()
            leftViewController = nil
        }
        
        leftViewController = controller
        view.insertSubview(leftViewController.view, atIndex: 1)
        addChildViewController(leftViewController)
        leftViewController.didMoveToParentViewController(self)
        
    }
    
    func addRightPanelViewController(controller: UIViewController) {
        if rightViewController != nil {
            rightViewController.removeFromParentViewController()
            rightViewController = nil
        }
        
        rightViewController = controller
        view.insertSubview(rightViewController.view, atIndex: 0)
        addChildViewController(rightViewController)
        rightViewController.didMoveToParentViewController(self)
    }
    
    // MARK: Panel Animation
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerViewController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
            }
        }
    }
    
    func animateRightPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .RightPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerViewController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .BothCollapsed
                
                //self.rightViewController!.view.removeFromSuperview()
                //self.rightViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerViewController.view.layer.shadowOpacity = 0.8
        } else {
            centerViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // we can determine whether the user is revealing the left or right
        // panel by looking at the velocity of the gesture
        
        if !gestureEnabled { return }
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        if !gestureIsDraggingFromLeftToRight && rightViewController == nil && currentState == .BothCollapsed {
            return
        }
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                showShadowForCenterViewController(true)
            }
        case .Changed:
            // If the user is already panning, translate the center view controller's
            // view by the amount that the user has panned
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            // When the pan ends, check whether the left or right view controller is visible
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > (view.bounds.size.width - 50)
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            } else if (rightViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

extension UIViewController {
    func sidePanelSystem() -> SidePanelSystem {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.window!.rootViewController as! SidePanelSystem
    }
    
}