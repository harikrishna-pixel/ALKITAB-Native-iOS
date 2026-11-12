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
    private var summaryRemaining: AIRemainingLineView?
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
        NotificationCenter.default.addObserver(self, selector: #selector(aiUsageChanged), name: AIUsageLimiter.usageChanged, object: nil)
    }

    @objc private func aiUsageChanged() {
        DispatchQueue.main.async {
            guard self.summaryRemaining != nil, !(self.SummaryButton?.isHidden ?? true) else { return }
            AIUsageLimiter.shared.applyLockBadge(to: self.SummaryButton, feature: .chapterSummary)
            self.updateSummaryRemaining(visible: true)
        }
    }
    
    /// Same height as the xib (88). Buttons sit inside it; only the width must follow the list.
    private static let rowHeight: CGFloat = 88

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Always the full list width. After Mark as Read reloads this cell, the list can fall back to
        // its tiny estimated size (~50pt); the buttons then shrink to a sliver ("M"). Never trust that size.
        let width = fullRowWidth(fallback: layoutAttributes.size.width)
        layoutAttributes.size = CGSize(width: width, height: Self.rowHeight)
        return layoutAttributes
    }

    private func fullRowWidth(fallback: CGFloat) -> CGFloat {
        var list: UICollectionView?
        var view: UIView? = superview
        while let current = view {
            if let collection = current as? UICollectionView {
                list = collection
                break
            }
            view = current.superview
        }
        if let list = list {
            let inset = list.adjustedContentInset
            let width = list.bounds.width - inset.left - inset.right
            if width > 100 { return width }
        }
        // Not attached yet: use a usable earlier width, else the screen.
        if fallback > 100 { return fallback }
        return UIScreen.main.bounds.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Safety net: if the list ever hands this cell a collapsed frame, ask it to re-measure.
        if bounds.width > 0, bounds.width < 100, superview != nil {
            var view: UIView? = superview
            while let current = view {
                if let collection = current as? UICollectionView {
                    DispatchQueue.main.async { collection.collectionViewLayout.invalidateLayout() }
                    break
                }
                view = current.superview
            }
        }
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

    /// "1 of 1 free summary left today" under Get Summary. Hidden for unlimited plans.
    func updateSummaryRemaining(visible: Bool) {
        guard let summaryButton = SummaryButton, let content = summaryButton.superview else { return }
        if summaryRemaining == nil && visible {
            let line = AIRemainingLineView(feature: .chapterSummary, fontSize: 10, compact: true, barHeight: 2)
            line.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(line)
            NSLayoutConstraint.activate([
                line.topAnchor.constraint(equalTo: summaryButton.bottomAnchor, constant: 3),
                line.leadingAnchor.constraint(equalTo: summaryButton.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: summaryButton.trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: 16)
            ])
            summaryRemaining = line
        }
        guard let line = summaryRemaining else { return }
        guard visible else {
            line.isHidden = true
            return
        }
        let themeColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        let isNight = themeColor == BGNightMode
        line.refresh(
            tint: isNight ? .white : themeColor,
            textColor: isNight ? UIColor.white.withAlphaComponent(0.6) : UIColor(white: 0.4, alpha: 1)
        )
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
