//
//  Extensions.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit


extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x:0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func imageFromLayer (layer : CALayer) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}

extension UINavigationController {
    
    func hairLine(hide: Bool) {
        //hides hairline at the bottom of the navigationbar
        for subview in self.navigationBar.subviews {
            if subview is UIImageView {
                for hairline in subview.subviews {
                    if hairline is UIImageView && hairline.bounds.height <= 1.0 {
                        hairline.isHidden = hide
                    }
                }
            }
        }
        
    }
}
