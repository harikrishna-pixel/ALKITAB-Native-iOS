//
//  LogoGradientView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 18/03/21.
//

import UIKit

class LogoGradientView: UIView {
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.frame.size.height/2
        let colors = [UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2).cgColor, UIColor(red: 100.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 0.2).cgColor ] as CFArray
        let endRadius = min(frame.width/2, frame.height/2)
        let center = CGPoint(x: 50, y: 50)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: 5.0, endCenter: center, endRadius: CGFloat(endRadius), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
    
}
