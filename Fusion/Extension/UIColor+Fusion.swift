//
//  UIColor+Neat.swift
//  Neat
//
//  Created by DevinShine on 16/10/24.
//  Copyright © 2016年 DevinShine. All rights reserved.
//

import UIKit
extension UIColor {
    open class var mainBackgroundColor: UIColor {
        return UIColor(hex: 0x211E3B)!
    }
    
    open class var mainColor: UIColor {
        return UIColor(hex: 0xFD4A6C)!
    }
    
    open class var textLevel1Color: UIColor {
        return UIColor(hex: 0x3C3C3C)!
    }
    
    open class var textLevel2Color: UIColor {
        return UIColor(hex: 0x555555)!
    }
    
    open class var textLevel3Color: UIColor {
        return UIColor(hex: 0xA7A7A7)!
    }
    
    func imageFromColor() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
