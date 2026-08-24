//
//  PopupButton.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/09/23.
//


import UIKit

class PopupButton: UIButton {

    
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = self.layer.frame.height/2
        self.layer.masksToBounds = true
        self.ButtonAnimation()
    }
    
    
    func ButtonAnimation() {
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
              self.ButtonAnimation1()
            })
    }
    
    func  ButtonAnimation1() {
        UIView.animate(withDuration: 0.6,
                animations: {
                    self.transform = CGAffineTransform.identity
                },
                completion: { _ in
               self.ButtonAnimation()
          })
    }
    

}
