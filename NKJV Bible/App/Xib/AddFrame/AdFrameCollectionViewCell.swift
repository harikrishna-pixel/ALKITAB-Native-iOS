//
//  AdFrameCollectionViewCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 25/05/21.
//

import UIKit

class AdFrameCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var MarkAsReadBtn:UIButton!
    @IBOutlet weak var SummaryButton:UIButton!
    
//    @IBOutlet weak var BibleAllOffice:UIButton!
    
    @IBOutlet weak var ADView: UIView!
//    @IBOutlet weak var AdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
        self.setupSummaryButton()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Fixed footer size — avoid self-sizing height jump when Mark as Read / Get Summary appear.
        layoutAttributes.frame.size = CGSize(width: ScreenWidth - 36, height: 88)
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update corner radius when layout is complete (button height is 40, so radius is 20)
        if let summaryButton = self.SummaryButton {
            summaryButton.layer.cornerRadius = summaryButton.frame.height / 2
            
            // Apply solid background color (without animating layout changes)
            UIView.performWithoutAnimation {
                self.applyGradientToSummaryButton()
            }
        }
    }
    
    func setupSummaryButton() {
        guard let summaryButton = self.SummaryButton else { return }
        // Set initial corner radius (button height is 40, so radius is 20)
        summaryButton.layer.cornerRadius = 20
        summaryButton.clipsToBounds = true
        
        // Set border color to theme color
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        summaryButton.layer.borderColor = themeColor.cgColor
        summaryButton.layer.borderWidth = 1
    }
    
    func applyGradientToSummaryButton() {
        guard let summaryButton = self.SummaryButton else { return }
        
        // Don't apply gradient if button frame is not yet set
        guard summaryButton.bounds.width > 0 && summaryButton.bounds.height > 0 else { return }
        
        // Remove any existing gradient layers
        summaryButton.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Get theme color with 0.2 opacity
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        let themeColorWithOpacity = themeColor.withAlphaComponent(0.2)
        
        // Set solid background color (no gradient)
        summaryButton.backgroundColor = themeColorWithOpacity
    }

 

}
