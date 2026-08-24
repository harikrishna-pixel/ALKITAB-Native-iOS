//
//  AppTrackIng_Popup.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 20/12/21.
//

import UIKit


class AppTrackIng_Popup: UIView {
    
    @IBOutlet weak var AlertTitle:UILabel!
    @IBOutlet weak var AlertContent:UILabel!
    @IBOutlet weak var NextBtn:UIButton!
    

    override func draw(_ rect: CGRect) {
        self.AlertTitle.text = "Thankful for Your Support!"
        self.AlertContent.text = "Ads enable us to serve you better. Kindly grant permission for personalized ads on the next screen. We're committed to preserving your reading experience. Your understanding is greatly appreciated. May God's Blessings be with You!"
    }
    
    
    @IBAction func Next(_ sender: Any) {
        App_Protocol.DelegateSplash!.PopupClose()
    }
    
    
//    add not enabled in code for now and  i need
}
