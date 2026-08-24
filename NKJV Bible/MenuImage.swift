//
//  MenuImage.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/06/23.
//

import UIKit

@IBDesignable
class MenuImage: UIImageView {
    
    let Themecolor:UIColor =  UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    override init(image: UIImage?) {
        super.init(image: image)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    if (self.Themecolor.toHexString() != UIColor.black.toHexString() &&  self.Themecolor.toHexString() != BGNightMode.toHexString()) || self.Themecolor.toHexString() == "#000000" {
        
        ImageTint.sharedInstance.imageTintcolorMethod(img: self, colorVu: .darkGray)
    } else {
        ImageTint.sharedInstance.imageTintcolorMethod(img: self, colorVu: .white)
    }

        
        
        

    }
}

