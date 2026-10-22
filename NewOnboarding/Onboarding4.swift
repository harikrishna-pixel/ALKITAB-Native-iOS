//
//  Onboarding4.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding4: View {
    @State private var explainRevealed = false
    @State private var navigateForward = false
    @State private var typedCount = 0

    private static var isIndonesian: Bool {
        let code = UserDefaults.standard.string(forKey: "language_code") ?? FallbackAppConfigConstants.languageCode
        return code.caseInsensitiveCompare("Indonesian") == .orderedSame
    }

    private static var contextTitle: String {
        isIndonesian ? "Dalam konteks" : "In context"
    }

    private static var contextText: String {
        isIndonesian
            ? "Paulus menulis ini dari dalam penjara. Ia tidak menjanjikan bahwa kamu bisa meraih apa pun yang kamu inginkan — ia berkata bahwa ia telah belajar mencukupkan diri, baik dalam kelimpahan maupun dalam kekurangan, karena kekuatannya tidak pernah berasal dari keadaannya."
            : "Paul wrote this from a prison cell. He isn't promising you can achieve anything you set your mind to — he's saying he has learned to be content with plenty and with almost nothing, because his strength never came from his circumstances."
    }

    private static var quoteText: String {
        let label = isIndonesian ? "ayat 11" : "verse 11"
        return "\"\(verseElevenQuote)\"\n— \(label)"
    }

    private static var todayTitle: String {
        isIndonesian ? "Artinya bagi kita hari ini" : "What it means today"
    }

    private static var todayText: String {
        isIndonesian
            ? "Janji ini bukan berarti masa sulit tidak akan datang lagi. Artinya, kamu diberi apa yang kamu butuhkan untuk menghadapinya — hari demi hari, dari sumber di luar dirimu."
            : "The promise isn't that hard things stop coming. It's that you are given what you need to meet them — one day at a time, from a source outside yourself."
    }

    private static var totalTypedLength: Int {
        contextText.count + quoteText.count + todayText.count
    }

    /// Philippians 4:11 from the bundled Bible, so the quote matches the reading language.
    private static var verseElevenQuote: String {
        let fallback = isIndonesian
            ? "Aku telah belajar mencukupkan diri dalam segala keadaan."
            : "I have learned how to be content with whatever I have."
        guard UserDefaults.standard.string(forKey: "SelectedLanguage") != nil else { return fallback }
        let books = BibleContent.sharedInstance.BookToPosition()
        let bookIndex = 49
        guard bookIndex < books.count else { return fallback }
        let bookName = books[bookIndex].components(separatedBy: "-")[0]
        let verses = BibleContent.sharedInstance.AudioBibleList(selecterBookName: bookName, selectedId: 3)
        let verseIndex = 10
        guard verseIndex < verses.count else { return fallback }
        let text = verses[verseIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? fallback : text
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            OnboardingEyebrow(text: "Understand with clarity", alignment: .leading)
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

                                reachBanner
                                    .padding(.horizontal, 26)
                                    .padding(.top, 13)
                                    .padding(.bottom, 12)
                            }

                            Spacer(minLength: 20)
                        }
                    }

                    Group {
                        if explainRevealed {
                            OnboardingPrimaryButton(title: "Continue") {
                                navigateForward = true
                            }
                        } else {
                            OnboardingPrimaryButton(title: "Try it to continue", isEnabled: false, onDark: false) {}
                        }
                    }
                    .padding(.horizontal, 26)
                    .background(
                        NavigationLink(
                            destination: Onboarding5(),
                            isActive: $navigateForward
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )

                    OnboardingPageDots(current: 3, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeOut(duration: 0.42), value: explainRevealed)
    }

    private var verseChip: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(OnboardingBibleVerse.reference.uppercased())
                    .font(.system(size: 10.5, weight: .heavy))
                    .tracking(1.3)
                    .foregroundColor(OnboardingTheme.primaryBlue)
                Spacer()
                Text(APPNAME)
                    .font(.system(size: 10.5, weight: .heavy))
                    .tracking(0.6)
                    .foregroundColor(Color(hex: "93A3BC"))
            }
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
        Button(action: {
            explainRevealed = true
            startTyping()
        }) {
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
                Text("AI")
                    .font(.system(size: 9.5, weight: .black))
                    .tracking(1)
                    .foregroundColor(OnboardingTheme.primaryBlue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "E8EFFD"))
                            .overlay(Capsule().stroke(Color(hex: "C9DCFB"), lineWidth: 1))
                    )
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

            VStack(alignment: .leading, spacing: 15) {
                sectionBlock(
                    title: Self.contextTitle,
                    body: Self.contextText,
                    visible: typedPart(Self.contextText, offset: 0)
                )

                typedText(Self.quoteText, visible: typedPart(Self.quoteText, offset: Self.contextText.count), italic: true)
                    .font(.system(size: 15.5, weight: .regular, design: .serif))
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
                    title: Self.todayTitle,
                    body: Self.todayText,
                    visible: typedPart(Self.todayText, offset: Self.contextText.count + Self.quoteText.count)
                )
            }
            .padding(17)

            Text("Always in the language you read in")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "7F90AC"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "EDF2F8"))
                        .frame(height: 1),
                    alignment: .top
                )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(OnboardingTheme.paperLine, lineWidth: 1)
        )
        .shadow(color: Color(hex: "142848").opacity(0.07), radius: 12, x: 0, y: 8)
    }

    private func sectionBlock(title: String, body: String, visible: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black))
                .tracking(1.4)
                .foregroundColor(Color(hex: "93A3BC"))
            typedText(body, visible: visible)
                .font(.system(size: 14.5))
                .foregroundColor(Color(hex: "31435F"))
                .lineSpacing(5)
        }
    }

    // MARK: Typing effect

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
        guard typedCount == 0 else { return }
        Timer.scheduledTimer(withTimeInterval: 0.012, repeats: true) { timer in
            typedCount = min(typedCount + 12, Self.totalTypedLength)
            if typedCount >= Self.totalTypedLength {
                timer.invalidate()
            }
        }
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

}

#Preview {
    Onboarding4()
}
