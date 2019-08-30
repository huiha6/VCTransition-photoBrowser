//
//  ViewController.swift
//  GHPhotoBrowser
//
//  Created by jinjin on 2019/1/19.
//  Copyright © 2019年 jinjin. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    ///////////图片浏览模态转场
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect(x: 200, y: 200, width: 50, height: 50))
        let image = UIImage(named: "test")
        imgV.image = image
        let size = image?.size
        if CGFloat((size?.width)!) >= CGFloat((size?.height)!) {
            let h = ((size?.height)!/(size?.width)!)*imgV.frame.width
            imgV.frame = CGRect(x: 200, y: 200, width: imgV.frame.width, height: h)
        }else{
            
        }
        return imgV
    }()
    //单张图片
    let imgBrowserTransitionDelegate = ImgBrowserTransitionDelegate()
    /////////////
    
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        return tap
    }()

    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    
    
    /////////// 模态转场  实现侧边栏抽屉
    let modalTransitionDelegate = SideBarTransitionDelegate()
    lazy var edgePan: UIScreenEdgePanGestureRecognizer = {
        let edge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanAction))
        edge.edges = .left
        return edge
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imgView)
        
        view.addGestureRecognizer(edgePan)
        view.addGestureRecognizer(tap)
    }

    //MARK: - 左边缘右滑-侧边栏
    @objc func edgePanAction(gesture: UIScreenEdgePanGestureRecognizer) {
        let transitionPoint = gesture.translation(in: view)
        let percent = transitionPoint.x / view.bounds.width
//        print("\(transitionPoint.x) ---- \(percent)")
        switch gesture.state {
        case .began:
            let vc = SideBarViewController()
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = modalTransitionDelegate
            modalTransitionDelegate.interactive = true
            present(vc, animated: true) {
            }
        case .changed:
            modalTransitionDelegate.interactionController.update(percent)
        case .cancelled, .ended:
            if percent < 0.2 {
                modalTransitionDelegate.interactionController.cancel()
            }else {
                modalTransitionDelegate.interactionController.finish()
            }
            modalTransitionDelegate.interactive = false
        default:
            break
        }
    }
    //MARK: - 图片浏览转场
    @objc func tapAction(gesture: UITapGestureRecognizer) {
//        let point = gesture.location(in: view)
        /* note 初试
         单张图片的 尝试
         *///
        /*
        if imgView.frame.contains(point!) {
            let vc = ImgBrowserViewController()
            let frame = view.convert(imgView.frame, to: UIApplication.shared.keyWindow)
            vc.imgViewFrame = frame
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = imgBrowserTransitionDelegate
            present(vc, animated: true) {
                
            }
            vc.image = imgView.image
        }
         */

        /* note  初试后的多图尝试
         多张图片的尝试   包括宽大于高的图片、高大于宽的图片，没有长图(即 在没放大的模式下可上下滑动的长图)
         *///
//        let vc = GHPhotoBroserViewController()
//        let imgAry = [UIImage(named: "test"), UIImage(named: "test1"), UIImage(named: "test2"), UIImage(named: "test3")] as! [UIImage]
//        let imgViewFrameAry = [imgView.frame, imgView1.frame, imgView2.frame, imgView3.frame]
//        vc.show(self, 2, imgAry, imgViewFrameAry)//Int(arc4random_uniform(4))
    }

}

