//
//  PhotoBrowserView.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class PhotoBrowserView: UIScrollView, UIScrollViewDelegate {
    
    weak var panDelegate: PanPhotoDelegate?
    var panDelegateEnable = false
    var panShouldBeganPoint = CGPoint.zero
    
    
    var tapDismissClosure: (()->Void)?
    
    /// 根据图片的尺寸计算得imgView的frame, 长图模式暂未有
    ///
    /// - Parameter imageSize: image的size
    /// - Returns: 计算的imgView的frame
    static func getImgViewFrame(_ imageSize: CGSize) -> CGRect {
        let size = imageSize
        var theFrame = CGRect.zero
        if size.width >= size.height {
            let h = (size.height/size.width)*kScreenWidth
            theFrame = CGRect(x: 0, y: (kScreenHeight-h)/2, width: kScreenWidth, height: h)
        }else{
            let w = (size.width/size.height)*kScreenHeight
            theFrame = CGRect(x: (kScreenWidth - w)/2, y: 0, width: w, height: kScreenHeight)
        }
        return theFrame
    }
    
    var image: UIImage? {
        didSet {
            imgView.image = image
            let size = image?.size
            let theFrame = PhotoBrowserView.getImgViewFrame(size!)
            imgView.frame = theFrame
            orgImgViewSize = imgView.frame.size
            orgImgViewCenter = imgView.center
        }
    }
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect.zero)
        imgV.isUserInteractionEnabled = true
        return imgV
    }()
    lazy var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        return tap
    }()
    
    var orgImgViewSize = CGSize.zero
    var orgImgViewCenter = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentSize = CGSize(width: frame.size.width, height: frame.size.height)
        minimumZoomScale = 1.0
        maximumZoomScale = 3.0
        delegate = self
        
        addSubview(imgView)
        
        addGestureRecognizer(doubleTap)
        addGestureRecognizer(tap)
        tap.require(toFail: doubleTap)
        
        
        panGestureRecognizer.addTarget(self, action: #selector(panAction))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        panShouldBeganPoint = gestureRecognizer.location(in: self)
        return true
    }
    //MARK: - method action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let locationPoint = gesture.location(in: self)
        print("pan-----------------pan= \(locationPoint)")
        
        switch gesture.state {
        case .began:
//            let offsetX = abs(locationPoint.x - panShouldBeganPoint.x)
//            let offsetY = abs(locationPoint.y - panShouldBeganPoint.y)
            var v: CGFloat = 1.1//v <= 1.0 小于等于45度
            
            if locationPoint.x > panShouldBeganPoint.x {//左滑
                print("左滑")
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = panShouldBeganPoint.y - locationPoint.y
                    v = tan(offsetX/offsetY)
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                }else{
                    
                }
            }else if locationPoint.x < panShouldBeganPoint.x {//右滑
                print("右滑")
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                    let offsetX = panShouldBeganPoint.x - locationPoint.x
                    let offsetY = panShouldBeganPoint.y - locationPoint.y
                    v = tan(offsetX/offsetY)
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = panShouldBeganPoint.x - locationPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                }else{
                    
                }
            }else {
                v = 0
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                }else{
                    
                }
            }
            
            
            if (contentOffset.y <= -20.0 || (bounds.height + contentOffset.y >= contentSize.height)) && v <= 1.0 {
                panDelegateEnable = true
                panDelegate?.panBegan(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            
            
            
//            let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! BrowserCollectionViewCell
//            let browserView = cell.browserView
            
//            orgPoint = locationPoint
//            offsetH = 0.0
//            beganPanPoint = locationPoint
//
//            moveView.frame.size = browserView.orgImgViewSize
//            moveView.center = browserView.orgImgViewCenter
//            moveView.image = imgAry[currentPage]
//            moveView.isHidden = false
//            browserCollectionView.isHidden = true
//            pageControl.isHidden = true
//
//            photoBrowserTransitionDelegate = transitioningDelegate as! PhotoBrowserTransitionDelegate
//            photoBrowserTransitionDelegate.interactive = true
//            dismiss(animated: true) {
//            }
            break
        case .changed:
            
            if panDelegateEnable {
                panDelegate?.panChanged(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            
            
            
//            let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! BrowserCollectionViewCell
//            let browserView = cell.browserView
//
//            let offsetY = locationPoint.y - orgPoint.y
//            if offsetY > 0 {//向下拖
//                if panDirection == .unKnown {
//                    panDirection = .down
//                }
//                if panDirection == .down {
//                    offsetH += abs(offsetY)
//                }else if panDirection == .up {
//                    offsetH -= abs(offsetY)
//                    if moveView.frame.width >= browserView.orgImgViewSize.width {
//                        panDirection = .down
//                    }
//                }
//            }else{//向上拖
//                if panDirection == .unKnown {
//                    panDirection = .up
//                }
//                if panDirection == .up {
//                    offsetH += abs(offsetY)
//                }else if panDirection == .down {
//                    offsetH -= abs(offsetY)
//                    if moveView.frame.width >= browserView.orgImgViewSize.width {
//                        panDirection = .up
//                    }
//                }
//            }
//            //拖动时图片的宽高按比例缩放
//            let w = browserView.orgImgViewSize.width - (browserView.orgImgViewSize.width - minImgViewWidth)*(min(offsetH, maxOffsetH) / maxOffsetH)
//            let imgSize = browserView.orgImgViewSize
//            let h = ((imgSize.height)/(imgSize.width))*w
//            moveView.frame.size = CGSize(width: w, height: h)
//            //拖动时手指拖动点与图片中心点的距离与宽高变化关系
//            let centerX = (browserView.orgImgViewCenter.x - beganPanPoint.x)/browserView.orgImgViewSize.width*w + locationPoint.x
//            let centerY = (browserView.orgImgViewCenter.y - beganPanPoint.y)/browserView.orgImgViewSize.height*h + locationPoint.y
//            moveView.center = CGPoint(x: centerX, y: centerY)
//
//            orgPoint = locationPoint
//            let percent = min(offsetH, maxOffsetH) / maxOffsetH
//            photoBrowserTransitionDelegate.interactionController.update(percent)
            break
        case .cancelled, .ended:
            if panDelegateEnable {
                panDelegateEnable = false
                panDelegate?.panCancelledOfEnded()
            }
//            panDirection = .unKnown
//            let percent = min(offsetH, maxOffsetH) / maxOffsetH
//            if percent > 0.15 {
//                photoBrowserTransitionDelegate.interactionController.finish()
//            }else{
//                photoBrowserTransitionDelegate.interactionController.cancel()
//            }
//            photoBrowserTransitionDelegate.interactive = false
            break
        default:
            break
        }
    }
    @objc func tapAction(gesture: UITapGestureRecognizer) {
        if let tempClosure = self.tapDismissClosure {
            tempClosure()
        }
    }
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        var scale = zoomScale
        if scale != 1.0 {
            setZoomScale(1.0, animated: true)
        }else{
            scale = 3.0
            let zoomRect = zoomRectForScale(scale, point)
            zoom(to: zoomRect, animated: true)
        }
    }
    /// 双击点进行放大
    ///
    /// - Parameters:
    ///   - scale: 放大倍数
    ///   - center: 双击点
    /// - Returns: 放大
    func zoomRectForScale(_ scale: CGFloat, _ center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width = frame.size.width / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    //MARK: - scrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {//缩放重点 捏合中心点缩放
        contentSize = CGSize(width: imgView.frame.size.width, height: imgView.frame.size.height)
        let offsetX = (frame.size.width > contentSize.width) ? (frame.size.width - contentSize.width)*0.5 : 0.0
        let offsetY = (frame.size.height > contentSize.height) ? (frame.size.height - contentSize.height)*0.5 : 0.0
        imgView.center = CGPoint(x: scrollView.contentSize.width*0.5 + offsetX, y: scrollView.contentSize.height*0.5 + offsetY)
        
        //        print("============== center= \(imgView.center)")
        let x = imgView.center.x - scrollView.contentOffset.x
        let y = imgView.center.y - scrollView.contentOffset.y
        orgImgViewSize = imgView.frame.size
        orgImgViewCenter = CGPoint(x: x, y: y)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        
//        if scrollView.contentOffset.x == 0 {
//            scrollView.isScrollEnabled = false
//        }
        
        
        let x = imgView.center.x - scrollView.contentOffset.x
        let y = imgView.center.y - scrollView.contentOffset.y
        orgImgViewSize = imgView.frame.size
        orgImgViewCenter = CGPoint(x: x, y: y)
    }
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        scrollView.isScrollEnabled = true
//    }
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
