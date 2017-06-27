//
//  HomeViewController.swift
//  Fusion
//
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController,TLPhotosPickerViewControllerDelegate {

    @IBOutlet var startButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.mainBackgroundColor
        self.startButton.backgroundColor = UIColor.mainColor
        self.startButton.setTitleColor(UIColor.white, for: .normal)
        self.startButton.layer.cornerRadius = 10
        self.startButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAction(_ sender: Any) {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 10
        viewController.configure = configure
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        guard withTLPHAssets.count > 1 else {
            let alert = UIAlertController(title: "提示", message: "请至少选择两张图片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let images = withTLPHAssets.flatMap { (asset) -> UIImage? in
            return asset.fullResolutionImage
        }
        
        let controller = PreviewViewController(images)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "提示", message: "超出了可选的最大数量", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}
