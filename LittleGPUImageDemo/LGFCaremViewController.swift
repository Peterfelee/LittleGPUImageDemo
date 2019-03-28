//
//  LGFCaremViewController.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/3/28.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

import EVGPUImage2
import AVFoundation


class LGFCaremViewController: UIViewController {
    
//    private var pickerViewController:UIImagePickerController!
    
    var cameraView:Camera!
    
    var filter:ToonFilter = ToonFilter()
    var barlim:BilateralBlur = BilateralBlur()
    var soft:SepiaToneFilter = SepiaToneFilter()
    var renderView:RenderView = RenderView()
    
    override func loadView() {
        super.loadView()
//        pickerViewController = UIImagePickerController()
//        pickerViewController.sourceType = .camera
//        pickerViewController.delegate = self
//        view.addSubview(pickerViewController.view)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderView.frame  = view.bounds
        view.addSubview(renderView)
        cameraView = try? Camera.init(sessionPreset: AVCaptureSession.Preset.high, cameraDevice: nil, location: PhysicalCameraLocation.frontFacing, captureAsYUV: true)
        cameraView --> soft --> renderView
        
        cameraView.startCapture()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
  

}

extension LGFCaremViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension LGFCaremViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        swtichCamera()
        
    }
    
    private func swtichCamera()
    {
       
        for input:AVCaptureInput in cameraView.captureSession.inputs
        {
            if (input as! AVCaptureDeviceInput).device.hasMediaType(.video){
                var newInput:AVCaptureDeviceInput?
                var newDevice:AVCaptureDevice?
                if (input as! AVCaptureDeviceInput).device.position == AVCaptureDevice.Position.back
                {
                    newDevice = cameraWithPosition(position: .front)
                    cameraView.location = .frontFacing
                }
                else
                {
                    newDevice = cameraWithPosition(position: .back)
                    cameraView.location = .backFacing
                }
                
                if let new = newDevice{
                    newInput = try? AVCaptureDeviceInput.init(device: new)
                }
                guard newInput != nil else
                {
                    return
                }
                cameraView.captureSession.beginConfiguration()
                cameraView.captureSession.removeInput(input)
                cameraView.captureSession.addInput(newInput!)
                cameraView.captureSession.commitConfiguration()
            }
        }
    }
    
    private func cameraWithPosition(position:AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let devices = AVCaptureDevice.devices(for: .video)
        if devices.count > 0
        {
            for device in devices
            {
                if device.position == position
                {
                    return device
                }
            }
        }
        return nil
    }
    
}
