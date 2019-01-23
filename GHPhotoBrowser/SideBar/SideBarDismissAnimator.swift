//
//  DismissAnimator.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/16.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

//dismiss模态转场动画
class SideBarDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        let fromView = fromVC?.view
        let toView = toVC?.view
        let containerView = transitionContext.containerView
        let frame = containerView.bounds
        //注意：dismiss时，toView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此toView消失不见，其他情况的模态转场可以 不受影响

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView?.frame = CGRect(x: -(kScreenWidth-100), y: frame.origin.y, width: kScreenWidth-100, height: frame.height)
            toView?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
