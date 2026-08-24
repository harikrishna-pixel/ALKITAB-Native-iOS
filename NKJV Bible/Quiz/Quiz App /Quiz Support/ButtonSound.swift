//
//  ButtonSound.swift
//  General Quiz
//
//  Created by ajayprasanth on 15/03/23.
//

import UIKit

class ButtonSound: UIButton {

    override func awakeFromNib() {
         super.awakeFromNib()
         self.addTarget(self, action: #selector(ButtonSound.buttonClicked(sender:)), for: .touchUpInside)
     }

     @objc private func buttonClicked(sender: UIButton) {
         if UserDefaults.standard.bool(forKey: "VibSwitch") {
             Vibration.soft.vibrate()
         }
         if UserDefaults.standard.bool(forKey: "ToneSwitch") {
             QuizClickSound.shared.ClickSound()
         }
     }
 }
