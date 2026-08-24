//
//  SlideCardCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 24/02/21.
//

import UIKit

class SlideCardCell: UICollectionViewCell {
    
    @IBOutlet weak var SliderImage:UIImageView!
    
    @IBOutlet weak var SliderImageView:UIView!
    @IBOutlet weak var SliderShadowVu:UIView!
        
    @IBOutlet weak var Verse:UILabel!
    @IBOutlet weak var Book:UILabel!
    
    @IBOutlet weak var ShareBtn:UIButton!
    @IBOutlet weak var ShareBtnVu:UIView!
    
    @IBOutlet weak var changeImage:UIButton!
    
    @IBOutlet weak var WaterMark:UIView!
    @IBOutlet weak var WaterMarkLbl:UILabel!
    


    override func awakeFromNib() {
        super.awakeFromNib()
        self.Verse.addInterlineSpacing(spacingValue: 3)
        // Initialization code
    }

}



//private extension UILabel {
//
//    // MARK: - spacingValue is spacing that you need
//    func addInterlineSpacing(spacingValue: CGFloat = 2) {
//
//        // MARK: - Check if there's any text
//        guard let textString = text else { return }
//
//        // MARK: - Create "NSMutableAttributedString" with your text
//        let attributedString = NSMutableAttributedString(string: textString)
//
//        // MARK: - Create instance of "NSMutableParagraphStyle"
//        let paragraphStyle = NSMutableParagraphStyle()
//
//        // MARK: - Actually adding spacing we need to ParagraphStyle
//        paragraphStyle.lineSpacing = spacingValue
//
//        // MARK: - Adding ParagraphStyle to your attributed String
//        attributedString.addAttribute(
//            .paragraphStyle,
//            value: paragraphStyle,
//            range: NSRange(location: 0, length: attributedString.length
//        ))
//
//        // MARK: - Assign string that you've modified to current attributed Text
//        attributedText = attributedString
//    }
//
//}

