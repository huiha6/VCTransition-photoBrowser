//
//  PhotoBrowserView.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class GHPhotoBrowserView: UIScrollView, UIScrollViewDelegate {
    enum PanScaleDirection {
        case unKnown, up, down, upDown
    }
    private var panScaleDirection: PanScaleDirection = .unKnown
    weak var panDelegate: GHPanPhotoDelegate?
    private var panDelegateEnable = false
    private var panShouldBeganPoint = CGPoint.zero
    private var panShouldBeganContentOffset = CGPoint.zero
    
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
            let theFrame = GHPhotoBrowserView.getImgViewFrame(size!)
            imgView.frame = theFrame
            orgImgViewSize = imgView.frame.size
            orgImgViewCenter = imgView.center
        }
    }
    //browserImageView
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect.zero)
//        imgV.isUserInteractionEnabled = true
        return imgV
    }()
    private lazy var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        return tap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
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
        panShouldBeganContentOffset = contentOffset
        return true
    }
    //MARK: - method action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let locationPoint = gesture.location(in: self)
        //        print("pan-----------------pan= \(locationPoint)")
        switch gesture.state {
        case .began:
            panScaleDirection = .unKnown
            panDelegateEnable = false
            //v<=1.0 拖动方向与纵轴角度小于等于30度
            var v: CGFloat = 1.0//设置初始值大于30度
            if locationPoint.x > panShouldBeganPoint.x {//左滑
                print("左滑")
                if locationPoint.y < panShouldBeganPoint.y {
                    print("向下")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = panShouldBeganPoint.y - locationPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 0.6 {
                        panScaleDirection = .down
                    }
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = locationPoint.x - panShouldBeganPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 0.6 {
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
                    if v <= 0.6 {
                        panScaleDirection = .down
                    }
                }else if locationPoint.y > panShouldBeganPoint.y {
                    print("向上")
                    let offsetX = panShouldBeganPoint.x - locationPoint.x
                    let offsetY = locationPoint.y - panShouldBeganPoint.y
                    v = tan(offsetX/offsetY)
                    if v <= 0.6 {
                        panScaleDirection = .up
                    }
                }else{
                    
                }
            }else {//绝对上下滑动
                v = 0
                if locationPoint.y < panShouldBeganPoint.y {
                    panScaleDirection = .down
                }else if locationPoint.y > panShouldBeganPoint.y {
                    panScaleDirection = .up
                }else{
                    panScaleDirection = .upDown
                }
            }
            //panShouldBeganContentOffset == 0.0 拖动时scrollView在顶部无偏移
            //(bounds.height + panShouldBeganContentOffset == contentSize.height) 拖动时scrollView在底部无偏移
            if ((panShouldBeganContentOffset.y == 0.0) && panScaleDirection == .down) {
                panDelegateEnable = true
            }
            if ((bounds.height + panShouldBeganContentOffset.y == contentSize.height) && panScaleDirection == .up) {
                panDelegateEnable = true
            }
            if panDelegateEnable {
                panDelegate?.panBegan(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            break
        case .changed:
            if panScaleDirection == .upDown {
                if locationPoint.y < panShouldBeganPoint.y {
                    panScaleDirection = .up
                }else if locationPoint.y > panShouldBeganPoint.y {
                    panScaleDirection = .down
                }
                if ((panShouldBeganContentOffset.y == 0.0) && panScaleDirection == .down) {
                    panDelegateEnable = true
                }
                if ((bounds.height + panShouldBeganContentOffset.y == contentSize.height) && panScaleDirection == .up) {
                    panDelegateEnable = true
                }
            }
            if panDelegateEnable {
                panDelegate?.panChanged(convert(locationPoint, to: UIApplication.shared.keyWindow))
            }
            break
        case .cancelled, .ended:
            if panDelegateEnable {
                panDelegate?.panCancelledOfEnded()
            }
            break
        default:
            break
        }
    }
    
    @objc private func tapAction(gesture: UITapGestureRecognizer) {
        if let tempClosure = self.tapDismissClosure {
            tempClosure()
        }
    }
    @objc private func doubleTapAction(gesture: UITapGestureRecognizer) {
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
    private func zoomRectForScale(_ scale: CGFloat, _ center: CGPoint) -> CGRect {
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
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if panDelegateEnable {
            let targetPoint = targetContentOffset.pointee
            scrollView.setContentOffset(targetPoint, animated: false)
        }
    }
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
