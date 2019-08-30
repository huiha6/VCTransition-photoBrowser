//
//  BrowserCollectionView.swift
//  GHPhotoBrowser
//
//  Created by Mac on 2019/1/23.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class GHBrowserCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = UIColor.black
        decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.9)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
