//
//  PhotoBroserViewController.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/21.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class PhotoBroserViewController: UIViewController {
    var photoBrowserTransitionDelegate = PhotoBrowserTransitionDelegate()
    
    let lineSpace: CGFloat = 20
    var imgViewFrameAry = [CGRect]()
    var currentPage: Int = 0
    var imgAry = [UIImage]()
    
    var presentingVC: UIViewController?
    public func show() {
        transitioningDelegate = photoBrowserTransitionDelegate
        modalPresentationStyle = .custom
        presentingVC?.present(self, animated: true, completion: {
            
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func setupUI() {
        view.addSubview(browserCollectionView)
        view.addSubview(pageControl)
        view.addSubview(moveView)
        view.addGestureRecognizer(pan)
        pageControl.currentPage = currentPage
        moveView.frame = imgViewFrameAry[currentPage]
        moveView.image = imgAry[currentPage]
        let targetOffset = CGFloat(currentPage) * (kScreenWidth+lineSpace)
        browserCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
    }
    //MARK: - action method
    
    //MARK: - lazy load
    lazy var browserCollectionView: BrowserCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = lineSpace//单元格cell间距
        flowLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
//        let flowLayout = GHPhotoBrowserLayout()
        let collectionView = BrowserCollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: flowLayout)
        collectionView.register(BrowserCollectionViewCell.self, forCellWithReuseIdentifier: "BrowserCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    lazy var pageControl: UIPageControl = {
        let pageC = UIPageControl(frame: CGRect(x: (view.frame.width - 200)/2, y: view.frame.height - 80, width: 200, height: 30))
        pageC.currentPage = currentPage
        pageC.isEnabled = false
        pageC.numberOfPages = imgAry.count
        return pageC
    }()
    
    lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return pan
    }()
    lazy var moveView: UIImageView = {
        let v = UIImageView(frame: CGRect.zero)
        return v
    }()

    //MARK: - 拖动相关计算存储属性
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
    var isCancelTransition = false
    

    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}

extension PhotoBroserViewController: PanPhotoDelegate {
    func panBegan(_ locationPoint: CGPoint) {
        let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! BrowserCollectionViewCell
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
        
        photoBrowserTransitionDelegate = transitioningDelegate as! PhotoBrowserTransitionDelegate
        photoBrowserTransitionDelegate.interactive = true
        dismiss(animated: true) {
        }
    }
    
    func panChanged(_ locationPoint: CGPoint) {
        let cell = browserCollectionView.cellForItem(at: IndexPath(item: currentPage, section: 0)) as! BrowserCollectionViewCell
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
        photoBrowserTransitionDelegate.interactionController.update(percent)
    }
    
    func panCancelledOfEnded() {
        let percent = min(offsetH, maxOffsetH) / maxOffsetH
        if percent > 0.4 {
            if isCancelTransition {
                photoBrowserTransitionDelegate.interactionController.cancel()
            }else{
                photoBrowserTransitionDelegate.interactionController.finish()
            }
        }else{
            photoBrowserTransitionDelegate.interactionController.cancel()
        }
        photoBrowserTransitionDelegate.interactive = false
        panDirection = .unKnown
    }
    
    @objc func panAction(gesture: UIPanGestureRecognizer) {
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

extension PhotoBroserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowserCollectionViewCell", for: indexPath) as! BrowserCollectionViewCell
        cell.browserView.panDelegate = self
        cell.tapDismissClosure = {[weak self] in
            self?.isTapDismiss = true
            self?.dismiss(animated: true, completion: {
            })
        }
        cell.image = imgAry[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print(indexPath.item)
        let theCell = cell as! BrowserCollectionViewCell
        theCell.browserView.setZoomScale(1.0, animated: false)
    }
    
    //MARK: - scrollViewDelegate
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth: CGFloat = kScreenWidth + lineSpace
        let currentOffset = scrollView.contentOffset.x
        let targetOffset = CGFloat(targetContentOffset.pointee.x)
        var newTargetOffset:CGFloat = 0.0
        
        if currentOffset < 0 {
            currentPage = 0
        }else if currentOffset > pageWidth*CGFloat(imgAry.count - 1) {
            currentPage = imgAry.count - 1
        }else{
//            print("+++++++++ \(targetOffset) ------ \(currentOffset)")
            if targetOffset > currentOffset {
                if currentOffset > pageWidth*CGFloat(currentPage) {
                    currentPage += 1
                }
            }else if targetOffset < currentOffset {
                if currentOffset < pageWidth*CGFloat(currentPage) {
                    currentPage -= 1
                }
            }else{
                let currentPageOffsetX = pageWidth*CGFloat(currentPage)
                if currentOffset > currentPageOffsetX {//向左滑
                    let offsetX = currentOffset - currentPageOffsetX
                    if (offsetX / kScreenWidth + 0.5) > 1.0 {
                        currentPage += 1
                    }
                }else{//向右滑
                    let offsetX = currentPageOffsetX - currentOffset
                    if (offsetX / kScreenWidth + 0.5) > 1.0 {
                        currentPage -= 1
                    }
                }
            }
        }
        newTargetOffset = CGFloat(currentPage) * pageWidth
        targetContentOffset.pointee = CGPoint(x: newTargetOffset, y: 0.0)
        pageControl.currentPage = currentPage
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
