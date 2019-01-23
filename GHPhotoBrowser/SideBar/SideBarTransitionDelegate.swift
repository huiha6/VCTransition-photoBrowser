//
//  VCTransitionDelegate.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/16.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class SideBarTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactive: Bool = false
    var interactionController = UIPercentDrivenInteractiveTransition()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideBarPresentAnimator()
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SideBarDismissAnimator()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }


    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? interactionController : nil
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return GHPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class GHPresentationController: UIPresentationController {
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(coverButton)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
    }
    
    override func containerViewWillLayoutSubviews() {
        
    }
    
    lazy var coverButton: UIButton = {
        // 1.添加蒙版
        let coverButton = UIButton()
        coverButton.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        coverButton.frame = containerView!.bounds
        coverButton.addTarget(self, action: #selector(coverBtnClick), for: .touchUpInside)
        return coverButton
    }()
    @objc func coverBtnClick() {
        presentedViewController.dismiss(animated: true) {
        }
    }
}
