//
//  BrowserCollectionView.swift
//  GHPhotoBrowser
//
//  Created by Sansi Mac on 2019/1/23.
//  Copyright © 2019 jinjin. All rights reserved.
//

import UIKit

class BrowserCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = UIColor.black
        decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.9)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
