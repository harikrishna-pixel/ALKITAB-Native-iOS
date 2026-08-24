//
//  GradientView.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 04/02/21.
//

import UIKit
@IBDesignable
class GradientView: UIView {

     var InsideColor: UIColor = UIColor.clear
     var OutsideColor: UIColor = UIColor.clear

    override func draw(_ rect: CGRect) {
        InsideColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        OutsideColor = UIColor.white
        let colors = [InsideColor.cgColor, OutsideColor.cgColor] as CFArray
        let endRadius = min(frame.width*6, frame.height*2)
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 3.5)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: 15.0, endCenter: center, endRadius: CGFloat(endRadius), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }
}


