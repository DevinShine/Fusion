//
//  PreviewViewController.swift
//  Fusion
//
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var images:[UIImage?]?
    @IBOutlet var previewHeightConstraint:NSLayoutConstraint!
    @IBOutlet var previewWidthConstraint:NSLayoutConstraint!
    @IBOutlet var previewImageView:UIImageView!
    @IBOutlet var generateButton:UIButton!
    deinit {
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: "PreviewViewController", bundle: Bundle(for: PreviewViewController.self))
    }
    
    public convenience init(_ images: [UIImage?]) {
        self.init()
        self.images = images
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        if (self.navigationController?.isNavigationBarHidden)! {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "预览"
        self.generateButton.backgroundColor = UIColor.mainBackgroundColor
        self.generateButton.setTitle("保存到本地", for: .normal)
        
        let image = DVSFusion.merge(self.images! as! [UIImage])!
        previewImageView.image = image
        previewHeightConstraint.constant = UIScreen.main.bounds.size.width * (image.size.height / image.size.width)
        previewWidthConstraint.constant = UIScreen.main.bounds.size.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(previewImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "保存失败", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default){ action -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "保存成功", message: "已经成功保存到本地", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default){ action -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            present(ac, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
