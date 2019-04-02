//
//  ViewController.swift
//  LittleGPUImageDemo
//
//  Created by peterlee on 2019/3/28.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import GPUImage

class LGFViewController: UIViewController {
    
    var renderView: RenderView = RenderView(frame: CGRect.zero)
    var collectionView: UICollectionView!
    
    let imageNames = ["vivid_20170620","crisp_20170520","jiari_20170928","xinxian_20170928","sweety_20170620-2","tianmei_20170928","vintage_20170520","musi_20170928","origin_20170824","nature_20170824","sweety_20170620","clean_lookup","beach_20170520","coral_20170620","meiwei_20170928","bingqilin_20170928","fresh_20170620","lolita_20170620","clean_20170807","chulian_20170928","jugeng_20170928","kisskiss_20170620","yuanqi_20170928","pink_20170928","makalong_20170928","sunset_20170620","yangqi_20170928","grass_20170621","urban_20170520","glossy_20170928","xiaosenlin_20170928_2"]
    let cellIdentifier = "UICollectionViewCell"
    var picture:PictureInput!
    var pickerImageViewController:UIImagePickerController!
    
    var dissove:DissolveBlend!
    var grammaAdjust:GammaAdjustment!
    var staturation:SaturationAdjustment!
    var lookupFilter:LookupFilter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "多滤镜效果"
        configView()
        setupFilter()
    }
    
    private func configView()
    {
        var frame = view.frame
        frame.size.height = frame.height - 100
        renderView.frame = frame
        renderView.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        renderView.addGestureRecognizer(tap)
        view.addSubview(renderView)
        
        view.backgroundColor = UIColor.white
        
        let flowLayout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: view.frame.height - 100 , width: view.frame.width, height: 100), collectionViewLayout: flowLayout)
        flowLayout.itemSize = CGSize(width: 90, height: 90)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.scrollDirection  = .horizontal
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        
        let sel = #selector(nextButtonClick)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: sel)
        
        let slider = UISlider(frame: CGRect(x: 10, y: collectionView.frame.minY - 30, width: frame.width - 20, height: 30))
        view.addSubview(slider)
        slider.value = 1.0
        slider.addTarget(sel, action: #selector(sliderValue(_:)), for: .valueChanged)
    }
    
    private func setupFilter()
    {
        // Filtering image for display
        picture = PictureInput(image:UIImage(named:"splash.png")!)
        
        //        filter = SaturationAdjustment()
        dissove = DissolveBlend()
        grammaAdjust = GammaAdjustment()
        staturation = SaturationAdjustment()
        lookupFilter = LookupFilter()
        
        let imagePath = Bundle.main.path(forResource: "crisp_20170520", ofType: "png")
        lookupFilter.lookupImage = PictureInput(image: UIImage(contentsOfFile: imagePath!)!)
        
        picture --> /*dissove -->*/ lookupFilter as! ImageSource --> /*bilateralblur --> grammaAdjust --> staturation --> sharpen -->*/ renderView
        picture.processImage(synchronously: true)
    }
}



extension LGFViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let imagePath = Bundle.main.path(forResource: imageNames[indexPath.row], ofType: "png")
        cell.layer.contents = UIImage.init(contentsOfFile: imagePath!)?.cgImage
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
        cell.backgroundView = label
        
        let str = (imageNames[indexPath.row] as NSString)
        if  str.contains("_") {
            let range = str.range(of: "_")
            label.text = str.substring(to: range.location)
        }
        else{
            label.text = imageNames[indexPath.row]
        }
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.init(white: 0.2, alpha: 0.4)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        renderView.removeSourceAtIndex(0)
        let imagePath = Bundle.main.path(forResource: imageNames[indexPath.row], ofType: "png")
        lookupFilter.lookupImage = PictureInput(image: UIImage(contentsOfFile: imagePath!)!)
        lookupFilter as! ImageSource --> renderView
        picture.processImage(synchronously: true)
    }
    
}

extension LGFViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
       @objc private func sliderValue(_ sender: UISlider) {
        lookupFilter.intensity = Float(sender.value)
        picture.processImage(synchronously: true)
    }
    
    @objc func nextButtonClick() {
        self.navigationController?.pushViewController(LGFTestViewController(), animated: true)
        
    }
    
    @objc private func tapClick() {
        
        pickerImageViewController = UIImagePickerController()
        pickerImageViewController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        pickerImageViewController.delegate = self
        self.present(pickerImageViewController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let image = info[UIImagePickerController.InfoKey.originalImage]
        {
            picture.removeAllTargets()
            renderView.removeSourceAtIndex(0)
            picture = PictureInput(image: image as! UIImage)
            picture --> lookupFilter as! ImageSource --> renderView
            picture.processImage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
