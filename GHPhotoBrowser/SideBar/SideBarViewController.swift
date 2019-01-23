//
//  ModalViewController.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/16.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class SideBarViewController: UIViewController {

    var modalTransitionDelegate = SideBarTransitionDelegate()
    
    lazy var btn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 30))
        btn.setTitle("btnClick", for: .normal)
        btn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        return btn
    }()
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return pan
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blue
        view.addSubview(btn)
        view.addGestureRecognizer(pan)
    }
    
    @objc func clickAction() {
        dismiss(animated: true) {
        }
    }
    
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let transitionPoint = gesture.translation(in: view)
        if transitionPoint.x < 0 {
            print(transitionPoint.x)
            let percent = abs(transitionPoint.x) / view.bounds.width
            switch gesture.state {
            case .began:
                modalTransitionDelegate = transitioningDelegate as! SideBarTransitionDelegate
                modalTransitionDelegate.interactive = true
                dismiss(animated: true) {
                }
            case .changed:
                modalTransitionDelegate.interactionController.update(percent)
            case .cancelled, .ended:
                if percent > 0.3 {
                    modalTransitionDelegate.interactionController.finish()
                }else{
                    modalTransitionDelegate.interactionController.cancel()
                }
                modalTransitionDelegate.interactive = false
            default:
                break
            }
        }
    }

    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }

}
