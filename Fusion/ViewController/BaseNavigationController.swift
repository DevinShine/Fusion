//
//  BaseNavigationController.swift
//  Fusion
//
//  Created by DevinShine on 2017/5/26.
//  Copyright © 2017年 DevinShine. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false;//不启用透明效果
        self.navigationBar.barTintColor = UIColor.mainBackgroundColor
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }


}
