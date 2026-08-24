//
//  BannerAd.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 04/05/23.
//

import UIKit

class BannerAd: UICollectionViewCell {

    @IBOutlet weak var ADView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: ScreenWidth-36, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }

 

}
