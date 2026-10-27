//
//  CoinLabel.swift
//  General Quiz
//
//  Created by ajayprasanth on 13/04/23.
//

import UIKit

class CoinLabel: UILabel {

    private var keepsPulsing = true
    private var drawnSize: CGSize = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshCoinFace()
    }
    
    private func setup() {
        self.textColor = .black
        self.textAlignment = .center
        self.clipsToBounds = true
        refreshCoinFace()
        self.ButtonAnimation()
    }

    /// Quiz badges call this together so both coins share one size, shape, and pulse.
    func applySharedCoinStyle(startPulse: Bool) {
        textColor = .black
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        clipsToBounds = true
        layer.masksToBounds = true
        let side = min(bounds.width, bounds.height)
        if side > 1 {
            layer.cornerRadius = side / 2
        }
        refreshCoinFace()
        guard startPulse else { return }
        keepsPulsing = false
        layer.removeAllAnimations()
        transform = .identity
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.2
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        layer.add(pulse, forKey: "coinPulse")
    }

    private func refreshCoinFace() {
        let size = bounds.size
        guard size.width > 1, size.height > 1, size != drawnSize, let image = UIImage(named: "CoinsLbl") else { return }
        drawnSize = size
        let side = min(size.width, size.height)
        guard let face = imageWithImage(image: image, scaledToSize: CGSize(width: side, height: side)) else { return }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        face.draw(in: CGRect(x: (size.width - side) / 2, y: (size.height - side) / 2, width: side, height: side))
        let canvas = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let canvas = canvas {
            backgroundColor = UIColor(patternImage: canvas)
        }
    }
    
    
    func ButtonAnimation() {
        guard keepsPulsing else { return }
        UIView.animate(withDuration: 0.6,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { finished in
                guard finished, self.keepsPulsing else { return }
                self.ButtonAnimation1()
            })
    }
    
    func  ButtonAnimation1() {
        guard keepsPulsing else { return }
        UIView.animate(withDuration: 0.6,
                animations: {
                    self.transform = CGAffineTransform.identity
                },
                completion: { finished in
                    guard finished, self.keepsPulsing else { return }
                    self.ButtonAnimation()
          })
    }
    
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage? {
        guard newSize.width > 1, newSize.height > 1 else { return nil }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let aspect = image.size.width / max(image.size.height, 1)
        let drawSize: CGSize
        if aspect >= 1 {
            drawSize = CGSize(width: newSize.width, height: newSize.width / aspect)
        } else {
            drawSize = CGSize(width: newSize.height * aspect, height: newSize.height)
        }
        image.draw(in: CGRect(
            x: (newSize.width - drawSize.width) / 2,
            y: (newSize.height - drawSize.height) / 2,
            width: drawSize.width,
            height: drawSize.height
        ))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    

}



class CoinLabel2: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        setup()
    }
    
    private func setup() {
        self.textColor = .black
        self.textAlignment = .center
        let image = imageWithImage(image: UIImage(named: "CoinsLbl")!, scaledToSize: self.frame.size)
        
        self.backgroundColor = UIColor(patternImage: image)
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
    
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    

}
