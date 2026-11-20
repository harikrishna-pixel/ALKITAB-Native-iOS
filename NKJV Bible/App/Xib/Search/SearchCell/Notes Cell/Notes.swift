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
    private let contentStack = UIStackView()
    private var explanationBottomConstraint: NSLayoutConstraint?
    private var verseBottomCollapsedConstraint: NSLayoutConstraint?
    private var dividerBelowVerseConstraint: NSLayoutConstraint?
    private var dividerBelowHeaderConstraint: NSLayoutConstraint?

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
        verseLabel.numberOfLines = 2
        verseLabel.isHidden = isExpanded

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
        contentStack.isHidden = !isExpanded
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if isExpanded {
            fillStructuredContent(
                explanation: explanation,
                themeColor: themeColor,
                isNight: isNight,
                bodyFont: bodyFont ?? .systemFont(ofSize: 14)
            )
            verseBottomCollapsedConstraint?.isActive = false
            dividerBelowVerseConstraint?.isActive = false
            dividerBelowHeaderConstraint?.isActive = true
            explanationBottomConstraint?.isActive = true
        } else {
            explanationBottomConstraint?.isActive = false
            dividerBelowHeaderConstraint?.isActive = false
            dividerBelowVerseConstraint?.isActive = true
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

        let fullVerse = ceil((verseText as NSString).boundingRect(
            with: CGSize(width: verseWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: verseFont],
            context: nil
        ).height)
        let verseHeight = min(fullVerse, ceil(verseFont.lineHeight * 2))

        // pads + header (action circles) + collapsed verse preview + bottom pad
        var height: CGFloat = 8 + 12 + Self.actionCircleSize + 8 + (isExpanded ? 0 : verseHeight) + 14 + 8

        if isExpanded {
            height += 12 + 1 + 12
            height += structuredContentHeight(
                explanation: explanation,
                width: contentWidth,
                bodyFont: bodyFont
            )
            // Extra room so section headings / theme chips are not clipped by clipsToBounds.
            height += 16
        }

        return height
    }

    private func fillStructuredContent(
        explanation: String,
        themeColor: UIColor,
        isNight: Bool,
        bodyFont: UIFont
    ) {
        let colors = VerseExplanationSheetLayout.colors(theme: isNight ? BGNightMode : themeColor)
        let summaryTitleColor = isNight
            ? UIColor.white.withAlphaComponent(0.55)
            : UIColor(white: 0.45, alpha: 1)

        // Chapter summaries first — LEAD alone must not be treated as a verse explanation.
        let chapterParsed = VerseExplanationSheetLayout.parseChapterSummary(explanation)
        if Self.hasChapterStructure(chapterParsed) {
            appendChapterSections(chapterParsed, colors: colors, summaryTitleColor: summaryTitleColor)
            return
        }

        let verseParsed = VerseExplanationSheetLayout.parseVerseExplanation(explanation)
        if verseParsed.isStructured || (!verseParsed.lead.isEmpty && !verseParsed.related.isEmpty) {
            appendVerseSections(verseParsed, colors: colors, summaryTitleColor: summaryTitleColor)
            return
        }

        // Older freeform saves — keep a plain Summary block.
        let title = summaryTitleLabel(color: summaryTitleColor)
        contentStack.addArrangedSubview(title)
        contentStack.setCustomSpacing(8, after: title)
        let body = plainBodyLabel(explanation, font: bodyFont, color: colors.ink)
        contentStack.addArrangedSubview(body)
    }

    private static func hasChapterStructure(_ parsed: VerseExplanationSheetLayout.ChapterSummaryContent) -> Bool {
        parsed.isStructured
            || !parsed.movements.isEmpty
            || !parsed.keys.isEmpty
            || !parsed.themes.isEmpty
    }

    private func appendVerseSections(
        _ parsed: VerseExplanationSheetLayout.VerseExplanationContent,
        colors: VerseExplanationSheetLayout.Colors,
        summaryTitleColor: UIColor
    ) {
        if !parsed.lead.isEmpty {
            let title = summaryTitleLabel(color: summaryTitleColor)
            contentStack.addArrangedSubview(title)
            contentStack.setCustomSpacing(8, after: title)
            let lead = VerseExplanationSheetLayout.makeBody(parsed.lead, colors: colors)
            // Lead under Summary reads a bit stronger than section body.
            if let attributed = lead.attributedText {
                let mutable = NSMutableAttributedString(attributedString: attributed)
                mutable.addAttribute(.foregroundColor, value: colors.ink, range: NSRange(location: 0, length: mutable.length))
                lead.attributedText = mutable
            }
            contentStack.addArrangedSubview(lead)
            contentStack.setCustomSpacing(18, after: lead)
        }
        if !parsed.context.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("In context", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            let body = VerseExplanationSheetLayout.makeBody(parsed.context, colors: colors)
            contentStack.addArrangedSubview(body)
            contentStack.setCustomSpacing(18, after: body)
        }
        if !parsed.today.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("What it means today", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            let body = VerseExplanationSheetLayout.makeBody(parsed.today, colors: colors)
            contentStack.addArrangedSubview(body)
            contentStack.setCustomSpacing(18, after: body)
        }
        if !parsed.related.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Related verses", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            let tags = VerseExplanationSheetLayout.makeRefTags(
                parsed.related,
                colors: colors,
                target: self,
                action: #selector(relatedPillTapped)
            )
            contentStack.addArrangedSubview(tags)
        }
    }

    private func appendChapterSections(
        _ parsed: VerseExplanationSheetLayout.ChapterSummaryContent,
        colors: VerseExplanationSheetLayout.Colors,
        summaryTitleColor: UIColor
    ) {
        if !parsed.lead.isEmpty {
            let title = summaryTitleLabel(color: summaryTitleColor)
            contentStack.addArrangedSubview(title)
            contentStack.setCustomSpacing(8, after: title)
            let lead = VerseExplanationSheetLayout.makeBody(parsed.lead, colors: colors)
            contentStack.addArrangedSubview(lead)
            contentStack.setCustomSpacing(18, after: lead)
        }
        if !parsed.movements.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Movements", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            for (index, move) in parsed.movements.enumerated() {
                let row = VerseExplanationSheetLayout.makeMovementRow(
                    index: index + 1,
                    title: move.title,
                    detail: move.detail,
                    colors: colors,
                    showDivider: index < parsed.movements.count - 1
                )
                contentStack.addArrangedSubview(row)
            }
            if let last = contentStack.arrangedSubviews.last {
                contentStack.setCustomSpacing(18, after: last)
            }
        }
        if !parsed.keys.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Key verses", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            let tags = VerseExplanationSheetLayout.makeRefTags(
                parsed.keys,
                colors: colors,
                target: self,
                action: #selector(relatedPillTapped)
            )
            contentStack.addArrangedSubview(tags)
            contentStack.setCustomSpacing(18, after: tags)
        }
        if !parsed.themes.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Themes", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(10, after: rule)
            contentStack.addArrangedSubview(VerseExplanationSheetLayout.makeThemeTags(parsed.themes, colors: colors))
        }
    }

    private func summaryTitleLabel(color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = "Summary"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = color
        return label
    }

    private func plainBodyLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacing = 6
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
        return label
    }

    @objc private func relatedPillTapped() {
        // Display-only chips in My Library.
    }

    private static func structuredContentHeight(
        explanation: String,
        width: CGFloat,
        bodyFont: UIFont
    ) -> CGFloat {
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.lineSpacing = 5

        func textHeight(_ text: String, font: UIFont, style: NSParagraphStyle? = nil) -> CGFloat {
            var attrs: [NSAttributedString.Key: Any] = [.font: font]
            if let style = style { attrs[.paragraphStyle] = style }
            return ceil((text as NSString).boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            ).height)
        }

        let chapterParsed = VerseExplanationSheetLayout.parseChapterSummary(explanation)
        if hasChapterStructure(chapterParsed) {
            var h: CGFloat = 0
            if !chapterParsed.lead.isEmpty {
                h += 18 + 8 + textHeight(chapterParsed.lead, font: .systemFont(ofSize: 15), style: bodyStyle) + 18
            }
            if !chapterParsed.movements.isEmpty {
                h += 18 + 10
                for move in chapterParsed.movements {
                    h += 12 + textHeight(move.title, font: .systemFont(ofSize: 14, weight: .semibold))
                    if !move.detail.isEmpty {
                        h += 2 + textHeight(move.detail, font: .systemFont(ofSize: 13.4), style: bodyStyle)
                    }
                    h += 18
                }
            }
            if !chapterParsed.keys.isEmpty { h += 18 + 10 + 40 + 18 }
            if !chapterParsed.themes.isEmpty {
                // Themes can wrap to multiple rows of chips.
                let rows = max(1, Int(ceil(Double(chapterParsed.themes.count) / 2.0)))
                h += 18 + 10 + CGFloat(rows) * 36
            }
            return h
        }

        let verseParsed = VerseExplanationSheetLayout.parseVerseExplanation(explanation)
        if verseParsed.isStructured || (!verseParsed.lead.isEmpty && !verseParsed.related.isEmpty) {
            var h: CGFloat = 0
            if !verseParsed.lead.isEmpty {
                h += 18 + 8 + textHeight(verseParsed.lead, font: .systemFont(ofSize: 15), style: bodyStyle) + 18
            }
            if !verseParsed.context.isEmpty {
                h += 18 + 10 + textHeight(verseParsed.context, font: .systemFont(ofSize: 15), style: bodyStyle) + 18
            }
            if !verseParsed.today.isEmpty {
                h += 18 + 10 + textHeight(verseParsed.today, font: .systemFont(ofSize: 15), style: bodyStyle) + 18
            }
            if !verseParsed.related.isEmpty {
                h += 18 + 10 + 40
            }
            return h
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.paragraphSpacing = 6
        return 18 + 8 + textHeight(explanation, font: bodyFont, style: paragraph)
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

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        cardView.addSubview(contentStack)

        let explanationBottom = contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        explanationBottomConstraint = explanationBottom
        let verseBottomCollapsed = verseLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        verseBottomCollapsedConstraint = verseBottomCollapsed
        let dividerBelowVerse = divider.topAnchor.constraint(equalTo: verseLabel.bottomAnchor, constant: 12)
        dividerBelowVerseConstraint = dividerBelowVerse
        let dividerBelowHeader = divider.topAnchor.constraint(equalTo: menuCircle.bottomAnchor, constant: 12)
        dividerBelowHeaderConstraint = dividerBelowHeader
        dividerBelowVerse.isActive = true

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            menuCircle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            menuCircle.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            menuCircle.widthAnchor.constraint(equalToConstant: Self.actionCircleSize),
            menuCircle.heightAnchor.constraint(equalToConstant: Self.actionCircleSize),

            chevronCircle.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            chevronCircle.trailingAnchor.constraint(equalTo: menuCircle.leadingAnchor, constant: -8),
            chevronCircle.widthAnchor.constraint(equalToConstant: Self.actionCircleSize),
            chevronCircle.heightAnchor.constraint(equalToConstant: Self.actionCircleSize),

            chevronImageView.centerXAnchor.constraint(equalTo: chevronCircle.centerXAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: chevronCircle.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),

            menuImageView.centerXAnchor.constraint(equalTo: menuCircle.centerXAnchor),
            menuImageView.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            menuImageView.widthAnchor.constraint(equalToConstant: 20),
            menuImageView.heightAnchor.constraint(equalToConstant: 20),

            menuBtn.centerXAnchor.constraint(equalTo: menuCircle.centerXAnchor),
            menuBtn.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            menuBtn.widthAnchor.constraint(equalToConstant: Self.actionHitSize),
            menuBtn.heightAnchor.constraint(equalToConstant: Self.actionHitSize),

            referenceLabel.centerYAnchor.constraint(equalTo: menuCircle.centerYAnchor),
            referenceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            referenceLabel.trailingAnchor.constraint(equalTo: chevronCircle.leadingAnchor, constant: -8),
            referenceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),

            verseLabel.topAnchor.constraint(equalTo: menuCircle.bottomAnchor, constant: 10),
            verseLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            verseLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 1),

            contentStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            verseBottomCollapsed
        ])
    }
}
