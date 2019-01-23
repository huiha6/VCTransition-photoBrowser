//
//  BrowserView.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/17.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class BrowserView: UIScrollView, UIScrollViewDelegate {
    var tapDismissClosure: (()->Void)?
    
    var image: UIImage? {
        didSet {
            imgView.image = image
            let size = image?.size
            if CGFloat((size?.width)!) >= CGFloat((size?.height)!) {
                let h = ((size?.height)!/(size?.width)!)*frame.width
                imgView.frame = CGRect(x: 0, y: (frame.height-h)/2, width: frame.width, height: h)
            }else{
                
            }
            orgImgViewSize = imgView.frame.size
            orgImgViewCenter = imgView.center
        }
    }
    lazy var imgView: UIImageView = {
        let imgV = UIImageView(frame: CGRect.zero)
        imgV.isUserInteractionEnabled = true
        return imgV
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        return tap
    }()
    lazy var doubleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        tap.numberOfTapsRequired = 2
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
        
        addGestureRecognizer(tap)
        addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction(gesture: UITapGestureRecognizer) {
        if let tempClosure = tapDismissClosure {
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
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        if contentOffset.y <= -20 {
//            return nil
//        }
////        if view == nil {
////            for subView in subviews {
////                let point = subView.convert(point, from: self)
////                if subView.bounds.contains(point) {
////                    return subView
////                }
////            }
////        }
//        return view
//    }
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
