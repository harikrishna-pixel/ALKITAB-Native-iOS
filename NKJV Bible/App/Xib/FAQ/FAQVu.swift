//
//  FAQ.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 25/09/23.
//

import UIKit

class FAQVu: UIView {

    @IBOutlet weak var MainFrame: UIScrollView!
    
    
    override func draw(_ rect: CGRect) {
        self.MainFrame.layer.cornerRadius = 20
        self.MainFrame.layer.masksToBounds = true
        // Drawing code
    }

    @IBAction func Close_Action(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
}
