//
//  VerseExplanationSheetLayout.swift
//  NKJV Bible
//
//  Builds the HTML-style AI body (lead, section rules, quote, points) for
//  verse explanation and chapter summary sheets.
//

import UIKit

enum VerseExplanationSheetLayout {

    struct ChapterSummaryContent {
        var lead: String = ""
        var movements: [(title: String, detail: String)] = []
        var keys: [String] = []
        var themes: [String] = []

        var isStructured: Bool {
            !lead.isEmpty && !movements.isEmpty
        }

        var plainText: String {
            var parts: [String] = []
            if !lead.isEmpty { parts.append(lead) }
            for (index, move) in movements.enumerated() {
                parts.append("\(index + 1). \(move.title) — \(move.detail)")
            }
            if !keys.isEmpty { parts.append("Key verses: \(keys.joined(separator: ", "))") }
            if !themes.isEmpty { parts.append("Themes: \(themes.joined(separator: ", "))") }
            return parts.joined(separator: "\n\n")
        }
    }

    struct VerseExplanationContent {
        var lead: String = ""
        var context: String = ""
        var today: String = ""
        var related: [String] = []

        var isStructured: Bool {
            !lead.isEmpty && (!context.isEmpty || !today.isEmpty)
        }

        var plainText: String {
            var parts: [String] = []
            if !lead.isEmpty { parts.append(lead) }
            if !context.isEmpty { parts.append(context) }
            if !today.isEmpty { parts.append(today) }
            if !related.isEmpty { parts.append("Related: \(related.joined(separator: ", "))") }
            return parts.joined(separator: "\n\n")
        }
    }

    struct Colors {
        let ink: UIColor
        let ink2: UIColor
        let ink3: UIColor
        let accent: UIColor
        let hair: UIColor
        let isNight: Bool
    }

    static func colors(theme: UIColor) -> Colors {
        let night = theme == BGNightMode
        return Colors(
            ink: night ? UIColor.white.withAlphaComponent(0.95) : UIColor(red: 0.09, green: 0.10, blue: 0.13, alpha: 1),
            ink2: night ? UIColor.white.withAlphaComponent(0.72) : UIColor(red: 0.33, green: 0.37, blue: 0.43, alpha: 1),
            ink3: night ? UIColor.white.withAlphaComponent(0.5) : UIColor(red: 0.55, green: 0.58, blue: 0.63, alpha: 1),
            accent: night ? .white : theme,
            hair: night ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.91, green: 0.925, blue: 0.95, alpha: 1),
            isNight: night
        )
    }

    static func parseVerseExplanation(_ text: String) -> VerseExplanationContent {
        var content = VerseExplanationContent()
        let labels: Set<String> = ["LEAD", "CONTEXT", "TODAY", "RELATED"]
        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
            guard let colon = line.firstIndex(of: ":") else { continue }
            let label = line[..<colon].trimmingCharacters(in: .whitespaces).uppercased()
            guard labels.contains(label) else { continue }
            let value = line[line.index(after: colon)...]
                .trimmingCharacters(in: CharacterSet(charactersIn: "-•· ").union(.whitespacesAndNewlines))
            guard !value.isEmpty, value.uppercased() != "NONE" else { continue }
            switch label {
            case "LEAD":
                content.lead = value
            case "CONTEXT":
                content.context = content.context.isEmpty ? value : content.context + " " + value
            case "TODAY":
                content.today = content.today.isEmpty ? value : content.today + " " + value
            case "RELATED":
                content.related.append(value)
            default:
                break
            }
        }
        if content.related.count > 3 {
            content.related = Array(content.related.prefix(3))
        }
        return content
    }

    static func parseChapterSummary(_ text: String) -> ChapterSummaryContent {
        var content = ChapterSummaryContent()
        let labels: Set<String> = ["LEAD", "MOVEMENT", "KEY", "THEME"]
        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
            guard let colon = line.firstIndex(of: ":") else { continue }
            let label = line[..<colon].trimmingCharacters(in: .whitespaces).uppercased()
            guard labels.contains(label) else { continue }
            let value = line[line.index(after: colon)...]
                .trimmingCharacters(in: CharacterSet(charactersIn: "-•· ").union(.whitespacesAndNewlines))
            guard !value.isEmpty, value.uppercased() != "NONE" else { continue }
            switch label {
            case "LEAD":
                content.lead = value
            case "MOVEMENT":
                let parts = value.split(separator: "|", maxSplits: 1).map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                if parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty {
                    content.movements.append((parts[0], parts[1]))
                } else if !value.isEmpty {
                    content.movements.append((value, ""))
                }
            case "KEY":
                content.keys.append(value)
            case "THEME":
                content.themes.append(value)
            default:
                break
            }
        }
        if content.movements.count > 8 {
            content.movements = Array(content.movements.prefix(8))
        }
        if content.keys.count > 3 {
            content.keys = Array(content.keys.prefix(3))
        }
        if content.themes.count > 2 {
            content.themes = Array(content.themes.prefix(2))
        }
        return content
    }

    /// First sentence as lead; remaining paragraphs as body blocks.
    static func splitAIText(_ text: String) -> (lead: String, bodies: [String]) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", []) }

        let paragraphs = trimmed
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if paragraphs.count >= 2 {
            return (paragraphs[0], Array(paragraphs.dropFirst()))
        }

        let ends: Set<Character> = [".", "!", "?", "。", "！", "？"]
        if let idx = trimmed.firstIndex(where: { ends.contains($0) }) {
            let leadLen = trimmed.distance(from: trimmed.startIndex, to: idx)
            let restLen = trimmed.distance(from: idx, to: trimmed.endIndex) - 1
            if leadLen >= 20, restLen >= 24 {
                let after = trimmed.index(after: idx)
                let lead = String(trimmed[...idx]).trimmingCharacters(in: .whitespacesAndNewlines)
                let rest = String(trimmed[after...]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !rest.isEmpty { return (lead, [rest]) }
            }
        }
        return (trimmed, [])
    }

    static func relatedReferences(in text: String, excluding current: String) -> [String] {
        let pattern = #"\b(?:[1-3]\s)?[A-Za-zÀ-ÿ]+(?:\s[A-Za-zÀ-ÿ]+)?\s+\d{1,3}:\d{1,3}(?:\s*[-–]\s*\d{1,3})?\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let currentNorm = current.replacingOccurrences(of: "-", with: " ").lowercased()
        var seen = Set<String>()
        var out: [String] = []
        regex.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let match = match, let r = Range(match.range, in: text) else { return }
            let ref = String(text[r])
                .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let key = ref.lowercased()
            guard key != currentNorm, !seen.contains(key) else { return }
            seen.insert(key)
            out.append(ref)
        }
        return Array(out.prefix(6))
    }

    static func makeLead(_ text: String, colors: Colors) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        // HTML .ansLead: 17px / 1.48 / weight 560 / letter-spacing -0.008em / margin-bottom 24
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8
        style.alignment = .left
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: colors.ink,
            .kern: -0.14,
            .paragraphStyle: style
        ])
        return label
    }

    static func makeBody(_ text: String, colors: Colors) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: colors.ink2,
            .paragraphStyle: style
        ])
        return label
    }

    static func makeSectionRule(_ title: String, colors: Colors) -> UIView {
        // HTML `.part`: label 10.5 / weight 750 / letter-spacing .13em, gap 11, hair line.
        // Use a plain container (not HStack with a 1pt line) so the row height follows the
        // label — an HStack + 1pt line was collapsing to ~1pt and clipping headings in My Library.
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: title.uppercased(), attributes: [
            .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
            .kern: 1.37,
            .foregroundColor: colors.accent
        ])
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = colors.hair

        let row = UIView()
        row.addSubview(label)
        row.addSubview(line)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            line.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 11),
            line.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            line.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return row
    }

    static func makeScriptureQuote(_ verse: String, colors: Colors) -> UIView {
        let container = UIView()
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = colors.accent
        bar.layer.cornerRadius = 1.25
        container.addSubview(bar)

        let serifDescriptor = UIFont.systemFont(ofSize: 17).fontDescriptor.withDesign(.serif)
        let serif = serifDescriptor.map { UIFont(descriptor: $0, size: 17) } ?? UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        label.attributedText = NSAttributedString(string: verse, attributes: [
            .font: serif,
            .foregroundColor: colors.ink,
            .paragraphStyle: style
        ])
        container.addSubview(label)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            bar.widthAnchor.constraint(equalToConstant: 2.5),

            label.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    /// HTML `.tags`: flex-wrap, gap 7. Ref chips use ai tint; theme chips use border only.
    static func makeRefTags(_ refs: [String], colors: Colors, target: Any?, action: Selector) -> UIView {
        let chips: [UIView] = refs.map { ref in
            let button = UIButton(type: .system)
            button.setTitle(ref, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            button.setTitleColor(colors.accent, for: .normal)
            button.backgroundColor = colors.isNight
                ? UIColor.white.withAlphaComponent(0.1)
                : colors.accent.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
            button.addTarget(target, action: action, for: .touchUpInside)
            return button
        }
        return makeWrappingTags(chips)
    }

    static func makeThemeTags(_ themes: [String], colors: Colors) -> UIView {
        let chips: [UIView] = themes.map { theme in
            let label = PaddingLabel()
            label.text = theme
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            label.textColor = colors.ink2
            label.numberOfLines = 1
            label.insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
            label.backgroundColor = .clear
            label.layer.cornerRadius = 8
            label.layer.borderWidth = 1
            label.layer.borderColor = colors.hair.cgColor
            label.clipsToBounds = true
            return label
        }
        return makeWrappingTags(chips)
    }

    private static func makeWrappingTags(_ chips: [UIView]) -> UIView {
        let wrap = WrappingTagRow()
        wrap.spacing = 7
        wrap.lineSpacing = 7
        chips.forEach { wrap.addArrangedSubview($0) }
        return wrap
    }

    /// HTML `.beats li`: display flex; gap 13; padding 9 0; border-bottom hair-2.
    static func makeMovementRow(index: Int, title: String, detail: String, colors: Colors, showDivider: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let n = UILabel()
        n.translatesAutoresizingMaskIntoConstraints = false
        n.text = "\(index)"
        n.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        n.textColor = colors.accent
        n.textAlignment = .center
        n.backgroundColor = colors.isNight
            ? UIColor.white.withAlphaComponent(0.1)
            : colors.accent.withAlphaComponent(0.1)
        n.layer.cornerRadius = 10.5
        n.clipsToBounds = true
        container.addSubview(n)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = NSAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: colors.ink,
            .kern: -0.07
        ])
        container.addSubview(titleLabel)

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.numberOfLines = 0
        // HTML `.beats .d`: 13.4px / line-height 1.5
        let detailStyle = NSMutableParagraphStyle()
        detailStyle.lineHeightMultiple = 1.5
        detailStyle.paragraphSpacing = 0
        detailLabel.attributedText = NSAttributedString(string: detail, attributes: [
            .font: UIFont.systemFont(ofSize: 13.4, weight: .regular),
            .foregroundColor: colors.ink2,
            .paragraphStyle: detailStyle
        ])
        detailLabel.isHidden = detail.isEmpty
        container.addSubview(detailLabel)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = colors.isNight
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor(red: 0.945, green: 0.955, blue: 0.97, alpha: 1)
        divider.isHidden = !showDivider
        container.addSubview(divider)

        let textBottom = detail.isEmpty ? titleLabel.bottomAnchor : detailLabel.bottomAnchor
        NSLayoutConstraint.activate([
            // Number sits 1pt below the 9pt top padding (HTML .beats .n { margin-top: 1px }).
            n.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            n.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            n.widthAnchor.constraint(equalToConstant: 21),
            n.heightAnchor.constraint(equalToConstant: 21),

            titleLabel.leadingAnchor.constraint(equalTo: n.trailingAnchor, constant: 13),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 9),

            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: textBottom, constant: 9),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if !showDivider {
            textBottom.constraint(equalTo: container.bottomAnchor, constant: -9).isActive = true
        }

        return container
    }
}

/// Horizontal wrapping row matching HTML `.tags { flex-wrap; gap: 7px }`.
private final class WrappingTagRow: UIView {
    var spacing: CGFloat = 7
    var lineSpacing: CGFloat = 7
    private var items: [UIView] = []
    private var measuredHeight: CGFloat = 30

    func addArrangedSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        items.append(view)
        addSubview(view)
        setNeedsLayout()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: measuredHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxWidth = max(bounds.width, 1)
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for item in items {
            let size = item.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .required
            )
            let width = min(max(ceil(size.width), 1), maxWidth)
            let height = max(ceil(size.height), 30)
            if x > 0, x + width > maxWidth {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            item.frame = CGRect(x: x, y: y, width: width, height: height)
            x += width + spacing
            rowHeight = max(rowHeight, height)
        }

        let height = y + rowHeight
        if abs(measuredHeight - height) > 0.5 {
            measuredHeight = max(height, 30)
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
        }
    }
}

private final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets.zero
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
