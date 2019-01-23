//
//  ImgBrowserDismissAnimator.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/17.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class ImgBrowserDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! ImgBrowserViewController
        let moveView = fromVC.moveView//browserView.imgView
        let fromView = fromVC.view
        if fromVC.isTapDismiss {
            //注意：dismiss时，toView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此toView消失不见，其他情况的模态转场可以 不受影响
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                moveView.frame = fromVC.imgViewFrame
                fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
        }else{
            //注意：dismiss时，toView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此toView消失不见，其他情况的模态转场可以 不受影响
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            }) { (finished) in
                if transitionContext.transitionWasCancelled {
                    UIView.animate(withDuration: 0.2, animations: {
                        fromView?.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                        moveView.frame.size = fromVC.browserView.orgImgViewSize
                        moveView.center = fromVC.browserView.orgImgViewCenter
                    }, completion: { (_) in
                        moveView.isHidden = true
                        fromVC.browserView.imgView.isHidden = false
                        transitionContext.completeTransition(false)
                    })
                }else{
                    UIView.animate(withDuration: 0.25, animations: {
                        fromView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                        moveView.frame = fromVC.imgViewFrame
                    }, completion: { (_) in
                        transitionContext.completeTransition(true)
                    })
                }
            }
        }
    }
    
    
}
