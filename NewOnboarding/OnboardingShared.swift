//
//  OnboardingShared.swift
//  NKJV Bible
//

import SwiftUI

enum OnboardingTheme {
    static let primaryBlue = Color(hex: "2563EB")
    static let primaryBlueDark = Color(hex: "1B49C4")
    static let navy = Color(hex: "0A1A38")
    static let navyMid = Color(hex: "153769")
    static let gold = Color(hex: "E8A317")
    static let goldInk = Color(hex: "28190A")
    static let paper = Color(hex: "F6F9FD")
    static let paperLine = Color(hex: "DCE6F3")
    static let paperInk = Color(hex: "16233C")
    static let grow = Color(hex: "15803D")
    static let growBg = Color(hex: "E8F6EE")
    static let growLine = Color(hex: "A9DEC0")
    static let softGray = Color(hex: "F5F6FA")
    static let textSecondary = Color(hex: "5A6D8C")
    static let dim = Color(hex: "93A8C9")
    static let teal = Color(hex: "22B8A6")

    static var brandTitle: String {
        let name = (APPNAME_SPLASH.isEmpty ? APPNAME : APPNAME_SPLASH).uppercased()
        return name.isEmpty ? "BIBLE" : name
    }

    static var darkPageGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "0A1A38"), Color(hex: "153769"), Color(hex: "0C2149")],
            startPoint: UnitPoint(x: 0.35, y: 0),
            endPoint: UnitPoint(x: 0.65, y: 1)
        )
    }
}

enum OnboardingProgress {
    private static let startedKey = "OnboardingStarted"
    private static let completedKey = "OnboardingCompleted"

    static var shouldShow: Bool {
        UserDefaults.standard.bool(forKey: startedKey)
            && !UserDefaults.standard.bool(forKey: completedKey)
    }

    static func markStarted() {
        UserDefaults.standard.set(true, forKey: startedKey)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }
}

/// Philippians 4:13 from the installed Bible (Alkitab / current translation).
enum OnboardingBibleVerse {
    private static let fallbackText = "For I can do everything through Christ, who gives me strength."
    private static let fallbackReference = "Philippians 4:13"
    private static let fallbackTokens = ["For", "I", "can", "do", "everything", "through", "Christ,", "who", "gives", "me", "strength."]
    private static let fallbackBlankIndices = [1, 3, 5, 10]
    private static let fallbackOptions = ["I", "do", "through", "strength"]

    private static var cachedLanguage: String?
    private static var cachedPayload: (
        text: String,
        reference: String,
        tokens: [String],
        blankIndices: [Int],
        options: [String]
    )?

    static var text: String { payload.text }
    static var reference: String { payload.reference }
    static var tokens: [String] { payload.tokens }
    static var blankIndices: [Int] { payload.blankIndices }
    static var options: [String] { payload.options }

    private static var payload: (
        text: String,
        reference: String,
        tokens: [String],
        blankIndices: [Int],
        options: [String]
    ) {
        let language = UserDefaults.standard.string(forKey: "SelectedLanguage")
        if let cachedPayload, cachedLanguage == language {
            return cachedPayload
        }

        let built = buildVerse(language: language)
        cachedLanguage = language
        cachedPayload = built
        return built
    }

    private static func buildVerse(language: String?) -> (
        text: String,
        reference: String,
        tokens: [String],
        blankIndices: [Int],
        options: [String]
    ) {
        guard language != nil else {
            return (fallbackText, fallbackReference, fallbackTokens, fallbackBlankIndices, fallbackOptions)
        }

        let books = BibleContent.sharedInstance.BookToPosition()
        let bookIndex = 49
        guard bookIndex < books.count else {
            return (fallbackText, fallbackReference, fallbackTokens, fallbackBlankIndices, fallbackOptions)
        }

        let bookName = books[bookIndex].components(separatedBy: "-")[0]
        let verses = BibleContent.sharedInstance.AudioBibleList(selecterBookName: bookName, selectedId: 3)
        let verseIndex = 12
        guard verseIndex < verses.count else {
            return (fallbackText, fallbackReference, fallbackTokens, fallbackBlankIndices, fallbackOptions)
        }

        let text = verses[verseIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return (fallbackText, fallbackReference, fallbackTokens, fallbackBlankIndices, fallbackOptions)
        }

        let tokens = text.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        let candidates = tokens.enumerated().compactMap { idx, word -> (Int, String)? in
            let cleaned = word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            guard cleaned.count >= 3 else { return nil }
            return (idx, cleaned)
        }

        var picked = Array(candidates.shuffled().prefix(4))
        if picked.count < 4 {
            let extras = tokens.enumerated().compactMap { idx, word -> (Int, String)? in
                guard !picked.contains(where: { $0.0 == idx }) else { return nil }
                let cleaned = word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                guard !cleaned.isEmpty else { return nil }
                return (idx, cleaned)
            }
            for item in extras where picked.count < 4 {
                picked.append(item)
            }
        }

        let blankIndices = picked.map { $0.0 }.sorted()
        let options = blankIndices.map {
            tokens[$0].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        }.shuffled()

        guard blankIndices.count == 4, options.count == 4 else {
            return (fallbackText, fallbackReference, fallbackTokens, fallbackBlankIndices, fallbackOptions)
        }

        return (text, "\(bookName) 4:13", tokens, blankIndices, options)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingPageDots: View {
    let current: Int
    let total: Int
    var onDark: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(
                        index == current
                            ? (onDark ? Color.white : OnboardingTheme.primaryBlue)
                            : (onDark ? Color.white.opacity(0.28) : Color(hex: "C4D2E6"))
                    )
                    .frame(width: index == current ? 18 : 6, height: 6)
            }
        }
    }
}

/// Top brand lockup matching onboarding mock (larger app name).
struct OnboardingBrandHeader: View {
    var lightContent: Bool = true

    var body: some View {
        let parts = OnboardingTheme.brandTitle
            .split(separator: " ")
            .map(String.init)
        VStack(spacing: 4) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 16, weight: .semibold))
            if parts.count >= 2 {
                Text(parts[0])
                    .font(.system(size: 28, weight: .bold))
                    .tracking(1)
                Text(parts.dropFirst().joined(separator: " "))
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(3)
            } else {
                Text(OnboardingTheme.brandTitle)
                    .font(.system(size: 26, weight: .bold))
                    .tracking(2)
            }
        }
        .foregroundColor(lightContent ? .white : OnboardingTheme.navy)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingPrimaryLink<Destination: View>: View {
    let title: String
    var isEnabled: Bool = true
    var onDark: Bool = true
    let destination: Destination

    var body: some View {
        if isEnabled {
            NavigationLink(destination: destination) {
                OnboardingButtonLabel(title: title, style: .primary, isEnabled: true, onDark: onDark)
            }
        } else {
            OnboardingButtonLabel(title: title, style: .primary, isEnabled: false, onDark: onDark)
        }
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var onDark: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            OnboardingButtonLabel(title: title, style: .primary, isEnabled: isEnabled, onDark: onDark)
        }
        .disabled(!isEnabled)
    }
}

struct OnboardingGhostButton: View {
    let title: String
    var onDark: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            OnboardingButtonLabel(title: title, style: .ghost, isEnabled: true, onDark: onDark)
        }
    }
}

struct OnboardingOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            OnboardingButtonLabel(title: title, style: .outline, isEnabled: true)
        }
    }
}

private enum OnboardingButtonStyleKind {
    case primary, ghost, outline
}

private struct OnboardingButtonLabel: View {
    let title: String
    let style: OnboardingButtonStyleKind
    var isEnabled: Bool = true
    var onDark: Bool = true

    var body: some View {
        Text(title)
            .font(.system(size: style == .ghost ? 14.5 : 16.5, weight: style == .outline ? .semibold : .bold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, style == .ghost ? 13 : 17)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: style == .outline ? 15 : 15)
                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
            .cornerRadius(15)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? .white : (onDark ? Color(hex: "8FA2BF") : Color(hex: "8C9BB2"))
        case .ghost:
            return onDark ? Color(hex: "9DB4D8") : OnboardingTheme.textSecondary
        case .outline:
            return OnboardingTheme.paperInk
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? OnboardingTheme.primaryBlue : (onDark ? Color(hex: "3F5578") : Color(hex: "CBD7E7"))
        case .ghost:
            return Color.clear
        case .outline:
            return .white
        }
    }

    private var borderColor: Color {
        style == .outline ? OnboardingTheme.paperLine : .clear
    }
}

struct OnboardingSkipButton: View {
    var onLight: Bool = false

    var body: some View {
        Button(action: {
            UIKitNavigationHelper.navigateToIAPView()
        }) {
            Text("Skip")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(onLight ? Color(hex: "7488A6") : OnboardingTheme.dim)
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
        }
    }
}

struct OnboardingTopBar: View {
    var onLight: Bool = false

    var body: some View {
        HStack {
            Spacer()
            OnboardingSkipButton(onLight: onLight)
        }
        .frame(height: 30)
    }
}

struct OnboardingBrandTag: View {
    var body: some View {
        Text(OnboardingTheme.brandTitle)
            .font(.system(size: 10.5, weight: .bold))
            .tracking(4.2)
            .foregroundColor(Color(hex: "7E97BE"))
            .padding(.leading, 4.2)
    }
}

struct OnboardingGoldOrnament: View {
    var body: some View {
        HStack(spacing: 13) {
            LinearGradient(
                colors: [OnboardingTheme.gold.opacity(0), OnboardingTheme.gold.opacity(0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 58, height: 1)
            Text("✦")
                .font(.system(size: 10))
                .foregroundColor(OnboardingTheme.gold)
            LinearGradient(
                colors: [OnboardingTheme.gold.opacity(0.6), OnboardingTheme.gold.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 58, height: 1)
        }
        .padding(.vertical, 4)
    }
}

struct OnboardingPillarRow: View {
    let items: [(symbol: String, title: String)]

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Circle()
                        .fill(OnboardingTheme.gold.opacity(0.65))
                        .frame(width: 4, height: 4)
                        .padding(.top, 25)
                }
                VStack(spacing: 10) {
                    Image(systemName: item.symbol)
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Color(hex: "08142C").opacity(0.55))
                        .overlay(
                            Circle()
                                .stroke(OnboardingTheme.gold.opacity(0.42), lineWidth: 1.5)
                        )
                        .clipShape(Circle())
                    Text(item.title)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(Color(hex: "CBD9EE"))
                }
                .frame(width: 76)
            }
        }
    }
}

struct OnboardingSerifTitle: View {
    let lines: [String]
    var goldWord: String? = nil
    var size: CGFloat = 41
    var alignment: TextAlignment = .center
    var onDark: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                if let goldWord = goldWord, line.contains(goldWord) {
                    let parts = line.components(separatedBy: goldWord)
                    HStack(spacing: 0) {
                        if let first = parts.first, !first.isEmpty {
                            Text(first)
                        }
                        Text(goldWord)
                            .foregroundColor(OnboardingTheme.gold)
                        if parts.count > 1, !parts[1].isEmpty {
                            Text(parts[1])
                        }
                    }
                    .font(.system(size: size, weight: .semibold, design: .serif))
                } else {
                    Text(line)
                        .font(.system(size: size, weight: .semibold, design: .serif))
                }
            }
        }
        .foregroundColor(onDark ? .white : OnboardingTheme.paperInk)
        .multilineTextAlignment(alignment)
        .lineSpacing(2)
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }
}

struct OnboardingEyebrow: View {
    let text: String
    var alignment: TextAlignment = .center

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .tracking(1.8)
            .foregroundColor(OnboardingTheme.primaryBlue)
            .multilineTextAlignment(alignment)
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }
}

struct OnboardingLede: View {
    let text: String
    var onDark: Bool = false
    var alignment: TextAlignment = .center

    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .lineSpacing(4)
            .foregroundColor(onDark ? OnboardingTheme.dim : OnboardingTheme.textSecondary)
            .multilineTextAlignment(alignment)
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }
}

struct OnboardingPhotocard: View {
    let verseText: String
    let reference: String
    var tag: String = APPNAME

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geo in
                Image("onboarding2_image")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geo.size.width + 24,
                        height: geo.size.height + 36
                    )
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2 + 14
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color(hex: "F7F1E4").opacity(0.82),
                                Color(hex: "F7F1E4").opacity(0.38),
                                Color.clear,
                                Color(hex: "1E3248").opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 14) {
                Text("\"\(verseText)\"")
                    .font(.system(size: 21, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "1B2E4A"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                Text(reference)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(Color(hex: "5D6E86"))
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
            .padding(.bottom, 44)
            .frame(maxWidth: .infinity)

            Text(tag)
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .padding(.trailing, 16)
                .padding(.bottom, 13)
        }
        .frame(minHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, -6)
        .padding(.bottom, -10)
        .shadow(color: Color(hex: "142848").opacity(0.14), radius: 14, x: 0, y: 10)
    }
}

struct OnboardingJourneyRail: View {
    let activeIndex: Int

    private let steps = [
        (symbol: "book.fill", title: "Read"),
        (symbol: "brain.head.profile", title: "Remember"),
        (symbol: "heart", title: "Reflect")
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("TODAY'S JOURNEY")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundColor(Color(hex: "5A6D8C"))
                Spacer()
                Text("1 / 3")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "8595AE"))
            }

            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    if index > 0 {
                        Text("→")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "B6C4D8"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 18)
                    }
                    VStack(spacing: 8) {
                        Image(systemName: step.symbol)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(index == activeIndex ? .white : OnboardingTheme.primaryBlue)
                            .frame(width: 52, height: 52)
                            .background(index == activeIndex ? OnboardingTheme.primaryBlue : Color.white)
                            .overlay(
                                Circle()
                                    .stroke(index == activeIndex ? OnboardingTheme.primaryBlue : OnboardingTheme.paperLine, lineWidth: 1.5)
                            )
                            .clipShape(Circle())
                        Text(step.title)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(Color(hex: "4A5C7A"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 74)
                }
            }
        }
    }
}

struct OnboardingToggleRow: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool
    var showDivider: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundColor(.white)
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundColor(OnboardingTheme.dim)
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(OnboardingSwitchStyle())
            }
            .padding(.vertical, 15)
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 1)
            }
        }
    }
}

struct OnboardingSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 15)
                .fill(configuration.isOn ? OnboardingTheme.grow : Color.white.opacity(0.18))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .offset(x: configuration.isOn ? 10 : -10),
                    alignment: .center
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
