//
//  MainTabbarController.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/15.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    private var subViewControllerCount: Int{
        let count = viewControllers != nil ? viewControllers!.count : 0
        return count
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.yellow
        
    }
    func hideTabbar(hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            if hidden {
                var frame = self.tabBar.frame
                frame.origin.y = kScreenHeight
                self.tabBar.frame = frame
            } else {
                var frame = self.tabBar.frame
                frame.origin.y = kScreenHeight - kTabBarH
                self.tabBar.frame = frame
            }
        }
    }
    

}
