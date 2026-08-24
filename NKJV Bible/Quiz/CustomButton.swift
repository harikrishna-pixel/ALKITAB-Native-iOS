//
//  CustomButton.swift
//  General Quiz
//
//  Created by ajayprasanth on 19/05/23.
//

import UIKit


class CustomButton: UIButton {

    var borderWidth: CGFloat = 4.0
    var borderColor = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor).cgColor
    
    override func awakeFromNib() {
         super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.borderColor = borderColor
        self.layer.borderWidth = borderWidth
        self.titleLabel!.font = UIFont(name: "ChalkboardSE-Bold" , size: 15)
        self.setTitleColor(.black, for: .normal)
        
        
        self.layer.backgroundColor = UIColor.white.cgColor
        self.addTarget(self, action: #selector(CustomButton.buttonClicked(sender:)), for: .touchUpInside)
     }

     @objc private func buttonClicked(sender: UIButton) {
         UIView.animate(withDuration: 0.1,
             animations: {
                 self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
             },
             completion: { _ in
                 UIView.animate(withDuration: 0.1) {
                     self.transform = CGAffineTransform.identity
                 }
             })
         if UserDefaults.standard.bool(forKey: "VibSwitch") {
             Vibration.soft.vibrate()
         }
         if UserDefaults.standard.bool(forKey: "ToneSwitch") {
             QuizClickSound.shared.ClickSound()
         }
     }
 }



