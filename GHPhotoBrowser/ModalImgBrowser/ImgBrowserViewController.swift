//
//  ImgBrowserViewController.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/17.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class ImgBrowserViewController: UIViewController {
    var imgBrowserTransitionDelegate = ImgBrowserTransitionDelegate()

    var imgViewFrame = CGRect.zero
    var maxOffsetH = kScreenHeight/2
    let minImgViewWidth: CGFloat = 80
    var beganPanPoint = CGPoint.zero
    var orgPoint = CGPoint.zero
    enum PanDirectionType {
        case unKnown, up, down
    }
    //刚开始拖动方向
    var panDirection: PanDirectionType = .unKnown
    var offsetH: CGFloat = 0.0
    var isTapDismiss = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(pan)
        view.addSubview(browserView)
        view.addSubview(moveView)
        moveView.frame = imgViewFrame
    }
    
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let locationPoint = gesture.location(in: view)
        switch gesture.state {
        case .began:
            orgPoint = locationPoint
            offsetH = 0.0
            beganPanPoint = locationPoint
            moveView.frame.size = browserView.orgImgViewSize
            moveView.center = browserView.orgImgViewCenter
            moveView.isHidden = false
            browserView.imgView.isHidden = true
            
            imgBrowserTransitionDelegate = transitioningDelegate as! ImgBrowserTransitionDelegate
            imgBrowserTransitionDelegate.interactive = true

            dismiss(animated: true) {
            }
            break
        case .changed:
            let offsetY = locationPoint.y - orgPoint.y
            if offsetY > 0 {//向下拖
                if panDirection == .unKnown {
                    panDirection = .down
                }
                if panDirection == .down {
                    offsetH += abs(offsetY)
                }else if panDirection == .up {
                    offsetH -= abs(offsetY)
                    if moveView.frame.width >= browserView.orgImgViewSize.width {
                        panDirection = .down
                    }
                }
            }else{//向上拖
                if panDirection == .unKnown {
                    panDirection = .up
                }
                if panDirection == .up {
                    offsetH += abs(offsetY)
                }else if panDirection == .down {
                    offsetH -= abs(offsetY)
                    if moveView.frame.width >= browserView.orgImgViewSize.width {
                        panDirection = .up
                    }
                }
            }
            let w = browserView.orgImgViewSize.width - (browserView.orgImgViewSize.width - minImgViewWidth)*(min(offsetH, maxOffsetH) / maxOffsetH)
            let imgSize = browserView.orgImgViewSize
            let h = ((imgSize.height)/(imgSize.width))*w
            moveView.frame.size = CGSize(width: w, height: h)
            
            let centerX = (browserView.orgImgViewCenter.x - beganPanPoint.x)/browserView.orgImgViewSize.width*w + locationPoint.x
            let centerY = (browserView.orgImgViewCenter.y - beganPanPoint.y)/browserView.orgImgViewSize.height*h + locationPoint.y
            moveView.center = CGPoint(x: centerX, y: centerY)
            
            orgPoint = locationPoint
            let percent = min(offsetH, maxOffsetH) / maxOffsetH
            imgBrowserTransitionDelegate.interactionController.update(percent)
            break
        case .cancelled, .ended:
            panDirection = .unKnown
            let percent = min(offsetH, maxOffsetH) / maxOffsetH
            if percent > 0.15 {
                imgBrowserTransitionDelegate.interactionController.finish()
            }else{
                imgBrowserTransitionDelegate.interactionController.cancel()
            }
            imgBrowserTransitionDelegate.interactive = false
            break
        default:
            break
        }
    }

    //MARK: - lazy load    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return pan
    }()
    var image: UIImage? {
        didSet {
            browserView.image = image
            moveView.image = image
        }
    }
    lazy var moveView: UIImageView = {
        let v = UIImageView(frame: CGRect.zero)
        return v
    }()
    lazy var browserView: BrowserView = {
        let bv = BrowserView(frame: view.bounds)
        bv.tapDismissClosure = {[weak self] in
            self?.isTapDismiss = true
            self?.moveView.frame.size = (self?.browserView.orgImgViewSize)!
            self?.moveView.center = (self?.browserView.orgImgViewCenter)!
            self?.moveView.isHidden = false
            self?.browserView.imgView.isHidden = true
            self?.dismiss(animated: true) {
            }
        }
        return bv
    }()
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
    //            let v = tan(offsetY/offsetX)
    //            if v <= 1.0 {//45度
    //                isPanEnable = true
    //                print("------------------- panEnable")
    //            }else{
    //                isPanEnable = false
    //                print("===================  no panEnable")
    //            }
}

