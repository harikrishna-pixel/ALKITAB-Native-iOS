//
//  CoinLabel.swift
//  General Quiz
//
//  Created by ajayprasanth on 13/04/23.
//

import UIKit

class CoinLabel: UILabel {

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
