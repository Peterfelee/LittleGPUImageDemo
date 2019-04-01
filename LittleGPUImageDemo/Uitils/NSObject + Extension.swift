//
//  NSObject + Extension.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/4/1.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

extension  NSObject {
    ///获取当前控制器的导航栏 没有的话为nil
    func getNavgationController()->UINavigationController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        guard vc != nil else {
            return nil
        }
        
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        while (vc!.isKind(of: UINavigationController.classForCoder()))
        {
            vc = (vc as! UINavigationController).topViewController
        }
        while (vc!.isKind(of: UITabBarController.classForCoder()))
        {
            vc = (vc as! UITabBarController).selectedViewController
            vc = vc!.getNavgationController()
        }
        return vc!.navigationController
    }
    
    
    
    ///获取顶层控制器 没有的话为nil
    func getCurrentViewController() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        guard vc != nil else {
            return nil
        }
        while vc!.presentedViewController != nil
        {
            vc = vc!.presentedViewController
        }
        while (vc!.isKind(of: UINavigationController.classForCoder()))
        {
            vc = (vc as! UINavigationController).topViewController
        }
        while (vc!.isKind(of: UITabBarController.classForCoder()))
        {
            vc = (vc as! UITabBarController).selectedViewController
            vc = vc!.getCurrentViewController()
        }
        return vc
    }
    
}
