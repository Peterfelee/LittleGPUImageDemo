//
//  UIKit + Extension.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/4/1.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

extension UIColor{
    @objc class func color(hexString:String?)->UIColor
    {
        return color(hexString: hexString, alpha: 1.0)
    }
    
    @objc class func color(hexString:String? , alpha:CGFloat)->UIColor
    {
        var colorString=""
        if hexString == nil||(hexString?.isEmpty)!
        {
            return UIColor.init(white: 0, alpha: 1)
        }
        else if (hexString?.contains("0x"))!
        {
            colorString = (hexString?.replacingOccurrences(of: "0x", with: ""))!
        }
        else if (hexString?.contains("#"))!
        {
            colorString = (hexString?.replacingOccurrences(of: "#", with: ""))!
        }
        colorString = colorString.uppercased()
        var  alphaValue = alpha , red = 0.0 , blue = 0.0 , green = 0.0
        
        switch (colorString as NSString).length {
        case 3: // #RGB
            red = colorComponentFrom(colorString: colorString, start: 0, length: 1)
            green = colorComponentFrom(colorString: colorString, start: 1, length: 1)
            blue = colorComponentFrom(colorString: colorString, start: 2, length: 1)
            break;
        case 4: // #ARGB
            alphaValue = CGFloat(colorComponentFrom(colorString: colorString, start: 0, length: 1))
            red = colorComponentFrom(colorString: colorString, start: 1, length: 1)
            green = colorComponentFrom(colorString: colorString, start: 2, length: 1)
            blue = colorComponentFrom(colorString: colorString, start: 3, length: 1)
        case 6: // #RRGGBB
            red = colorComponentFrom(colorString: colorString, start: 0, length: 2)
            green = colorComponentFrom(colorString: colorString, start: 2, length: 2)
            blue = colorComponentFrom(colorString: colorString, start: 4, length: 2)
        case 8: // #AARRGGBB
            alphaValue = CGFloat(colorComponentFrom(colorString: colorString, start: 0, length: 2))
            red = colorComponentFrom(colorString: colorString, start: 2, length: 2)
            green = colorComponentFrom(colorString: colorString, start: 4, length: 2)
            blue = colorComponentFrom(colorString: colorString, start: 6, length: 2)
        default:
            NSException.raise(NSExceptionName(rawValue: "Invalid color value"), format: "Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", arguments: getVaList([hexString!]))
        }
        
        return UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: alphaValue)
    }
    
    private class func colorComponentFrom(colorString:String?, start:Int,length:Int)->Double
    {
        if colorString == nil
        {
            return 1.0
        }
        let startIndex=colorString?.index((colorString?.startIndex)!, offsetBy: start)
        let endIndex=colorString?.index(startIndex!, offsetBy: length)
        let substring=colorString![startIndex!..<endIndex!]
        //        let substring=colorString?.substring(with: Range.init(NSMakeRange(start, length), in: colorString!)!)
        let fullHex=(length==2 ? substring : substring + substring)
        var hexComponent:UInt64=0
        Scanner(string: String(fullHex)).scanHexInt64(&hexComponent)
        return Double(hexComponent) / 255.0
    }
    
    @objc public class func color(hexValue:Int,alpha:CGFloat)->UIColor
    {
        return UIColor.init(red: CGFloat((hexValue & 0xFF0000) >> 16)/255.0, green: CGFloat((hexValue & 0xFF00) >> 8)/255.0, blue:CGFloat((hexValue & 0xFF))/255.0, alpha: alpha)
    }
    
    @objc public class func color(hexValue:Int)->UIColor
    {
        return UIColor.color(hexValue: hexValue, alpha: 1.0)
    }
}



extension UIView{
    ///当前view或者view的subclass的x 同时可以通过这个属性来赋值
    @objc var x:CGFloat{
        set{
            var temp=self.frame.origin
            temp.x=CGFloat(newValue)
            self.frame.origin=temp
        }
        get{
            return self.frame.minX
        }
    }
    ///当前view或者view的subclass的y 同时可以通过这个属性来赋值
    @objc var y:CGFloat{
        set{
            var temp=self.frame.origin
            temp.y=CGFloat(newValue)
            self.frame.origin=temp
        }
        get{
            return self.frame.minY
        }
    }
    ///当前view或者view的subclass的width 同时可以通过这个属性来赋值
    @objc var width:CGFloat{
        set{
            var temp=self.frame.size
            temp.width=CGFloat(newValue)
            self.frame.size=temp
        }
        get{
            return self.frame.width
        }
        
    }
    ///当前view或者view的subclass的height 同时可以通过这个属性来赋值
    @objc var height:CGFloat{
        set{
            var temp=self.frame.size
            temp.height=CGFloat(newValue)
            self.frame.size=temp
        }
        get{
            return self.frame.height
        }
    }
    ///当前view或者view的subclass的origin 同时可以通过这个属性来赋值
    @objc var origin:CGPoint{
        set{
            self.frame.origin=newValue
        }
        get{
            return self.frame.origin
        }
        
    }
    ///当前view或者view的subclass的size 同时可以通过这个属性来赋值
    @objc var size:CGSize{
        set{
            self.frame.size=newValue
        }
        get{
            return self.frame.size
        }
    }
    
    
    @objc func getSnapViewImage()->UIImage?{
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
}


extension UIImage{
    
    ///根据给定的颜色和尺寸绘制一个图片
    @objc class func drawImage(color:UIColor,size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let temp=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp!
    }
    
    ///根据颜色和直径绘制一个圆环
    @objc class func drawCycleImage(color:UIColor,diameter:CGFloat)->UIImage{
        
        // 开始图形上下文，NO代表透明
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0.0);
        
        // 获得图形上下文
        
        let ctx = UIGraphicsGetCurrentContext();
        
        // 设置一个范围
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        // 根据一个rect创建一个椭圆
        ctx?.addEllipse(in: rect)
        // 裁剪
        ctx?.clip()
        UIImage.drawImage(color: color, size: CGSize(width: diameter, height: diameter)).draw(in: rect)
        
        // 从上下文上获取剪裁后的照片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    ///根据指定渐变色范围绘制图片
    @objc class  func draw(fromColor:UIColor,toColor:UIColor,size:CGSize) -> UIImage {
        
        //创建CGContextRef
        UIGraphicsBeginImageContext(size)
        let context=UIGraphicsGetCurrentContext()
        //创建CGMutablePathRef
        let path=CGMutablePath.init()
        
        //绘制Path
        let rect=CGRect.init(x: 0, y: 0, width: size.width+1, height: size.height)
        path.move(to: CGPoint.init(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint.init(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint.init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint.init(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        //绘制渐变
        let colorSpace=CGColorSpaceCreateDeviceRGB()
        
        let locations:[CGFloat]=[0.0,1.0]
        let colors=[fromColor.cgColor,toColor.cgColor]
        let gradient=CGGradient.init(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        let pathRect=path.boundingBoxOfPath
        
        //具体方向可根据需求修改
        let startPoint = CGPoint.init(x: pathRect.minX, y: pathRect.midY)
        let endPoint = CGPoint.init(x: pathRect.maxX, y: pathRect.midY)
        context?.saveGState()
        context?.addPath(path)
        context?.clip()
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context?.restoreGState()
        
        //从Context中获取图像，并显示在界面上
        let image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

extension NSString{
    
    @objc class func createFile(name:String?)->String
    {
        
        if name == nil||name!.isEmpty
        {
            LGFHudHelper.share.showAutoHud(text: "文件名不能为空")
        }
        let fileName = name!
        let docsDir=NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let soudFileName=(docsDir! as NSString).appendingPathComponent(createFileName())
        var isDir=ObjCBool.init(false)
        let existed=FileManager.default.fileExists(atPath: soudFileName, isDirectory: &isDir)
        //如果有文件就删除
        if isDir.boolValue && existed
        {
            try?FileManager.default.removeItem(at: URL(fileURLWithPath: soudFileName))
        }
        try!FileManager.default.createDirectory(atPath: soudFileName, withIntermediateDirectories: true, attributes: nil)
        
        let soundFilePath=(soudFileName as NSString).appendingPathComponent("\(fileName)")
        return soundFilePath
    }
    private class func createFileName()->String
    {
        let dateFormmater=DateFormatter()
        dateFormmater.dateFormat="yyyy-MM-dd HH:mm:ss"
        return dateFormmater.string(from: Date())
    }
    
    
    
    @objc class func pathForRecordFile(fileName:String?) -> String {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        var recorderName = "default"
        if fileName != nil
        {
            recorderName = fileName!
        }
        let recorderPath = dirPath.appendingPathComponent(recorderName)
        if FileManager.default.fileExists(atPath: recorderPath) && recorderPath.contains(".mp4")
        {
            try?FileManager.default.removeItem(atPath: recorderPath)
        }
        NSLog("%@",recorderPath)
        return recorderPath
    }
    
    @objc class func mutublePathForRecordFile(fileName:String?) -> String {
        
        let recorderPath = createFile(name: fileName)
        NSLog("%@",recorderPath)
        return recorderPath
    }
}
