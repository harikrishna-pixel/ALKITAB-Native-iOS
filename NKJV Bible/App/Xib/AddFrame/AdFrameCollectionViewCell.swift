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
    private var lastSummarySize: CGSize = .zero
    private var lastMarkSize: CGSize = .zero
    
//    @IBOutlet weak var BibleAllOffice:UIButton!
    
    @IBOutlet weak var ADView: UIView!
//    @IBOutlet weak var AdLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lastSummarySize = .zero
        lastMarkSize = .zero
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSummaryButton()
        self.setupMarkAsReadButton()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Keep the size the list already used. Changing it animates Mark as Read and Get Summary.
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let summarySize = SummaryButton?.bounds.size ?? .zero
        let markSize = MarkAsReadBtn?.bounds.size ?? .zero
        guard summarySize != lastSummarySize || markSize != lastMarkSize else { return }
        lastSummarySize = summarySize
        lastMarkSize = markSize
        UIView.performWithoutAnimation {
            if let summaryButton = self.SummaryButton, summaryButton.bounds.height > 0 {
                summaryButton.layer.cornerRadius = summaryButton.bounds.height / 2
                self.applyGradientToSummaryButton()
            }
            self.applyMarkAsReadAppearance()
        }
    }
    
    /// Option 2 hides Get Summary. Mark as Read then uses the full row.
    func setChapterSummaryVisible(_ visible: Bool) {
        guard let summaryButton = SummaryButton else { return }
        summaryButton.isHidden = !visible
        summaryButton.isUserInteractionEnabled = visible
        guard let content = summaryButton.superview else { return }
        for constraint in content.constraints {
            let first = constraint.firstItem as? UIView
            let second = constraint.secondItem as? UIView
            if first === summaryButton && constraint.firstAttribute == .leading && second === MarkAsReadBtn {
                constraint.constant = visible ? 16 : 0
            }
            if constraint.firstAttribute == .trailing && second === summaryButton {
                constraint.constant = visible ? 16.5 : 18
            }
            if first === summaryButton && constraint.firstAttribute == .width && second === MarkAsReadBtn {
                constraint.isActive = visible
            }
        }
        let hiddenWidth = summaryButton.constraints.first { $0.identifier == "SummaryHiddenWidth" }
        if visible {
            hiddenWidth?.isActive = false
        } else if hiddenWidth == nil {
            let width = summaryButton.widthAnchor.constraint(equalToConstant: 0)
            width.identifier = "SummaryHiddenWidth"
            width.isActive = true
        } else {
            hiddenWidth?.isActive = true
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
        if themeColor == BGNightMode {
            // Night theme color matches the page background, so use light colors instead.
            button.layer.borderColor = UIColor.white.cgColor
            if isMarkedRead {
                button.backgroundColor = .white
                button.setTitle("Marked as Read", for: .normal)
                button.setTitleColor(.black, for: .normal)
            } else {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
                button.setTitle("Mark as Read", for: .normal)
                button.setTitleColor(.white, for: .normal)
            }
            return
        }
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
