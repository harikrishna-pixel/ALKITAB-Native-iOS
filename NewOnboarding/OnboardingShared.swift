//
//  OnboardingShared.swift
//  NKJV Bible
//

import SwiftUI

enum OnboardingTheme {
    static let primaryBlue = Color(red: 0.18, green: 0.31, blue: 0.71)
    static let navy = Color(hex: "0B1B3A")
    static let gold = Color(hex: "D4A017")
    static let softGray = Color(hex: "F5F6FA")
    static let textSecondary = Color.black.opacity(0.55)

    static var brandTitle: String {
        let name = (APPNAME_SPLASH.isEmpty ? APPNAME : APPNAME_SPLASH).uppercased()
        return name.isEmpty ? "BIBLE" : name
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
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(
                        index == current
                            ? (onDark ? Color.white : OnboardingTheme.primaryBlue)
                            : (onDark ? Color.white.opacity(0.35) : Color.black.opacity(0.15))
                    )
                    .frame(width: index == current ? 18 : 7, height: 7)
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
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(OnboardingTheme.primaryBlue)
            .cornerRadius(28)
        }
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(OnboardingTheme.primaryBlue)
            .cornerRadius(28)
        }
    }
}

struct OnboardingSkipButton: View {
    var body: some View {
        Button(action: {
            UIKitNavigationHelper.navigateToIAPView()
        }) {
            Text("Skip")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.black.opacity(0.25)))
        }
    }
}
