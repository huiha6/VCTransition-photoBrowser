//
//  PresentAnimator.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/16.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

//present模态转场动画
class SideBarPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        let fromView = fromVC?.view
        let toView = toVC?.view
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        let frame = containerView.bounds
        toView?.frame = CGRect(x: -(kScreenWidth-100), y: frame.origin.y, width: kScreenWidth-100, height: frame.height)
        fromView?.frame = frame
        //注意：present时，fromView在 custom 情况下 不能添加到containerView上，否则会出现dismiss后此fromView消失不见，其他情况的模态转场可以 不受影响
        containerView.addSubview(toView!)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView?.frame = CGRect(x: kScreenWidth-100, y: frame.origin.y, width: frame.width, height: frame.height)
            toView?.frame = CGRect(x: 0, y: frame.origin.y, width: kScreenWidth-100, height: frame.height)
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
