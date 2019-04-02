//
//  LGFScaleImageViewController.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/4/1.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import CoreGraphics
//import GPUImage
import GPUImage

class LGFScaleImageViewController: UIViewController {
    
    private var backButton:UIButton!
    private var showView:UIImageView!
    private var testImage:UIImage = UIImage(named: "WID-small.jpg")!
//    var bliater:ZoomBlur BilateralBlur!
    var detect:CIDetector!
    var pictureInput:PictureInput!
    var pictureOutput:PictureOutput!
    var brightess:BrightnessAdjustment!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        title = "合成效果"
        // Do any additional setup after loading the view.
        addViews()
        
        let param:[String:Any] = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let context:CIContext = CIContext(options: nil)
        detect = CIDetector(ofType: CIDetectorTypeFace, context:context , options: param)
        
    }
    
    private func addViews()
    {
        backButton = UIButton(frame: CGRect(x: 10, y: 25, width: 60, height: 30))
        view.addSubview(backButton)
        backButton.setTitle("back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick(button:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.darkGray, for: .normal)
        
        
        let showViewWidth:CGFloat = 150
        let showViewHeight:CGFloat = 150
        
        showView = UIImageView(frame: CGRect(x: self.view.frame.width/2 - showViewWidth/2, y: self.view.frame.height/2.0 - showViewHeight/2 , width:showViewWidth, height: showViewHeight))
        showView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(showView)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        showView.isUserInteractionEnabled = true
        showView.addGestureRecognizer(tap)
        
        
        let sel = #selector(nextButtonClick)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: sel)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "detect", style: .plain, target: self, action: #selector(detectButtonClick))
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        processImage()
    }
   
    
    private func processImage()
    {
        if pictureInput != nil
        {
            pictureInput.removeAllTargets()
            pictureOutput.removeSourceAtIndex(0)
        }
        pictureInput = PictureInput(image: testImage)
        pictureOutput = PictureOutput()
//        bliater = BilateralBlur()
//        bliater.distanceNormalizationFactor = 1.5
        
        brightess = BrightnessAdjustment()
        brightess.brightness = 0.2
        
        pictureInput --> brightess --> pictureOutput
        pictureInput.processImage()
        
        pictureOutput.imageAvailableCallback = {[weak self](image) in
            DispatchQueue.main.async {
                self?.showView.image = image
            }
        }
        
    }
    
    @objc private func backButtonClick(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LGFScaleImageViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @objc private func tapClick()
    {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {[weak self] in
            DispatchQueue.main.async {
                if let image = info[UIImagePickerController.InfoKey.originalImage]
                {
                    self?.testImage = (self?.fixOriention(image: image as! UIImage))!
                    self?.processImage()
                }
            }
        }
    }
    
    
    @objc private func nextButtonClick()
    {
        self.navigationController?.pushViewController(LGFCaremViewController(), animated: true)
    }
    
    @objc private func detectButtonClick()
    {
        let ciimage = CIImage.init(image: testImage)
        let detectArray = detect.features(in: ciimage!)
        let firstImage = drawLineWithDetectResult(detectArray: detectArray)
        let path = (Bundle.main.path(forResource: "boy", ofType: nil)! as NSString).appendingPathComponent("face/face1/m_face_0_a@2x.png")
        let secondImage = UIImage.init(contentsOfFile: path)
        showView.image = blendTwoImage(first: firstImage, second: secondImage!)
        
    }
    
}

extension LGFScaleImageViewController{
    
    //重新绘制一些线框在原图片上，生成新的图片 获取一张新的图片为截取的脸部部分
    private func drawLineWithDetectResult(detectArray:[CIFeature]?) -> UIImage
    {
        
        guard detectArray != nil else {
            return testImage
        }
        UIGraphicsBeginImageContext(testImage.size)
        testImage.draw(at: CGPoint(x: 0, y: 0))
        
        let str:NSString = "e" as NSString
        
        var firstImageFrame:CGRect = .zero
        
        for result:CIFeature in detectArray!
        {
            let temp = result as! CIFaceFeature
            //反过来绘制
            let leftPosition = CGPoint(x: temp.leftEyePosition.x, y: testImage.size.height - temp.leftEyePosition.y)
            let rightPosition = CGPoint(x:  temp.rightEyePosition.x, y: testImage.size.height - temp.rightEyePosition.y)
            let mouthPosition = CGPoint(x: temp.mouthPosition.x, y: testImage.size.height - temp.mouthPosition.y)
            let nosePosition = CGPoint(x: mouthPosition.x, y: leftPosition.y + (mouthPosition.y - leftPosition.y)/2)
            str.draw(at:leftPosition, withAttributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
            str.draw(at: rightPosition, withAttributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
            str.draw(at: mouthPosition, withAttributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
            str.draw(at: nosePosition, withAttributes: [NSAttributedString.Key.foregroundColor:UIColor.red])
            var tempFrame = temp.bounds
            //根据眼睛和嘴巴的位置粗计算出整个脸的位置
            tempFrame.origin.y = min(leftPosition.y, rightPosition.y) - tempFrame.height/4
            firstImageFrame = tempFrame
            
            //绘制需要的纹理到当前的画板上
            let image = UIImage(named: "t_button")
            
            image?.draw(in: CGRect(x: leftPosition.x - tempFrame.width/6 , y: leftPosition.y + 50, width: tempFrame.width/3, height: tempFrame.height/3))
            
        }
        
        let tempImage = UIGraphicsGetImageFromCurrentImageContext()
        let rendImage = tempImage?.cgImage?.cropping(to: firstImageFrame)
        guard rendImage != nil else {
            return tempImage!
        }
        let finishImage = UIImage(cgImage:rendImage!)
        
        UIGraphicsEndImageContext()
        
        
        return finishImage
    }
    
    //根据抠出的脸进行比对模板切脸
    private func blendTwoImage(first firstImage:UIImage,second secondImage:UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(firstImage.size)
        firstImage.draw(at: CGPoint(x: 0, y: 0), blendMode: CGBlendMode.normal, alpha: 1.0)
        secondImage.draw(in: CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height), blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //纠正图片方向的问题
    private func fixOriention(image:UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp!
    }
}
