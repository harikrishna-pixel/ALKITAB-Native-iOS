//
//  rateus1.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/07/23.
//

import UIKit

class rateus1: UIView {
     
    
    @IBOutlet weak var BannerImage: UIImageView!
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var MessageTxt: UILabel!
    
    
    var SourceVu:ReaderViewController!
    
    override func draw(_ rect: CGRect) {
    
        self.ShareBtn.backgroundColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        ImageTint.sharedInstance.imageTintcolorMethod(img: self.BannerImage, colorVu: hexColorConvert.shared.hexStringToUIColor(hex: "6D941D"))
        
        self.MessageTxt.text = "Be the reason to Light up someone's day by sharing this Bible App. \nThanks a million!"
    }
    
    

    
    @IBAction func Share_Action(_ sender: Any) {
        self.shared()
        UserDefaults.standard.setValue("RateShared", forKey: "Rate5")
    }
    
    
    func shared() {
        
        let text = "Hi, I found an amazing Reading Bible application with challenging Bible Trivia to improvise biblical knowledge. \n\nTry it now! : \(APP_LINK)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = SourceVu.view
        activityViewController.popoverPresentationController?.sourceRect = SourceVu.view.bounds
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: SourceVu.view.bounds.midX, y: SourceVu.view.bounds.maxY, width: 0, height: 0)
        SourceVu.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func Close_Action(_ sender: Any) {
        UserDefaults.standard.setValue("RateShared", forKey: "Rate5")
        UserDefaults.standard.setValue(Date.Week.string(format: "dd-MM-yyyy"), forKey: "RateAction")
        self.removeFromSuperview()
    }
    
    
}
