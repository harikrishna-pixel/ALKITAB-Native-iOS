//
//  QuizAnswersCell.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 23/02/23.
//

import UIKit

class QuizAnswersCell: UICollectionViewCell {
    
    @IBOutlet weak var QuestionNo: UILabel!
    @IBOutlet weak var AnswerLbl: UILabel!
    @IBOutlet weak var AnswerView: UIView!
    
    
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
