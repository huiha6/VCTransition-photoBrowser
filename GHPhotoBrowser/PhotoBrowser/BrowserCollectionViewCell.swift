//
//  BrowserCollectionViewCell.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/21.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class BrowserCollectionViewCell: UICollectionViewCell {
    var tapDismissClosure: (()->Void)?

    lazy var browserView: PhotoBrowserView = {
        let bv = PhotoBrowserView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        bv.tapDismissClosure = {[weak self] in
            if let tempClosure = self?.tapDismissClosure {
                tempClosure()
            }
        }
        return bv
    }()
    
    var image: UIImage? {
        didSet {
            browserView.image = image
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(browserView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        browserView.setZoomScale(1.0, animated: false)
    }
    
    deinit {
        print("=========== deinit: \(self.classForCoder)")
    }
}
