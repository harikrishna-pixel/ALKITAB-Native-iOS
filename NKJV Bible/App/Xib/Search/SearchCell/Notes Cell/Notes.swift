//
//  Notes.swift
//  Audio Bible
//
//  Created by Axeraan Technologies on 17/02/21.
//

import UIKit

class Notes: UICollectionViewCell {
    
    
    @IBOutlet var VerseLbl: UILabel!
    @IBOutlet var MenuBtn: UIButton!
    @IBOutlet var VerseTitle: UILabel!
    @IBOutlet var NoteLbl: UILabel!
    @IBOutlet var NoteTitle: UILabel!
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var DottedLines: UIView!
    @IBOutlet weak var Noteheight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

/// Accordion card for My Library → Explanations (does not change Notes tab layout).
final class ExplanationLibraryCell: UICollectionViewCell {

    static let reuseId = "ExplanationLibraryCell"

    let menuBtn = UIButton(type: .custom)
    private let cardView = UIView()
    private let menuCircle = UIView()
    private let chevronCircle = UIView()
    private let menuImageView = UIImageView()
    private let chevronImageView = UIImageView()
    private let referenceLabel = UILabel()
    private let verseLabel = UILabel()
    private let divider = UIView()
    private let explanationTitleLabel = UILabel()
    private let explanationBodyLabel = UILabel()
    private var explanationBottomConstraint: NSLayoutConstraint?
    private var verseBottomCollapsedConstraint: NSLayoutConstraint?

    private static let actionCircleSize: CGFloat = 36
    private static let actionIconPointSize: CGFloat = 15
    private static let actionHitSize: CGFloat = 44

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(
        verseText: String,
        reference: String,
        explanation: String,
        themeColor: UIColor,
        isNight: Bool,
        verseFont: UIFont?,
        bodyFont: UIFont?,
        menuTint: UIColor,
        isExpanded: Bool
    ) {
        referenceLabel.text = reference
        referenceLabel.textColor = isNight ? .white : .black

        verseLabel.text = verseText
        verseLabel.font = verseFont ?? .systemFont(ofSize: 15)
        verseLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.9) : UIColor(white: 0.2, alpha: 1)
        verseLabel.numberOfLines = isExpanded ? 0 : 2

        explanationTitleLabel.text = "Explanation"
        explanationTitleLabel.textColor = themeColor

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacing = 6
        explanationBodyLabel.attributedText = NSAttributedString(
            string: explanation,
            attributes: [
                .font: bodyFont ?? UIFont.systemFont(ofSize: 14),
                .foregroundColor: isNight ? UIColor.white.withAlphaComponent(0.92) : UIColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 1),
                .paragraphStyle: paragraph
            ]
        )

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: Self.actionIconPointSize, weight: .semibold)
        chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tintColor = isExpanded ? themeColor : (isNight ? UIColor.white.withAlphaComponent(0.7) : UIColor(white: 0.35, alpha: 1))
        menuImageView.image = UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)?.withRenderingMode(.alwaysTemplate)
        menuImageView.tintColor = menuTint

        let circleFill = isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.90, green: 0.93, blue: 0.97, alpha: 1)
        menuCircle.backgroundColor = circleFill
        chevronCircle.backgroundColor = circleFill

        cardView.backgroundColor = isNight ? DarkModeColor : .white
        let border = isExpanded
            ? themeColor.withAlphaComponent(isNight ? 0.55 : 0.35)
            : (isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.82, green: 0.88, blue: 0.96, alpha: 1))
        cardView.layer.borderColor = border.cgColor
        divider.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.82, green: 0.88, blue: 0.96, alpha: 1)

        divider.isHidden = !isExpanded
        explanationTitleLabel.isHidden = !isExpanded
        explanationBodyLabel.isHidden = !isExpanded
        if isExpanded {
            verseBottomCollapsedConstraint?.isActive = false
            explanationBottomConstraint?.isActive = true
        } else {
            explanationBottomConstraint?.isActive = false
            verseBottomCollapsedConstraint?.isActive = true
        }
    }

    static func preferredHeight(
        width: CGFloat,
        verseText: String,
        explanation: String,
        verseFont: UIFont,
        bodyFont: UIFont,
        isExpanded: Bool
    ) -> CGFloat {
        let contentWidth = max(width - 52, 120)
        let verseWidth = contentWidth - 8

        let verseHeight: CGFloat
        if isExpanded {
            verseHeight = ceil((verseText as NSString).boundingRect(
                with: CGSize(width: verseWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: verseFont],
                context: nil
            ).height)
        } else {
            let full = ceil((verseText as NSString).boundingRect(
                with: CGSize(width: verseWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: verseFont],
                context: nil
            ).height)
            verseHeight = min(full, ceil(verseFont.lineHeight * 2))
        }

        // pads + header (action circles) + verse + bottom pad
        var height: CGFloat = 8 + 12 + Self.actionCircleSize + 8 + verseHeight + 14 + 8

        if isExpanded {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 4
            paragraph.paragraphSpacing = 6
            let bodyHeight = ceil((explanation as NSString).boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: bodyFont, .paragraphStyle: paragraph],
                context: nil
            ).height)
            // divider + title + body gaps (replaces simple bottom pad already counted partially)
            height += 12 + 1 + 12 + 18 + 8 + bodyHeight + 4
        }

        return height
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)

        referenceLabel.translatesAutoresizingMaskIntoConstraints = false
        referenceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        referenceLabel.numberOfLines = 1
        referenceLabel.textAlignment = .left
        cardView.addSubview(referenceLabel)

        func styleCircle(_ view: UIView) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = Self.actionCircleSize / 2
            view.clipsToBounds = true
            view.isUserInteractionEnabled = false
            cardView.addSubview(view)
        }
        styleCircle(chevronCircle)
        styleCircle(menuCircle)

        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.isUserInteractionEnabled = false
        cardView.addSubview(chevronImageView)

        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuImageView.contentMode = .scaleAspectFit
        menuImageView.isUserInteractionEnabled = false
        cardView.addSubview(menuImageView)

        menuBtn.translatesAutoresizingMaskIntoConstraints = false
        menuBtn.accessibilityLabel = "More"
        cardView.addSubview(menuBtn)

        verseLabel.translatesAutoresizingMaskIntoConstraints = false
        verseLabel.textAlignment = .left
        cardView.addSubview(verseLabel)

        divider.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(divider)

        explanationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        cardView.addSubview(explanationTitleLabel)

        explanationBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationBodyLabel.numberOfLines = 0
        explanationBodyLabel.textAlignment = .left
        cardView.addSubview(explanationBodyLabel)

        let explanationBottom = explanationBodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        explanationBottomConstraint = explanationBottom
        let verseBottomCollapsed = verseLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        verseBottomCollapsedConstraint = verseBottomCollapsed

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            chevronCircle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            chevronCircle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            chevronCircle.widthAnchor.constraint(equalToConstant: Self.actionCircleSize),
            chevronCircle.heightAnchor.constraint(equalToConstant: Self.actionCircleSize),

            chevronImageView.centerXAnchor.constraint(equalTo: chevronCircle.centerXAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: chevronCircle.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),

            menuCircle.centerYAnchor.constraint(equalTo: chevronCircle.centerYAnchor),
            menuCircle.trailingAnchor.constraint(equalTo: chevronCircle.leadingAnchor, constant: -8),
            menuCircle.widthAnchor.constraint(equalToConstant: Self.actionCircleSize),
            menuCircle.heightAnchor.constraint(equalToConstant: Self.actionCircleSize),

            menuImageView.centerXAnchor.constraint(equalTo: menuCircle.centerXAnchor),
            menuImageView.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            menuImageView.widthAnchor.constraint(equalToConstant: 20),
            menuImageView.heightAnchor.constraint(equalToConstant: 20),

            menuBtn.centerXAnchor.constraint(equalTo: menuCircle.centerXAnchor),
            menuBtn.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            menuBtn.widthAnchor.constraint(equalToConstant: Self.actionHitSize),
            menuBtn.heightAnchor.constraint(equalToConstant: Self.actionHitSize),

            referenceLabel.centerYAnchor.constraint(equalTo: chevronCircle.centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            referenceLabel.trailingAnchor.constraint(equalTo: menuCircle.leadingAnchor, constant: -8),
            referenceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),

            verseLabel.topAnchor.constraint(equalTo: chevronCircle.bottomAnchor, constant: 10),
            verseLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            verseLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            divider.topAnchor.constraint(equalTo: verseLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),

            explanationTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            explanationTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            explanationTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            explanationBodyLabel.topAnchor.constraint(equalTo: explanationTitleLabel.bottomAnchor, constant: 8),
            explanationBodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            explanationBodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            verseBottomCollapsed
        ])
    }
}
