//
//  SettingsTableCell.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 11/02/21.
//

import UIKit

class SettingsTableCell: UITableViewCell {

    @IBOutlet var themeColor: UIView!
    @IBOutlet var FontStyle: UILabel!
    @IBOutlet var NotifiSwitch: UISwitch!
    @IBOutlet var NotifiTime: UILabel!
    
    @IBOutlet var NotifiMorningTime: UILabel!
    @IBOutlet var NotifiEveningTime: UILabel!
    @IBOutlet var NotifiNightTime: UILabel!
    
    @IBOutlet var Notifications: UILabel!
    @IBOutlet var NotificationTime: UILabel!
    @IBOutlet var FontType: UILabel!
    @IBOutlet var Theme: UILabel!
    @IBOutlet var Feedback: UILabel!
    @IBOutlet var AboutUs: UILabel!
    @IBOutlet var RateUs: UILabel!
    @IBOutlet var MoreApp: UILabel!
    @IBOutlet var Help: UILabel!
    @IBOutlet var Quiz: UILabel!
    
    @IBOutlet var Notification: UILabel!
    @IBOutlet var FontTheme: UILabel!
    @IBOutlet var AboutApp: UILabel!
    @IBOutlet var Support: UILabel!
    
    @IBOutlet var arrow1: UIImageView!
    @IBOutlet var arrow2: UIImageView!
    @IBOutlet var arrow3: UIImageView!

    enum CardEdge {
        case single, top, middle, bottom
    }

    var cardEdge: CardEdge = .single
    private let cardView = UIView()
    private let cardLine = UIView()
    private var addedChevron: UIImageView?
    /// Drawn above the card on the first row of a section so titles never pin over rows (plain-table sticky headers).
    private let sectionTitleLabel = UILabel()
    private var showsSectionTitle = false
    static let sectionTitleBand: CGFloat = 32

    let Themecolor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func applyCard(edge: CardEdge, night: Bool, sectionTitle: String? = nil) {
        cardEdge = edge
        showsSectionTitle = !(sectionTitle?.isEmpty ?? true)
        if cardView.superview == nil {
            cardView.isUserInteractionEnabled = false
            insertSubview(cardView, at: 0)
            cardLine.backgroundColor = UIColor(white: 0.90, alpha: 1)
            cardLine.isUserInteractionEnabled = false
            contentView.addSubview(cardLine)
        }
        if sectionTitleLabel.superview == nil {
            sectionTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            sectionTitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
            sectionTitleLabel.isUserInteractionEnabled = false
            insertSubview(sectionTitleLabel, aboveSubview: cardView)
        }
        sectionTitleLabel.text = sectionTitle
        sectionTitleLabel.isHidden = !showsSectionTitle
        // Old storyboard header labels inside prototype cells must stay hidden.
        Notification?.isHidden = true
        FontTheme?.isHidden = true
        AboutApp?.isHidden = true
        Support?.isHidden = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.isOpaque = false
        clipsToBounds = false
        selectionStyle = .none
        cardView.backgroundColor = night ? UIColor(white: 0.16, alpha: 1) : .white
        cardLine.backgroundColor = night ? UIColor(white: 1, alpha: 0.08) : UIColor(white: 0.90, alpha: 1)
        for view in contentView.subviews {
            let hairline = view.constraints.contains { $0.firstAttribute == .height && $0.constant > 0 && $0.constant < 1 }
            if hairline { view.isHidden = true }
        }
        for image in contentView.subviews.compactMap({ $0 as? UIImageView }) where image !== addedChevron {
            let badge = image.constraints.contains { $0.firstAttribute == .width && $0.constant == 20 }
            if badge { image.isHidden = true }
        }
        let hasArrow = contentView.subviews.contains { view in
            guard let image = view as? UIImageView else { return false }
            return image.constraints.contains { $0.firstAttribute == .width && $0.constant == 16 }
        }
        if !hasArrow && addedChevron == nil {
            let arrow = UIImageView(image: UIImage(named: "SettingsArrow"))
            arrow.translatesAutoresizingMaskIntoConstraints = false
            arrow.contentMode = .scaleAspectFit
            contentView.addSubview(arrow)
            NSLayoutConstraint.activate([
                arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                arrow.widthAnchor.constraint(equalToConstant: 16),
                arrow.heightAnchor.constraint(equalToConstant: 16)
            ])
            addedChevron = arrow
        }
        layoutMargins = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: themeColor == nil ? 36 : 62)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 16
        let titleBand = showsSectionTitle ? SettingsTableCell.sectionTitleBand : 0
        // Keep row labels/chevrons in the card band only — title sits above and scrolls with the row.
        contentView.frame = CGRect(x: 0, y: titleBand, width: bounds.width, height: max(0, bounds.height - titleBand))
        if showsSectionTitle {
            sectionTitleLabel.frame = CGRect(
                x: 20,
                y: titleBand - 20,
                width: max(0, bounds.width - 40),
                height: 16
            )
        }
        cardView.frame = CGRect(
            x: inset,
            y: titleBand,
            width: max(0, bounds.width - inset * 2),
            height: max(0, bounds.height - titleBand)
        )
        cardView.layer.cornerRadius = cardEdge == .middle ? 0 : 14
        switch cardEdge {
        case .single:
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cardLine.isHidden = true
        case .top:
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cardLine.isHidden = false
        case .middle:
            cardLine.isHidden = false
        case .bottom:
            cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cardLine.isHidden = true
        }
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = cardEdge == .middle ? 0 : 0.05
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardLine.frame = CGRect(x: 36, y: contentView.bounds.height - 0.5, width: max(0, bounds.width - 72), height: 0.5)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        showsSectionTitle = false
        sectionTitleLabel.isHidden = true
        sectionTitleLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}






class NotificationTableCell: UITableViewCell {
    
    @IBOutlet var NotifiMorningTime: UILabel!
    @IBOutlet var NotifiEveningTime: UILabel!
    @IBOutlet var NotifiNightTime: UILabel!
    @IBOutlet var NotifiQuizTime: UILabel!
    
    @IBOutlet var Shift1Switch: UISwitch!
    @IBOutlet var Shift2Switch: UISwitch!
    @IBOutlet var Shift3Switch: UISwitch!
    @IBOutlet var Shift4Switch: UISwitch!
    @IBOutlet var FAQ: UIButton!
    
    
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}



