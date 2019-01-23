
//
//  PublicConst.swift
//  VCTransition-Test
//
//  Created by Sansi Mac on 2019/1/15.
//  Copyright © 2019 gh. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Public length
let userDefaults = UserDefaults.standard
let kStatusBarH = UIApplication.shared.statusBarFrame.size.height //状态栏高度x:44
let kNavigationBarH = UINavigationController.init().navigationBar.frame.height  //导航栏Bar高度
let kNavigationH = (kStatusBarH + kNavigationBarH)                              //导航高度(导航栏+状态栏)
let kBottomArcH = kStatusBarH > 20.1 ? 34 : 0   //底部圆弧高度
let kTabBarH: CGFloat = CGFloat(kBottomArcH + 49)    //tabbar高度
let kScreenWidth = UIScreen.main.bounds.size.width                              //屏幕宽
let kScreenHeight = UIScreen.main.bounds.size.height                             //屏幕高
let kTextEnterViewNormalHeight: CGFloat = 79
let kWidthRatio = kScreenWidth/375
let kHeightRatio = kScreenHeight/667


extension UITabBar {
    func hideTabbar(hidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            if hidden {
                self.frame.origin.y = kScreenHeight
            } else {
                self.frame.origin.y = kScreenHeight - kTabBarH
            }
        }
    }
}

/* note
 - (UIViewController *)currentViewController
 {
 UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
 UIViewController *vc = keyWindow.rootViewController;
 while (vc.presentedViewController)
 {
 vc = vc.presentedViewController;
 
 if ([vc isKindOfClass:[UINavigationController class]])
 {
 vc = [(UINavigationController *)vc visibleViewController];
 }
 else if ([vc isKindOfClass:[UITabBarController class]])
 {
 vc = [(UITabBarController *)vc selectedViewController];
 }
 }
 return vc;
 }
 
 - (UINavigationController *)currentNavigationController
 {
 return [self currentViewController].navigationController;
 }
 */

/// 获取当前正要显示的视图控制器
///
/// - Returns: currentViewController
func currentViewController() -> UIViewController {
    let keyWindow = UIApplication.shared.keyWindow
    var vc = keyWindow?.rootViewController
    while ((vc?.presentedViewController) != nil) {
        let controller = vc?.presentedViewController
        if (controller?.isKind(of: UINavigationController.self))! {
            let navC = controller as! UINavigationController
            vc = navC.visibleViewController
        }else if (controller?.isKind(of: UITabBarController.self))! {
            let tabbarController = controller as! UITabBarController
            vc = tabbarController.selectedViewController
        }
    }
    return vc!
}
func currentNavigationController() -> UINavigationController {
    return currentViewController().navigationController!
}
