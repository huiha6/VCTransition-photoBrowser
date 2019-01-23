//
//  PhotoBrowserDismissAnimator.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class PhotoBrowserDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let tabbarC = transitionContext.viewController(forKey: .to) as! UITabBarController
        let navC = tabbarC.selectedViewController as! UINavigationController
        let toVC = navC.viewControllers.first as! FirstViewController
        toVC.hiddenStatusBar = false
        toVC.setNeedsStatusBarAppearanceUpdate()

        let fromVC = transitionContext.viewController(forKey: .from) as! PhotoBroserViewController
        let moveView = fromVC.moveView//browserView.imgView
        let fromView = fromVC.view
        if fromVC.isTapDismiss {
            moveView.image = fromVC.imgAry[fromVC.currentPage]
            moveView.isHidden = false
            fromVC.browserCollectionView.isHidden = true
            fromVC.pageControl.isHidden = true
            let theFrame = fromVC.imgViewFrameAry[fromVC.currentPage]
            //注意：dismiss时，toView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此toView消失不见，其他情况的模态转场可以 不受影响
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                moveView.frame = theFrame
                fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
        }else{
            //注意：dismiss时，toView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此toView消失不见，其他情况的模态转场可以 不受影响
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }) { (finished) in
                if transitionContext.transitionWasCancelled {
                    toVC.hiddenStatusBar = true
                    toVC.setNeedsStatusBarAppearanceUpdate()

                    let cell = fromVC.browserCollectionView.cellForItem(at: IndexPath(item: fromVC.currentPage, section: 0)) as! BrowserCollectionViewCell
                    UIView.animate(withDuration: 0.2, animations: {
                        fromView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                        moveView.frame.size = cell.browserView.orgImgViewSize
                        moveView.center = cell.browserView.orgImgViewCenter
                    }, completion: { (_) in
//                        cell.browserView.isScrollEnabled = true
                        moveView.isHidden = true
                        fromVC.browserCollectionView.isHidden = false
                        fromVC.pageControl.isHidden = false
                        transitionContext.completeTransition(false)
                    })
                }else{
                    let theFrame = fromVC.imgViewFrameAry[fromVC.currentPage]
                    UIView.animate(withDuration: 0.2, animations: {
                        fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                        moveView.frame = theFrame
                    }, completion: { (_) in
                        transitionContext.completeTransition(true)
                    })
                }
            }
        }
    }
    
    
}
