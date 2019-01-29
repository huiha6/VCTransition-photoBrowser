
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
//MARK: -
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

//MARK: - tableView/collectionView register/dequeue protocol
protocol ReusableView {
}
//Self不仅指代的是实现该协议的类型本身，也包括该类的子类
extension ReusableView where Self: UIView {
    static var reuseId: String {
        return String(describing: type(of: self))
    }
}
protocol NibLoadableView {
}
extension NibLoadableView where Self: UIView {
    static var NibName: String {
        return String(describing: type(of: self))
    }
}
extension UICollectionViewCell: ReusableView, NibLoadableView {
}
extension UICollectionView {
    func register(_ cellType: UICollectionViewCell.Type) {
        register(cellType.classForCoder(), forCellWithReuseIdentifier: cellType.reuseId)
    }
    func registerWithNib(_ cellType: UICollectionViewCell.Type) {
        register(UINib(nibName: cellType.NibName, bundle: nil), forCellWithReuseIdentifier: cellType.reuseId)
    }
    func dequeueTheReusableCell(_ cellType: UICollectionViewCell.Type, _ indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath)
    }
}
extension UITableViewCell: ReusableView, NibLoadableView {
}
extension UITableView {
    func register(_ cellType: UITableViewCell.Type) {
        register(cellType.classForCoder(), forCellReuseIdentifier: cellType.reuseId)
    }
    func registerWithNib(_ cellType: UITableViewCell.Type) {
        register(UINib(nibName: cellType.NibName, bundle: nil), forCellReuseIdentifier: cellType.reuseId)
    }
    func dequeueTheReusableCell(_ cellType: UITableViewCell.Type, _ indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: cellType.reuseId, for: indexPath)
    }
//    func ss(_ cellClass: AnyClass) {
//        register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellReuseIdentifier: cellClass.re)
//    }
}
