//
//  CopyRightsCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 18/11/21.
//

import UIKit

class CopyRightsCell: UICollectionViewCell {

    
    @IBOutlet weak var MarkAsReadBtn:UIButton!
    @IBOutlet weak var BibleAllOffice:UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: ScreenWidth-36, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }

}
