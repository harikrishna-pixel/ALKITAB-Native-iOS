//
//  BookCatagoryCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 31/05/24.
//

import UIKit

class BookCatagoryCell: UICollectionViewCell {
    @IBOutlet var BookCatagoryList : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: ScreenWidth-CGFloat((UserDefaults.standard.float(forKey: "FontSize")+10)), height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }

    
    
}
