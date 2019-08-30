//
//  PhotoBroserViewController.swift
//  GHPhotoBrowser
//
//  Created by Mac on 2019/1/21.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

public class GHPhotoBroserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgAry.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = browserCollectionView.dequeueReusableCell(withReuseIdentifier: "GHBrowserCollectionViewCellID", for: indexPath) as! GHBrowserCollectionViewCell
        cell.browserView.panDelegate = self
        cell.tapDismissClosure = {[weak self] in
            self?.transitionContainerView?.window?.windowLevel = UIWindow.Level(rawValue: 0)
            self?.dismiss(animated: true, completion: {
            })
        }
        cell.image = imgAry[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        print(indexPath.item)
        let theCell = cell as! GHBrowserCollectionViewCell
        theCell.browserView.setZoomScale(1.0, animated: false)
    }
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }

    let photoBrowserTransitionDelegate = GHPhotoBrowserTransitionDelegate()
    
    private let lineSpace: CGFloat = 20
    var imgViewFrameAry = [CGRect]()
    var currentPage: Int = 0
    var imgAry = [UIImage]()
    
    public func show(_ presentingVC: UIViewController, _ currentIndex: Int = 0, _ imageArray: [UIImage], _ imgFrameArray: [CGRect]) {
        imgAry = Array(imageArray)
        imgViewFrameAry.removeAll()
        imgFrameArray.forEach { (frame) in
             let theFrame = presentingVC.view.convert(frame, to: UIApplication.shared.keyWindow)
            self.imgViewFrameAry.append(theFrame)
        }
        currentPage = currentIndex
        transitioningDelegate = photoBrowserTransitionDelegate
        modalPresentationStyle = .custom
        presentingVC.present(self, animated: true, completion: {
        })
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        setupUI()
    }
    private func setupUI() {
        view.addSubview(browserCollectionView)
        view.addSubview(pageControl)
        view.addSubview(moveView)
        view.addGestureRecognizer(pan)
        pageControl.currentPage = currentPage
        moveView.frame = imgViewFrameAry[currentPage]
        moveView.image = imgAry[currentPage]
        let targetOffset = CGFloat(currentPage) * (screenWidth+lineSpace)
        browserCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
    }
    
    //MARK: - lazy load
    lazy var browserCollectionView: GHBrowserCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: screenWidth + lineSpace, height: screenHeight)
        //        let flowLayout = GHPhotoBrowserLayout()
        let collectionView = GHBrowserCollectionView(frame: CGRect(x: 0 - lineSpace*0.5, y: 0, width: screenWidth + lineSpace, height: screenHeight), collectionViewLayout: flowLayout)
        collectionView.register(GHBrowserCollectionViewCell.self, forCellWithReuseIdentifier: "GHBrowserCollectionViewCellID")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.contentSize = CGSize(width: screenWidth + lineSpace, height: screenHeight)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    lazy var pageControl: UIPageControl = {
        let pageC = UIPageControl(frame: CGRect(x: (view.frame.width - 200)/2, y: view.frame.height - 80, width: 200, height: 30))
        pageC.currentPage = currentPage
        pageC.isEnabled = false
        pageC.alpha = imgAry.count > 1 ? 1.0 : 0.0
        pageC.numberOfPages = imgAry.count
        return pageC
    }()
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return pan
    }()
    //moveView作为转场时图片操作替代对象
    lazy var moveView: UIImageView = {
        let v = UIImageView(frame: CGRect.zero)
        return v
    }()

    //MARK: - 拖动相关计算存储属性
    enum PanDirectionType {
        case unKnown, up, down
    }
    private let maxOffsetH = UIScreen.main.bounds.size.height*0.5
    private let minImgViewWidth: CGFloat = 80
    private var beganPanPoint = CGPoint.zero
    private var orgPoint = CGPoint.zero
    //刚开始拖动方向
    var panDirection: PanDirectionType = .unKnown
    private var offsetH: CGFloat = 0.0
    //拖动时取消
    private var isCancelTransition = false
    weak var animatorCoordinator: GHPhotoBrowserMaskController?
    var transitionContainerView: UIView?
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
    
    /*
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgAry.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GHBrowserCollectionViewCellID", for: indexPath) as! GHBrowserCollectionViewCell
        collectionView.dequeueReusableCell(withReuseIdentifier: "GHBrowserCollectionViewCellID", for: indexPath) as! GHBrowserCollectionViewCell
        cell.browserView.panDelegate = self
        cell.tapDismissClosure = {[weak self] in
            self?.transitionContainerView?.window?.windowLevel = UIWindow.Level(rawValue: 0)
            self?.dismiss(animated: true, completion: {
            })
        }
        cell.image = imgAry[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        print(indexPath.item)
        let theCell = cell as! GHBrowserCollectionViewCell
        theCell.browserView.setZoomScale(1.0, animated: false)
    }
    */
    
    //MARK: - scrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetWidth = scrollView.contentOffset.x
        offsetWidth = offsetWidth + (screenWidth + lineSpace)*0.5
        let currentIndex = Int(offsetWidth / (screenWidth + lineSpace))
        if currentIndex < imgAry.count && currentIndex != currentPage {
            currentPage = currentIndex
            print("========== index= \(currentPage)")
            pageControl.currentPage = currentPage
        }
    }
}

extension GHPhotoBroserViewController: GHPanPhotoDelegate {
    func panBegan(_ locationPoint: CGPoint) {
        let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! GHBrowserCollectionViewCell
        let browserView = cell.browserView
        
        orgPoint = locationPoint
        offsetH = 0.0
        beganPanPoint = locationPoint
        
        moveView.frame.size = browserView.orgImgViewSize
        moveView.center = browserView.orgImgViewCenter
        moveView.image = imgAry[currentPage]
        moveView.isHidden = false
        browserCollectionView.isHidden = true
        pageControl.isHidden = true
        
        transitionContainerView?.window?.windowLevel = UIWindow.Level(rawValue: 0)
    }
    
    func panChanged(_ locationPoint: CGPoint) {
        let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! GHBrowserCollectionViewCell
        let browserView = cell.browserView
        
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
        //拖动时图片的宽高按比例缩放
        let w = browserView.orgImgViewSize.width - (browserView.orgImgViewSize.width - minImgViewWidth)*(min(offsetH, maxOffsetH) / maxOffsetH)
        let imgSize = browserView.orgImgViewSize
        let h = ((imgSize.height)/(imgSize.width))*w
        moveView.frame.size = CGSize(width: w, height: h)
        //拖动时手指拖动点与图片中心点的距离与宽高变化关系
        let centerX = (browserView.orgImgViewCenter.x - beganPanPoint.x)/browserView.orgImgViewSize.width*w + locationPoint.x
        let centerY = (browserView.orgImgViewCenter.y - beganPanPoint.y)/browserView.orgImgViewSize.height*h + locationPoint.y
        moveView.center = CGPoint(x: centerX, y: centerY)
        //松手的时候往反方向扫动  则放弃dismiss转场
        if offsetY > 0 {//向下拖
            if panDirection == .down {
                isCancelTransition = false
            }else{
                isCancelTransition = true
            }
        }else{//向上拖
            if panDirection == .up {
                isCancelTransition = false
            }else{
                isCancelTransition = true
            }
        }

        orgPoint = locationPoint
        let percent = min(offsetH, maxOffsetH) / maxOffsetH
//        print(percent)
        animatorCoordinator?.maskView.backgroundColor = UIColor.black.withAlphaComponent(1.0 - percent)
    }
    
    func panCancelledOfEnded() {
        let percent = min(offsetH, maxOffsetH) / maxOffsetH
        if percent > 0.1 {
            if isCancelTransition {
                transitionContainerView?.window?.windowLevel = UIWindow.Level.statusBar + 1
                self.browserCollectionView.isHidden = false
                self.moveView.isHidden = true
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                    self.animatorCoordinator?.maskView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
                }) { (_) in
                    self.pageControl.isHidden = false
                }
            }else{
                transitionContainerView?.window?.windowLevel = UIWindow.Level(rawValue: 0)
                dismiss(animated: true) {
                    
                }
            }
        }else{
            transitionContainerView?.window?.windowLevel = UIWindow.Level.statusBar + 1
            self.browserCollectionView.isHidden = false
            self.moveView.isHidden = true
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.animatorCoordinator?.maskView.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            }) { (_) in
                self.pageControl.isHidden = false
            }
        }
        panDirection = .unKnown
    }
    
    @objc private func panAction(gesture: UIPanGestureRecognizer) {
        let locationPoint = gesture.location(in: view)
        switch gesture.state {
        case .began:
            panBegan(locationPoint)
            break
        case .changed:
            panChanged(locationPoint)
            break
        case .cancelled, .ended:
            panCancelledOfEnded()
            break
        default:
            break
        }
    }
}

//自定义flowlayout  对于collectionView  cell布局特殊要求的可以尝试自定义
//class GHPhotoBrowserLayout: UICollectionViewLayout {
//    override var collectionViewContentSize: CGSize {
//        let width = (collectionView?.bounds.width)! * 3 + 40*2
//        let height = collectionView?.bounds.height
//        return CGSize(width: width, height: height!)
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var attributesArray = [UICollectionViewLayoutAttributes]()
//        let cellCount = collectionView?.numberOfItems(inSection: 0) ?? 0
//        for i in 0..<cellCount {
//            let indexPath = IndexPath(item: i, section: 0)
//            let attributes = layoutAttributesForItem(at: indexPath)
//            attributesArray.append(attributes!)
//        }
//        return attributesArray
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        attributes.frame = CGRect(x: (collectionView?.bounds.width)!*CGFloat(indexPath.item) + CGFloat(40*indexPath.item), y: 0, width: (collectionView?.bounds.width)!, height: (collectionView?.bounds.height)!)
//        return attributes
//    }
//}
