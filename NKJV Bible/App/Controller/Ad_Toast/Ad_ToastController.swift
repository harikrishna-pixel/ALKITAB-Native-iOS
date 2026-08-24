//
//  Ad_ToastController.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/11/21.
//

import UIKit


class Ad_ToastController: UIViewController {

    @IBOutlet weak var BannerView: UIView!
    @IBOutlet weak var AlertLbl: UILabel!
    @IBOutlet weak var AlertBtn: UIButton!
    @IBOutlet weak var LogoImg: UIImageView!
    @IBOutlet weak var LogoView: UIView!
    
    
    @IBOutlet weak var AdView: UIView!
//    @IBOutlet weak var AdBanner: UIView!
    
    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    
    var VText = ""
    var VTitle = ""
    
    var AlertTxt:String?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PaymentHistory.sharedInstance.paymentInfo() {
            
            
            DispatchQueue.main.async {
                IronSourceBanner.sharedInstance.ViewControl = self
                IronSourceBanner.sharedInstance.IronSource_Banner_AdLoad(bannerWidth: Int(self.AdView.frame.width), bannerHeight: Int(self.AdView.frame.width))
            }
        } else {
            self.AdView.isHidden = true
        }

        
        self.AlertBtn.layer.cornerRadius = self.AlertBtn.frame.height/2
        self.BannerView.layer.cornerRadius = 10
//        self.BannerView.layer.masksToBounds = true
//        ImageTint.sharedInstance.imageTintcolorMethod(img: self.LogoImg! , colorVu: UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
        
        self.AlertLbl.text = AlertTxt
        
        AlertBtn.backgroundColor = (Themecolor == BGNightMode ? DarkModeColor:Themecolor)
        
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.4) {
//            App_Protocol.delegateReader?.CloseMenu()
//        }
    }
    
    @IBAction func CloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
