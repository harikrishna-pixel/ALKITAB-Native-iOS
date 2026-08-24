//
//  MenuButton.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit

class MenuButton: UIView {

    @IBOutlet weak var HomeBtnView: UIView!
    @IBOutlet weak var HomeViewText: UILabel!
    @IBOutlet weak var HomeButtonConstrain: NSLayoutConstraint!
    
    
   override func draw(_ rect: CGRect) {
       
       HomeBtnView.backgroundColor = UIColor.clear
       HomeButtonConstrain.constant = 30
       HomeViewText.textColor = UIColor.clear
       
    }
    
    
    
}
