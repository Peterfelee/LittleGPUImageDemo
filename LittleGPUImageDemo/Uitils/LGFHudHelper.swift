//
//  LGFHudHelper.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/4/1.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import MBProgressHUD

class LGFHudHelper: NSObject {
    
    private var hud:MBProgressHUD?
    private var showView :UIView?
    
    //显示时间
    private let showTime=1.0
    //单例方法
    @objc static let share=LGFHudHelper()
    
    ///对外的方法
    //添加到当前页面
    @objc public func showHud(text:String?,window:UIView?)
    {
        checkHud()
        if window != nil
        {
            showView=window!
        }
        else
        {
            showView=UIApplication.shared.keyWindow
        }
        hud=MBProgressHUD.showAdded(to: showView!, animated: true)
        //为了后面hidden的时候会自动移除和置空
        hud?.removeFromSuperViewOnHide=true
        hud?.backgroundColor = UIColor.clear
        if text != nil
        {
            hud?.label.text=text!
            hud?.label.numberOfLines = 0
            hud?.mode=MBProgressHUDMode.text
        }
        else
        {
            hud?.mode=MBProgressHUDMode.indeterminate
        }
        
    }
    ///纯菊花转
    @objc public  func showHud(window:UIView?)  {
        showHud(window: window, str: nil)
    }
    
    ///带有文字的菊花转
    @objc public  func showHud(window:UIView?,str:String?)  {
        checkHud()
        if window != nil
        {
            showView=window!
        }
        else
        {
            showView=UIApplication.shared.keyWindow
        }
        hud=MBProgressHUD.showAdded(to: showView!, animated: true)
        //为了后面hidden的时候会自动移除和置空
        hud?.removeFromSuperViewOnHide=true
        hud?.mode=MBProgressHUDMode.indeterminate
        if str != nil
        {
            hud?.label.text = str
        }
        hud?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.50)
    }
    
    
    //自动隐藏的 默认是1.0s
    @objc public func showAutoHud(text:String?)
    {
        showAutoHud(text: text, delay: showTime)
    }
    @objc public func showAutoHud(text:String?,delay:TimeInterval)
    {
        showHud(text: text, window: nil)
        dismiss(delay: delay)
    }
    @objc public func dismiss(delay:TimeInterval)
    {
        hud?.hide(animated: true, afterDelay: delay)
    }
    @objc public func dismiss()
    {
        dismiss(delay: 0)
    }
    ///检查是不是有hud，如果有就先销毁再加载
    private func checkHud()
    {
        if hud != nil
        {
            hud?.hide(animated: false)
        }
    }
    
    
}
