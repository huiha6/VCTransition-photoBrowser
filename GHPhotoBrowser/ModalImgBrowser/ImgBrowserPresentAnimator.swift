//
//  ImgBrowserModalAnimator.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/17.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class ImgBrowserPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let tabbarC = transitionContext.viewController(forKey: .from) as! UITabBarController
//        let navC = tabbarC.selectedViewController as! UINavigationController
//        let fromVC = navC.viewControllers.first as! FirstViewController
        let toVC = transitionContext.viewController(forKey: .to) as! ImgBrowserViewController
        toVC.browserView.imgView.isHidden = true
        let moveView = toVC.moveView//UIImageView(frame: toVC.imgViewFrame)
//        moveView.image = toVC.image
//        toVC.view.addSubview(moveView)
        
        let toView = toVC.view
        let containerView = transitionContext.containerView
        toView?.frame = containerView.bounds
        //注意：present时，fromView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此fromView消失不见，其他情况的模态转场可以 不受影响
        containerView.addSubview(toView!)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            moveView.frame = toVC.browserView.imgView.frame
            toView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }) { (finished) in
            toVC.browserView.imgView.isHidden = false
            toVC.moveView.isHidden = true
            transitionContext.completeTransition(true)
        }
    }
}


