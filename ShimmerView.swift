//
//  ShimmerView.swift
//  ShimmerAnimationComplete
//
//  Created by Jha, Vasudha on 29/11/19.
//  Copyright © 2019 Jha, Vasudha. All rights reserved.
//

import UIKit

class ShimmerView: UIButton {

//    var gradientColorOne : CGColor = UIColor(white: 0.85, alpha: 0.0).cgColor
//    var gradientColorTwo : CGColor = UIColor(white: 1.95, alpha: 0.5).cgColor


    
//    func addGradientLayer() -> CAGradientLayer {
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
//        gradientLayer.locations = [0.4, 0.5, 0.6]
//        self.layer.addSublayer(gradientLayer)
//
//        return gradientLayer
//    }
//
//    func addAnimation() -> CABasicAnimation {
//
//        let animation = CABasicAnimation(keyPath: "locations")
//        animation.fromValue = [-1.0, -0.5, 0.0]
//        animation.toValue = [1.0, 1.5, 2.0]
//        animation.repeatCount = .infinity
//        animation.duration = 1.6
//        return animation
//
//    }
    
    func startAnimating() {
        
//        self.layer.sublayers = self.layer.sublayers?.filter { theLayer in
//                !theLayer.isKind(of: CAGradientLayer.classForCoder())
//          }
//
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.masksToBounds = true
//
//        let gradientLayer = addGradientLayer()
//        let animation = addAnimation()
//
//        gradientLayer.add(animation, forKey: animation.keyPath)
        
        self.shimmer(view: self)
        
    }
    
    
    
    
    func shimmer(view: UIButton) {
            let gradient = CAGradientLayer()
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: -0.02)
            gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width*3, height: view.bounds.size.height)

            let lowerAlpha: CGFloat = 0.3
            let solid = UIColor(white: 1, alpha: 1).cgColor
            let clear = UIColor(white: 1, alpha: lowerAlpha).cgColor
        
            gradient.colors     = [ solid, solid, clear, solid, solid, solid ]
            gradient.locations  = [ 0,     0.40,   0.45,  0.49,  0.7,   1     ]

            let theAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
            theAnimation.duration = 2
            theAnimation.repeatCount = Float.infinity
            theAnimation.autoreverses = false
            theAnimation.isRemovedOnCompletion = false
            theAnimation.fillMode = CAMediaTimingFillMode.forwards
            theAnimation.fromValue = -view.frame.size.width * 2
            theAnimation.toValue =  0
            gradient.add(theAnimation, forKey: "animateLayer")

            view.layer.mask = gradient
        }
    
    

}




