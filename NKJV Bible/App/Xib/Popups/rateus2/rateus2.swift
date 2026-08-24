//
//  rateus2.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/07/23.
//

import UIKit


class rateus2: UIView {
    

    var SourceVu:ReaderViewController!
    
    @IBOutlet weak var BannerImage: UIImageView!
    @IBOutlet weak var ShareBtn: UIButton!
    
    
    override func draw(_ rect: CGRect) {
        
        self.ShareBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.BannerImage, colorVu: hexColorConvert.shared.hexStringToUIColor(hex: "AFAB33"))
    }
    

    
    
    @IBAction func No_Action(_ sender: Any) {
        UserDefaults.standard.setValue(Date.oneMonth.string(format: "dd-MM-yyyy"), forKey: "RateAction")
        self.removeFromSuperview()
    }
    
    @IBAction func Yes_Action(_ sender: Any) {
        SourceVu.openRatePopup()
        self.removeFromSuperview()
    }
    
    
}
