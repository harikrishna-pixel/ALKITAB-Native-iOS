//
//  BibleVerseCC.swift
//  NKJV Bible
//
//  Created by ajayprasanth on 08/12/22.
//

import UIKit

class BibleVerseCC: UICollectionViewCell {
    
    
    @IBOutlet weak var BibleDetaillbl: UILabel!
    @IBOutlet weak var ContainView: UIView!
    
    @IBOutlet weak var ColorFrame: UIView!
    @IBOutlet weak var BottomFrame: UIView!
        
    
    @IBOutlet weak var DotLine: UIView!

    
    @IBOutlet weak var ColorFrameH: NSLayoutConstraint!
    @IBOutlet weak var BottomFrameH: NSLayoutConstraint!
    
    @IBOutlet weak var BookmarkHeight: NSLayoutConstraint!
    @IBOutlet weak var BookmarkWidth: NSLayoutConstraint!
    
    @IBOutlet weak var NotesHeight: NSLayoutConstraint!
    @IBOutlet weak var NotesWidth: NSLayoutConstraint!
    
    @IBOutlet weak var FrameConstrain: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let targetSize = CGSize(width: ScreenWidth-(isIpad ? 30:20), height: 0)
        let targetSize = CGSize(width: ScreenWidth-CGFloat((UserDefaults.standard.float(forKey: "FontSize")+10)), height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Re-draw dashed line when layout changes to ensure correct bounds
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.DotLine.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }
            if !self.DotLine.isHidden {
                self.DotLine.addDashedLine()
            }
        }
    }
    
    
    
}

