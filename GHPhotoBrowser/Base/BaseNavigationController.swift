//
//  BaseNavigationController.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/14.
//  Copyright © 2019 gh. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if (self.viewControllers.count != 0) {
            let tabbarVC : MainTabbarController = self.tabBarController as! MainTabbarController
//            tabbarVC.hideTabbar(hidden: true, animated: true)
            tabbarVC.tabBar.hideTabbar(hidden: true)
        }
        super.pushViewController(viewController, animated: animated)
    }
}
