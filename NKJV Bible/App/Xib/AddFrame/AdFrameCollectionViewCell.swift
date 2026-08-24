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
        let targetSize = CGSize(width: ScreenWidth-36, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update corner radius when layout is complete (button height is 40, so radius is 20)
        if let summaryButton = self.SummaryButton {
            summaryButton.layer.cornerRadius = summaryButton.frame.height / 2
            
            // Apply solid background color
            self.applyGradientToSummaryButton()
        }
        self.updateAdLabelPosition()
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
        
        self.addAdLabelToSummaryButton()
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
    
    func addAdLabelToSummaryButton() {
        guard let summaryButton = self.SummaryButton else { return }
        
        // Remove any existing Ad label
        summaryButton.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create Ad label
        let adLabel = UILabel()
        adLabel.tag = 999
        adLabel.text = "Ad"
        adLabel.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        adLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        adLabel.textAlignment = .right
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        
        summaryButton.addSubview(adLabel)
        
        // Add constraints - positioned at top right inside the button
        NSLayoutConstraint.activate([
            adLabel.widthAnchor.constraint(equalToConstant: 24),
            adLabel.heightAnchor.constraint(equalToConstant: 12),
            adLabel.topAnchor.constraint(equalTo: summaryButton.topAnchor, constant: 4),
            adLabel.trailingAnchor.constraint(equalTo: summaryButton.trailingAnchor, constant: -8)
        ])
    }
    
    func updateAdLabelPosition() {
        guard let summaryButton = self.SummaryButton else { return }
        // Ensure Ad label stays in correct position when layout changes
        if let adLabel = summaryButton.subviews.first(where: { $0.tag == 999 }) {
            adLabel.setNeedsLayout()
        }
    }

 

}
