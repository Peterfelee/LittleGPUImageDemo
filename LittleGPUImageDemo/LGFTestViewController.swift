//
//  LGFTestViewController.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/3/28.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import EVGPUImage2

class LGFTestViewController: UIViewController {
    
    private var backButton:UIButton!
    private var showView:UIView!
    private var testImage:UIImage = UIImage(named: "WID-small.jpg")!
    var am:AmatorkaFilter = AmatorkaFilter()
    var miss:MissEtikateFilter = MissEtikateFilter()
    var toon:ToonFilter = ToonFilter()
    var input:PictureInput!
    var temp:PictureInput!
    var output:PictureOutput!
    var dissolve:DissolveBlend = DissolveBlend()
    
    var detect:CIDetector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        title = "滤镜合成效果"
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
        
        
        let showViewWidth:CGFloat = 180
        let showViewHeight:CGFloat = 300
        
        showView = UIView(frame: CGRect(x: self.view.frame.width/2 - showViewWidth/2, y: self.view.frame.height/2.0 - showViewHeight/2 , width:showViewWidth, height: showViewHeight))
//        showView.layer.contentsGravity = CALayerContentsGravity(rawValue: "resizeAspect")
        view.addSubview(showView)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        showView.isUserInteractionEnabled = true
        showView.addGestureRecognizer(tap)
        
        
        let slider = UISlider(frame: CGRect(x: 10, y: self.view.frame.height - 50, width: self.view.frame.width - 20, height: 20))
        slider.value = 0.5
        slider.addTarget(self, action: #selector(valueChange(slider:)), for: .valueChanged)
        self.view.addSubview(slider)
        
        
        let sel = #selector(nextButtonClick)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: sel)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "detect", style: .plain, target: self, action: #selector(detectButtonClick))
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupFilter()
    }
    private func setupFilter()
    {
        input = PictureInput(image: testImage)
        output = PictureOutput()
        output.keepImageAroundForSynchronousCapture  = true
        output.onlyCaptureNextFrame = true
        temp = PictureInput(imageName: "clean_20170807.png")
        input --> dissolve  -->/* miss -->*/ miss --> output
        temp --> dissolve
        processImage()
    }
    
    private func processImage()
    {
        temp.processImage(synchronously: false)
        input.processImage(synchronously: false)
        showView.layer.contents = output.synchronousImageCapture().cgImage
    }
    
    @objc private func backButtonClick(button:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LGFTestViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
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
                    self?.input.removeAllTargets()
                    self?.testImage = image as! UIImage
                    self?.setupFilter()
                }
            }
        }
    }
    
    
    @objc private func valueChange(slider:UISlider)
    {
        miss.intensity = Float(slider.value)
        toon.quantizationLevels = Float(slider.value)*10.0
        toon.threshold = Float(slider.value)
        dissolve.mix = Float(slider.value)
        processImage()
    }
    
    @objc private func nextButtonClick()
    {
        self.navigationController?.pushViewController(LGFCaremViewController(), animated: true)
    }
    
    @objc private func detectButtonClick()
    {
        self.navigationController?.pushViewController(LGFScaleImageViewController(), animated: true)
    }

}

