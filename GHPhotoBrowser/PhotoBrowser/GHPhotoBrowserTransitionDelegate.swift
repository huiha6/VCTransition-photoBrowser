//
//  PhotoBrowserTransitionDelegate.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class GHPhotoBrowserTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactive: Bool = false
    var interactionController = UIPercentDrivenInteractiveTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GHPhotoBrowserPresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GHPhotoBrowserDismissAnimator()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let vc = presented as! GHPhotoBroserViewController
        let animatorCoordinator = GHPhotoBrowserMaskController(presentedViewController: presented, presenting: presenting)
        vc.animatorCoordinator = animatorCoordinator
        return animatorCoordinator
    }
}

class GHPhotoBrowserMaskController: UIPresentationController {
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(maskView)
        maskView.frame = containerView!.bounds
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.maskView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }, completion: { (_) in
            
        })
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.maskView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }, completion: { (_) in
            
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        
    }
    
    lazy var maskView: UIView = {
        // 1.添加蒙版
        let maskView = UIView()
        maskView.backgroundColor = UIColor.black
        return maskView
    }()
}
