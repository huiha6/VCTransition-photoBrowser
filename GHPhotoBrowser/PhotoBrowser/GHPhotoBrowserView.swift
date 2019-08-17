//
//  PhotoBrowserView.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/22.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class GHPhotoBrowserView: UIScrollView, UIScrollViewDelegate {
    
    weak var panDelegate: GHPanPhotoDelegate?
    private var panDelegateEnable = false
    //开始拖拽时是否在顶部
    private var beginDraggingIsTop = false
    //开始拖拽时是否在底部
    private var beginDraggingIsBottom = false
    private var panShouldBeganPoint = CGPoint.zero
    
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
            let w = kScreenWidth
            let h = size.height/size.width*w
            var y: CGFloat = 0
            if h < kScreenHeight {
                y = (kScreenHeight-h)/2
            }
            theFrame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: w, height: h))
        }
        return theFrame
    }
    
    var image: UIImage? {
        didSet {
            if image != nil {
                imgView.image = image
                let size = image!.size
                let theFrame = GHPhotoBrowserView.getImgViewFrame(size)
                imgView.frame = theFrame
                orgImgViewSize = imgView.frame.size
                orgImgViewCenter = imgView.center
                if size.width >= size.height  {
                    contentSize = CGSize(width: frame.size.width, height: frame.size.height)
                }else{
                    contentSize = CGSize(width: theFrame.size.width, height: theFrame.size.height)
                }
            }
        }
    }
    //browserImageView
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect.zero)
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
    
    //MARK: - method action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let locationPoint = gesture.location(in: self)
        //        print("pan-----------------pan= \(locationPoint)")
        switch gesture.state {
        case .began:
            panShouldBeganPoint = locationPoint
        case .changed:
            if beginDraggingIsTop && contentOffset.y < 0 && panShouldBeganPoint.y < locationPoint.y {
                if panDelegateEnable == false {
                    panDelegateEnable = true
                    panDelegate?.panBegan(convert(locationPoint, to: UIApplication.shared.keyWindow))
                }else{
                    panDelegate?.panChanged(convert(locationPoint, to: UIApplication.shared.keyWindow))
                }
            }else if beginDraggingIsBottom && contentOffset.y + bounds.height > contentSize.height && panShouldBeganPoint.y > locationPoint.y {
                if panDelegateEnable == false {
                    panDelegateEnable = true
                    panDelegate?.panBegan(convert(locationPoint, to: UIApplication.shared.keyWindow))
                }else{
                    panDelegate?.panChanged(convert(locationPoint, to: UIApplication.shared.keyWindow))
                }
            }
        case .cancelled, .ended:
            if panDelegateEnable {
                panDelegateEnable = false
                panDelegate?.panCancelledOfEnded()
            }
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
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("didEndZooming = \(scrollView.contentOffset)")
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("-----begin dragging = \(scrollView.contentOffset)")
        if scrollView.contentOffset.y == 0 {
            beginDraggingIsTop = true
        }else{
            beginDraggingIsTop = false
        }
        if Int(scrollView.contentOffset.y + bounds.height) == Int(contentSize.height) {
            beginDraggingIsBottom = true
        }else{
            beginDraggingIsBottom = false
        }
    }
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
