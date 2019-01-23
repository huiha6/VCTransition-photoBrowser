//
//  PhotoBrowserPresentAnimator.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class PhotoBrowserPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //        let tabbarC = transitionContext.viewController(forKey: .from) as! UITabBarController
        //        let navC = tabbarC.selectedViewController as! UINavigationController
        //        let fromVC = navC.viewControllers.first as! FirstViewController
        let toVC = transitionContext.viewController(forKey: .to) as! PhotoBroserViewController
        toVC.browserCollectionView.isHidden = true
        let moveView = toVC.moveView
        let toView = toVC.view
        let containerView = transitionContext.containerView
        toView?.frame = containerView.bounds
        //注意：present时，fromView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此fromView消失不见，其他情况的模态转场可以 不受影响
        containerView.addSubview(toView!)
        let theFrame = PhotoBrowserView.getImgViewFrame(toVC.imgAry[toVC.currentPage].size)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            moveView.frame = theFrame//toVC.browserView.imgView.frame
            toView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }) { (finished) in
            toVC.browserCollectionView.isHidden = false
            moveView.isHidden = true
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
