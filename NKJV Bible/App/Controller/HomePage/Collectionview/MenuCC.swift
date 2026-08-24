//
//  MenuCC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 09/12/22.
//

import UIKit



class MenuCC: UICollectionViewCell {
    
    
    @IBOutlet weak var Menutext: UILabel!
    @IBOutlet weak var MenuView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: 0, height: 30)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        return layoutAttributes
    }
    
}
