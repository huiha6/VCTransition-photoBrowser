//
//  ImgBrowserTransitionDelegate.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/17.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class ImgBrowserTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactive: Bool = false
    var interactionController = UIPercentDrivenInteractiveTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImgBrowserPresentAnimator()
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImgBrowserDismissAnimator()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }
    
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
}
