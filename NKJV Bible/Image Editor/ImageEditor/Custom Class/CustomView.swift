//
//  CustomView.swift
//  ImageEditor
//
//  Created by ajayprasanth on 17/04/23.
//

import UIKit

class CustomView: UIView {

    @IBInspectable var Radius: CGFloat = 6.0
    

    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = Radius
        self.layer.masksToBounds = true
    }
    

}
