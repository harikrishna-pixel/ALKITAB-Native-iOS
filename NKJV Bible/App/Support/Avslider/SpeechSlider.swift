//
//  SpeechSlider.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 07/10/21.
//

import UIKit

class SpeechSlider: UISlider {

    
    var thumpColor:UIColor!
    @IBInspectable var trackHeight: CGFloat = 5

    @IBInspectable var thumbRadius: CGFloat = 20

    // Custom thumb view which will be converted to UIImage
    // and set as thumb. You can customize it's colors, border, etc.

    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .white//thumbTintColor
        thumb.layer.borderWidth = 0//1.5
        thumb.layer.borderColor = UserDefaults.standard.color(forKey: "AppThemeColor")?.cgColor
        return thumb
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.customeColor(Thumpcolor: UIColor(white: 1, alpha: 0.5))
    }
    
    func customeColor(Thumpcolor:UIColor) {
        self.thumbView.layer.borderColor  = Thumpcolor.cgColor
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }
    
    
    private func thumbImage(radius: CGFloat) -> UIImage {
        
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
}
