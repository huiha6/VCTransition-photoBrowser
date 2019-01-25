//
//  PhotoBrowserView.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class PhotoBrowserView: UIScrollView, UIScrollViewDelegate {
    enum PanScaleDirection {
        case unKnown, up, down, upDown
    }
    var panScaleDirection: PanScaleDirection = .unKnown
    weak var panDelegate: PanPhotoDelegate?
    var panEndPoint = CGPoint.zero
    var panDelegateEnable = false
    var panShouldBeganPoint = CGPoint.zero
    
    var tapDismissClosure: (()->Void)?
    
    var orgImgViewSize = CGSize.zero
    var orgImgViewCenter = CGPoint.zero

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentInsetAdjustmentBehavior = .never
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
            panDelegateEnable = false
            //v<=1.0 拖动方向与纵轴角度小于等于45度
            var v: CGFloat = 1.1//设置初始值大于45度
            if locationPoint.x > panShouldBeganPoint.x {//左滑
                print("左滑")
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = panShouldBeganPoint.y - locationPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 1.0 {
                        panScaleDirection = .down
                    }
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 1.0 {
                        panScaleDirection = .up
                    }
                }else{
                    
                }
            }else if locationPoint.x < panShouldBeganPoint.x {//右滑
                print("右滑")
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                    let offsetX = panShouldBeganPoint.x - locationPoint.x
                    let offsetY = panShouldBeganPoint.y - locationPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 1.0 {
                        panScaleDirection = .down
                    }
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = panShouldBeganPoint.x - locationPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 1.0 {
                        panScaleDirection = .up
                    }
                }else{
                    
                }
            }else {//绝对上下滑动
                v = 0
//                if locationPoint.y < panShouldBeganPoint.y {
//                    print("向下")
//                    panScaleDirection = .down
//                }else if locationPoint.y > panShouldBeganPoint.y {
//                    print("向上")
//                    panScaleDirection = .up
//                }else{
//                }
                panScaleDirection = .upDown
            }
            //contentOffset.y <= 0.0 拖动时scrollView在顶部无偏移
            //(bounds.height + contentOffset.y >= contentSize.height) 拖动时scrollView在底部无偏移
            if ((contentOffset.y <= 0.0) && panScaleDirection == .down) || ((bounds.height + contentOffset.y >= contentSize.height) && panScaleDirection == .up) || (((contentOffset.y <= 0.0) || (bounds.height + contentOffset.y >= contentSize.height)) && panScaleDirection == .upDown) {
                panDelegateEnable = true
            }
            if panDelegateEnable {
                panDelegate?.panBegan(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            panScaleDirection = .unKnown
            break
        case .changed:
            if panDelegateEnable {
                panDelegate?.panChanged(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            break
        case .cancelled, .ended:
            if panDelegateEnable {
                panDelegateEnable = false
                panDelegate?.panCancelledOfEnded()
            }
            panEndPoint = locationPoint
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
        let x = imgView.center.x - scrollView.contentOffset.x
        let y = imgView.center.y - scrollView.contentOffset.y
        orgImgViewSize = imgView.frame.size
        orgImgViewCenter = CGPoint(x: x, y: y)
    }
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
