//
//  QuizAnswerCC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 20/02/23.
//

import UIKit

class QuizAnswerCC: UICollectionViewCell {
    
    @IBOutlet weak var AnswerVu: UIView!
    @IBOutlet weak var AnswerLbl: UILabel!

    // Self-sizing remeasures this cell forever and freezes the Bible Quiz.
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}
