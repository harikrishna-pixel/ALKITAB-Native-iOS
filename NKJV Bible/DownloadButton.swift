//
//  DownloadButton.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 21/08/23.
//

import UIKit

class DownloadButton: UIButton {

    
    override func draw(_ rect: CGRect) {
        self.ButtonAnimation()
        
        self.layer.cornerRadius = 17.5
        self.layer.masksToBounds = true
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
