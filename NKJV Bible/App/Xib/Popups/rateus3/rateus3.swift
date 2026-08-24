//
//  rateus3.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 30/07/23.
//

import UIKit
import StoreKit
class rateus3: UIView {

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    
    @IBAction func Ignore_Action(_ sender: Any) {
        UserDefaults.standard.setValue(Date.oneMonth.string(format: "dd-MM-yyyy"), forKey: "RateAction")
        self.removeFromSuperview()
    }
    
    @IBAction func Rate_Action(_ sender: Any) {
        SKStoreReviewController.requestReviewInCurrentScene()
        self.removeFromSuperview()
    }
    
    
    
}
