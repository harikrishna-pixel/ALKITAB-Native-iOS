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
    private var isMarkedRead = false
    
//    @IBOutlet weak var BibleAllOffice:UIButton!
    
    @IBOutlet weak var ADView: UIView!
//    @IBOutlet weak var AdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        // Initialization code
        self.setupSummaryButton()
        self.setupMarkAsReadButton()
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
        self.applyMarkAsReadAppearance()
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
        
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        let isNight = themeColor.toHexString() == BGNightMode.toHexString()
        if isNight {
            summaryButton.backgroundColor = .white
            summaryButton.setTitleColor(.black, for: .normal)
            summaryButton.layer.borderColor = UIColor.white.cgColor
        } else {
            summaryButton.backgroundColor = themeColor.withAlphaComponent(0.2)
            summaryButton.setTitleColor(.black, for: .normal)
            summaryButton.layer.borderColor = themeColor.cgColor
        }
    }

    func setMarkAsRead(_ isRead: Bool) {
        isMarkedRead = isRead
        applyMarkAsReadAppearance()
    }

    func setupMarkAsReadButton() {
        guard let button = MarkAsReadBtn else { return }
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        button.layer.borderColor = themeColor.cgColor
        button.layer.borderWidth = 1
        applyMarkAsReadAppearance()
    }

    func applyMarkAsReadAppearance() {
        guard let button = MarkAsReadBtn else { return }
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        if button.bounds.height > 0 {
            button.layer.cornerRadius = button.bounds.height / 2
        }
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = themeColor.cgColor
        if isMarkedRead {
            button.backgroundColor = themeColor
            button.setTitle("Marked as Read", for: .normal)
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = themeColor.withAlphaComponent(0.2)
            button.setTitle("Mark as Read", for: .normal)
            button.setTitleColor(.black, for: .normal)
        }
    }

 

}
