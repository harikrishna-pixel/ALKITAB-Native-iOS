//
//  Onboarding4.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding4: View {
    @State private var explainRevealed = false
    @State private var explanationReady = false
    @State private var isLoadingExplanation = false
    /// Non-empty AI body in referral language; nil/empty → hardcoded English fallback.
    @State private var aiExplanation: String?
    @State private var navigateForward = false
    /// Verse text loaded once when Explain is tapped, so typing does not re-read the Bible.
    @State private var revealedVerse = ""
    /// Only the first outcome (AI reply or 3s timeout) is shown; the other is ignored.
    @State private var explainSettled = false
    private static let aiTimeout: TimeInterval = 3

    /// Hardcoded English fallback when AI is unavailable (medium-length referral wording).
    private static let contextTitle = "In context"
    private static let contextText =
        "Paul wrote this from prison. He isn't saying you can do anything you want — he's saying Christ's strength is enough for every situation he faces."
    private static let todayTitle = "What it means today"
    private static let todayText =
        "Hard days still come. The promise is that Christ gives the strength you need to meet them."

    private static func quoteLine(_ verse: String) -> String {
        let text = verse.isEmpty ? OnboardingBibleVerse.text : verse
        return "\"\(text)\"\n— verse 13"
    }

    /// Keep explanation body medium-length for the onboarding card.
    private static func mediumBody(_ text: String?) -> String? {
        guard let raw = text?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if raw.count <= 180 { return raw }
        let limit = 180
        let prefix = String(raw.prefix(limit))
        if let period = prefix.lastIndex(of: ".") {
            return String(prefix[...period])
        }
        if let space = prefix.lastIndex(of: " ") {
            return String(prefix[..<space]) + "…"
        }
        return prefix + "…"
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            OnboardingEyebrow(
                                text: "Understand with clarity",
                                alignment: .leading
                            )
                                .padding(.horizontal, 26)
                                .padding(.top, 16)

                            OnboardingSerifTitle(
                                lines: ["What Does", "This Verse Mean?"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .leading,
                                onDark: false
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 4)
                            .padding(.bottom, 14)

                            verseChip
                                .padding(.horizontal, 26)

                            explainButton
                                .padding(.horizontal, 26)
                                .padding(.top, 14)

                            if explainRevealed {
                                explanationCard
                                    .padding(.horizontal, 26)
                                    .padding(.top, 14)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                                if explanationReady {
                                    reachBanner
                                        .padding(.horizontal, 26)
                                        .padding(.top, 13)
                                        .padding(.bottom, 12)
                                }
                            }

                            Spacer(minLength: 20)
                        }
                    }

                    Group {
                        if explanationReady {
                            OnboardingPrimaryButton(title: "Continue") {
                                navigateForward = true
                            }
                        } else {
                            OnboardingPrimaryButton(
                                title: "Try it to continue",
                                isEnabled: false,
                                onDark: false
                            ) {}
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, usesOldOnboarding ? 0 : max(geometry.safeAreaInsets.bottom, 16))
                    .background(
                        Group {
                            if usesOldOnboarding {
                                NavigationLink(destination: BeforeOnboarding5(), isActive: $navigateForward) {
                                    EmptyView()
                                }
                            } else {
                                NavigationLink(destination: Onboarding5(), isActive: $navigateForward) {
                                    EmptyView()
                                }
                            }
                        }
                        .hidden()
                    )
                    if usesOldOnboarding {
                        OnboardingPageDots(current: 3, total: 5)
                            .padding(.top, 14)
                            .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: prefetchExplanation)
        .animation(.easeOut(duration: 0.42), value: explainRevealed)
        .animation(.easeOut(duration: 0.35), value: explanationReady)
    }

    private var verseChip: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(OnboardingBibleVerse.reference.uppercased())
                .font(.system(size: 10.5, weight: .heavy))
                .tracking(1.3)
                .foregroundColor(OnboardingTheme.primaryBlue)
            Text("\"\(OnboardingBibleVerse.text)\"")
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "22334F"))
                .lineSpacing(4)
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(OnboardingTheme.paperLine, lineWidth: 1)
                )
        )
        .overlay(
            Rectangle()
                .fill(OnboardingTheme.primaryBlue)
                .frame(width: 3)
                .cornerRadius(1.5),
            alignment: .leading
        )
    }

    private var explainButton: some View {
        Button(action: startExplain) {
            HStack(spacing: 9) {
                Text("✦")
                Text("Explain This Verse")
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [OnboardingTheme.primaryBlue, OnboardingTheme.primaryBlueDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(color: OnboardingTheme.primaryBlue.opacity(0.28), radius: 9, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(explainRevealed)
        .opacity(explainRevealed ? 0.9 : 1)
    }

    private var explanationCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Explanation")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(OnboardingTheme.paperInk)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(Color(hex: "FAFCFE"))
            .overlay(
                Rectangle()
                    .fill(Color(hex: "EDF2F8"))
                    .frame(height: 1),
                alignment: .bottom
            )

            Group {
                if isLoadingExplanation {
                    HStack(spacing: 10) {
                        SwiftUI.ProgressView()
                        Text("Getting explanation…")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "31435F"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(17)
                } else {
                    // Always use structured box: In context + yellow quote + today (referral layout).
                    OnboardingExplainTyping(
                        contextTitle: Self.contextTitle,
                        contextText: Self.mediumBody(aiExplanation) ?? Self.contextText,
                        quoteText: Self.quoteLine(revealedVerse),
                        todayTitle: Self.todayTitle,
                        todayText: Self.todayText
                    )
                    .padding(17)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(OnboardingTheme.paperLine, lineWidth: 1)
        )
        .shadow(color: Color(hex: "142848").opacity(0.07), radius: 12, x: 0, y: 8)
    }

    private var reachBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(OnboardingTheme.primaryBlue)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "E8EFFD"))
                )

            Text("Any verse. Any chapter.\nWhenever you're unsure.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "1F4C9E"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "F4F9FF"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "C9DCFB"), lineWidth: 1)
                )
        )
    }

    /// Ask the AI while the user reads the verse. The reply is cached, so Explain shows it at once.
    private func prefetchExplanation() {
        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code
        OpenAIExplanationService.shared.fetchExplanation(
            verseReference: OnboardingBibleVerse.reference,
            verseText: OnboardingBibleVerse.text,
            bibleVersion: APPNAME,
            responseLanguageCode: languageCode
        ) { result in
            DispatchQueue.main.async {
                // Explain was tapped and is still waiting — use this reply.
                guard explainRevealed, !explainSettled, case .success(let text) = result else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                explainSettled = true
                isLoadingExplanation = false
                aiExplanation = trimmed
                explanationReady = true
            }
        }
    }

    private func startExplain() {
        guard !explainRevealed else { return }
        if revealedVerse.isEmpty {
            revealedVerse = OnboardingBibleVerse.text
        }
        explainRevealed = true
        explanationReady = false
        isLoadingExplanation = true
        aiExplanation = nil
        explainSettled = false

        let reference = OnboardingBibleVerse.reference
        let verseText = revealedVerse.isEmpty ? OnboardingBibleVerse.text : revealedVerse
        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code

        let task = OpenAIExplanationService.shared.fetchExplanation(
            verseReference: reference,
            verseText: verseText,
            bibleVersion: APPNAME,
            responseLanguageCode: languageCode
        ) { result in
            DispatchQueue.main.async {
                guard !explainSettled else { return }
                explainSettled = true
                isLoadingExplanation = false
                switch result {
                case .success(let text):
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    aiExplanation = trimmed.isEmpty ? nil : trimmed
                case .failure:
                    aiExplanation = nil
                }
                explanationReady = true
            }
        }

        // No AI reply within 3s → show the hardcoded English explanation.
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.aiTimeout) {
            guard !explainSettled else { return }
            explainSettled = true
            task?.cancel()
            isLoadingExplanation = false
            aiExplanation = nil
            explanationReady = true
        }
    }

}

/// Types a single AI explanation paragraph. Used when the AI module returns text.
private struct OnboardingExplainAITyping: View {
    let text: String

    @State private var typedCount = 0
    @State private var clock = Clock()

    var body: some View {
        typedText(text, visible: String(text.prefix(typedCount)))
            .font(.system(size: 14.5))
            .foregroundColor(Color(hex: "31435F"))
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transaction { transaction in
                transaction.animation = nil
                transaction.disablesAnimations = true
            }
            .onAppear(perform: startTyping)
    }

    private func typedText(_ full: String, visible: String) -> some View {
        ZStack(alignment: .topLeading) {
            Text(full).hidden()
            Text(visible)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func startTyping() {
        guard !clock.started else { return }
        clock.started = true
        let total = text.count
        let timer = Timer(timeInterval: 0.02, repeats: true) { timer in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                typedCount = min(typedCount + 2, total)
            }
            if typedCount >= total {
                timer.invalidate()
                clock.timer = nil
            }
        }
        clock.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private final class Clock {
        var timer: Timer?
        var started = false
    }
}

/// Same type-on explanation as before. Updates stay in this view so the rest of the screen does not redraw.
private struct OnboardingExplainTyping: View {
    let contextTitle: String
    let contextText: String
    let quoteText: String
    let todayTitle: String
    let todayText: String

    @State private var typedCount = 0
    @State private var clock = Clock()

    private var total: Int {
        contextText.count + quoteText.count + todayText.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionBlock(title: contextTitle, body: contextText, offset: 0)

            typedText(quoteText, visible: typedPart(quoteText, offset: contextText.count), italic: true)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "6B4B10"))
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(hex: "FFFAF0"))
                )
                .overlay(
                    Rectangle()
                        .fill(OnboardingTheme.gold)
                        .frame(width: 3),
                    alignment: .leading
                )
                .cornerRadius(12)

            sectionBlock(
                title: todayTitle,
                body: todayText,
                offset: contextText.count + quoteText.count
            )
        }
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
        .onAppear(perform: startTyping)
    }

    private func sectionBlock(title: String, body: String, offset: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .black))
                .tracking(1.4)
                .foregroundColor(Color(hex: "93A3BC"))
            typedText(body, visible: typedPart(body, offset: offset))
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "31435F"))
                .lineSpacing(5)
        }
    }

    /// Full text reserves the final size (hidden) so the card does not grow while typing.
    private func typedText(_ full: String, visible: String, italic: Bool = false) -> some View {
        ZStack(alignment: .topLeading) {
            (italic ? Text(full).italic() : Text(full)).hidden()
            italic ? Text(visible).italic() : Text(visible)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func typedPart(_ text: String, offset: Int) -> String {
        let count = min(max(typedCount - offset, 0), text.count)
        return String(text.prefix(count))
    }

    private func startTyping() {
        guard !clock.started else { return }
        clock.started = true
        // Slightly faster type-on for Get Explanation.
        let timer = Timer(timeInterval: 0.012, repeats: true) { timer in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                typedCount = min(typedCount + 4, total)
            }
            if typedCount >= total {
                timer.invalidate()
                clock.timer = nil
            }
        }
        clock.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private final class Clock {
        var timer: Timer?
        var started = false
    }
}

#Preview {
    Onboarding4()
}

struct OnboardingComfortView: View {
    @State private var theme = "light"
    @State private var fontSize: CGFloat = 20
    @State private var navigateForward = false

    private var cardBackground: Color {
        if theme == "dark" { return Color(hex: "14213D") }
        if theme == "sepia" { return Color(hex: "F2E6CC") }
        return .white
    }

    private var cardInk: Color {
        theme == "dark" ? .white : OnboardingTheme.paperInk
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            OnboardingEyebrow(text: "Your Bible, your way")
                                .padding(.top, 16)
                            OnboardingSerifTitle(
                                lines: ["Make It", "Comfortable"],
                                size: min(geometry.size.width * 0.08, 31),
                                onDark: false
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            OnboardingLede(text: "Pick how you like to read.")
                                .padding(.horizontal, 32)
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 10) {
                                Text(OnboardingBibleVerse.reference)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(cardInk.opacity(0.7))
                                Text(OnboardingBibleVerse.text)
                                    .font(.system(size: fontSize, weight: .regular, design: .serif))
                                    .foregroundColor(cardInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16).fill(cardBackground))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(OnboardingTheme.paperLine, lineWidth: 1))
                            .padding(.horizontal, 26)
                            .padding(.top, 16)
                            Spacer(minLength: 12)
                        }
                    }

                    VStack(spacing: 0) {
                        Text("THEME")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.4)
                            .foregroundColor(Color(hex: "7488A6"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            themeChip("Light", id: "light", swatch: Color.white, border: true)
                            themeChip("Sepia", id: "sepia", swatch: Color(hex: "F2E6CC"), border: false)
                            themeChip("Dark", id: "dark", swatch: Color(hex: "14213D"), border: false)
                        }
                        .padding(.top, 8)

                        Text("TEXT SIZE")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.4)
                            .foregroundColor(Color(hex: "7488A6"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)

                        OnboardingTextSizeLine(fontSize: $fontSize)
                            .padding(.top, 10)

                        OnboardingPrimaryButton(title: "Continue", onDark: false) {
                            OnboardingTheme.applyReadingChoice(theme: theme, fontSize: fontSize)
                            navigateForward = true
                        }
                        .padding(.top, 18)

                        Text("You can change this anytime in Settings.")
                            .font(.system(size: 13))
                            .foregroundColor(OnboardingTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 8)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    .background(
                        NavigationLink(destination: OnboardingVerseImageView(), isActive: $navigateForward) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func themeChip(_ title: String, id: String, swatch: Color, border: Bool) -> some View {
        Button(action: { theme = id }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(swatch)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color(hex: "CDD7E6"), lineWidth: border ? 1 : 0))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(OnboardingTheme.paperInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme == id ? OnboardingTheme.primaryBlue : OnboardingTheme.paperLine, lineWidth: theme == id ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingVerseImageView: View {
    @State private var background = "candle"
    @State private var serif = true
    @State private var navigateForward = false

    private var imageName: String {
        if background == "gold" { return "verse_bg_gold" }
        if background == "ivory" { return "verse_bg_ivory" }
        return "verse_bg_candle"
    }

    private var ink: Color {
        if background == "ivory" { return Color(hex: "33250F") }
        if background == "gold" { return Color(hex: "FBF3E0") }
        return Color(hex: "FFF4DC")
    }

    private var accent: Color {
        if background == "ivory" { return Color(hex: "9A722C") }
        if background == "gold" { return Color(hex: "D9B35E") }
        return Color(hex: "E8C57A")
    }

    private var frameColor: Color {
        if background == "ivory" { return Color(hex: "9A722C").opacity(0.55) }
        if background == "gold" { return Color(hex: "D9B35E").opacity(0.6) }
        return Color(hex: "E8C57A").opacity(0.7)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            OnboardingEyebrow(text: "Make it beautiful")
                                .padding(.top, 16)
                            OnboardingSerifTitle(
                                lines: ["Your First", "Verse Image"],
                                size: min(geometry.size.width * 0.08, 31),
                                onDark: false
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            OnboardingLede(text: "Turn any verse into an image to keep or share. Try a background.")
                                .padding(.horizontal, 32)
                                .padding(.top, 8)

                            ZStack {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                VStack(spacing: 14) {
                                    Group {
                                        if serif {
                                            Text("“\(OnboardingBibleVerse.text)”")
                                                .font(.system(size: 22, weight: .regular, design: .serif))
                                                .italic()
                                        } else {
                                            Text("“\(OnboardingBibleVerse.text)”")
                                                .font(.system(size: 20, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(ink)
                                    .multilineTextAlignment(.center)
                                    Rectangle()
                                        .fill(accent.opacity(0.8))
                                        .frame(width: 34, height: 1.5)
                                    Text(OnboardingBibleVerse.reference.uppercased())
                                        .font(.system(size: 11.5, weight: .bold))
                                        .tracking(1.4)
                                        .foregroundColor(accent)
                                }
                                .padding(28)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 258)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(frameColor, lineWidth: 1.5)
                                    .padding(11)
                            )
                            .shadow(color: Color(hex: "0A1432").opacity(0.28), radius: 17, y: 8)
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            Text("BACKGROUND")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.4)
                                .foregroundColor(Color(hex: "7488A6"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 26)
                                .padding(.top, 16)

                            HStack(spacing: 8) {
                                bgChip("Candle", id: "candle", image: "verse_bg_candle")
                                bgChip("Gold", id: "gold", image: "verse_bg_gold")
                                bgChip("Ivory", id: "ivory", image: "verse_bg_ivory")
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            Text("FONT")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.4)
                                .foregroundColor(Color(hex: "7488A6"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 26)
                                .padding(.top, 16)

                            HStack(spacing: 8) {
                                fontChip("Serif", isSerif: true)
                                fontChip("Clean", isSerif: false)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 8)
                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryButton(title: "Continue", onDark: false) {
                        UserDefaults.standard.set(background, forKey: OnboardingTheme.verseImageBgKey)
                        UserDefaults.standard.set(serif ? "serif" : "sans", forKey: OnboardingTheme.verseImageFontKey)
                        navigateForward = true
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    .background(
                        NavigationLink(destination: Onboarding5(), isActive: $navigateForward) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func bgChip(_ title: String, id: String, image: String) -> some View {
        let selected = background == id
        return Button(action: { background = id }) {
            HStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selected ? OnboardingTheme.primaryBlue : Color(hex: "31456A"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? OnboardingTheme.primaryBlue : OnboardingTheme.paperLine, lineWidth: 1.5)
            )
            .shadow(color: selected ? OnboardingTheme.primaryBlue.opacity(0.12) : .clear, radius: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func fontChip(_ title: String, isSerif: Bool) -> some View {
        Button(action: { serif = isSerif }) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(serif == isSerif ? OnboardingTheme.primaryBlue : Color(hex: "31456A"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(serif == isSerif ? OnboardingTheme.primaryBlue : OnboardingTheme.paperLine, lineWidth: serif == isSerif ? 1.5 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingTextSizeLine: View {
    @Binding var fontSize: CGFloat

    private let minSize: CGFloat = 16
    private let maxSize: CGFloat = 28
    private let thumbSize: CGFloat = 22

    private var progress: CGFloat {
        min(1, max(0, (fontSize - minSize) / (maxSize - minSize)))
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { fontSize = max(minSize, fontSize - 2) }) {
                Text("A")
                    .font(.system(size: 16, weight: .semibold))
            }
            GeometryReader { bar in
                let usable = max(1, bar.size.width - thumbSize)
                let thumbX = usable * progress
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(OnboardingTheme.primaryBlue.opacity(0.25))
                        .frame(height: 4)
                    Capsule()
                        .fill(OnboardingTheme.primaryBlue)
                        .frame(width: max(thumbSize / 2, thumbX + thumbSize / 2), height: 4)
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(Circle().stroke(OnboardingTheme.primaryBlue, lineWidth: 2.5))
                        .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)
                        .offset(x: thumbX)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let p = min(1, max(0, (value.location.x - thumbSize / 2) / usable))
                            let raw = minSize + p * (maxSize - minSize)
                            fontSize = (raw / 2).rounded() * 2
                            fontSize = min(maxSize, max(minSize, fontSize))
                        }
                )
            }
            .frame(height: thumbSize)
            Button(action: { fontSize = min(maxSize, fontSize + 2) }) {
                Text("A")
                    .font(.system(size: 22, weight: .semibold))
            }
        }
        .foregroundColor(OnboardingTheme.paperInk)
    }
}
