//
//  Onboarding3.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding3: View {
    @State private var selectedOption: Int? = nil
    private let options = OnboardingBibleVerse.options

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(OnboardingTheme.primaryBlue.opacity(0.1))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 30))
                                    .foregroundColor(OnboardingTheme.primaryBlue)
                            }
                            .padding(.top, 16)

                            VStack(spacing: 6) {
                                Text("Remember What You Read")
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 28)

                                Text("Simple fill-in-the-blank challenges help Scripture stay with you.")
                                    .font(.system(size: 15))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(OnboardingTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 36)
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                fillInBlankText()
                                    .font(.system(size: 16, weight: .medium))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(OnboardingBibleVerse.reference)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(OnboardingTheme.textSecondary)

                                VStack(spacing: 10) {
                                    if options.indices.contains(0) {
                                        optionChip(index: 0)
                                    }
                                    HStack(spacing: 10) {
                                        if options.indices.contains(1) {
                                            optionChip(index: 1)
                                        }
                                        if options.indices.contains(2) {
                                            optionChip(index: 2)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                            .padding(.horizontal, 24)

                            if let selectedOption {
                                feedbackBanner(for: selectedOption)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 12)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }

                    OnboardingPrimaryLink(title: "Try It Now", destination: OnboardingNotificationView())
                        .padding(.horizontal, 24)

                    OnboardingPageDots(current: 2, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: selectedOption)
    }

    private func fillInBlankText() -> Text {
        let prompt = OnboardingBibleVerse.blankPrompt
        let parts = prompt.components(separatedBy: "________")
        let prefix = parts.first ?? prompt
        let suffix = parts.count > 1 ? parts[1] : ""
        if let selectedOption, options.indices.contains(selectedOption) {
            let isCorrect = selectedOption == OnboardingBibleVerse.correctOptionIndex
            return Text(prefix)
                .foregroundColor(.black)
            + Text(options[selectedOption])
                .fontWeight(.semibold)
                .foregroundColor(isCorrect ? OnboardingTheme.primaryBlue : Color(hex: "C0392B"))
            + Text(suffix)
                .foregroundColor(.black)
        }
        return Text(prompt)
            .foregroundColor(.black)
    }

    private func feedbackBanner(for selectedIndex: Int) -> some View {
        let isCorrect = selectedIndex == OnboardingBibleVerse.correctOptionIndex
        let message = isCorrect
            ? "Great! 🥳 Keep going and remember His Word today."
            : "Not quite. The correct word is \"\(options[OnboardingBibleVerse.correctOptionIndex])\"."
        let accent = isCorrect ? OnboardingTheme.primaryBlue : Color(hex: "C0392B")

        return HStack(spacing: 8) {
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(accent)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accent.opacity(0.08))
        )
    }

    private func optionChip(index: Int) -> some View {
        let isSelected = selectedOption == index
        let isCorrect = index == OnboardingBibleVerse.correctOptionIndex
        let fillColor: Color
        let textColor: Color
        let borderOpacity: Double

        if isSelected {
            if isCorrect {
                fillColor = OnboardingTheme.primaryBlue
                textColor = .white
                borderOpacity = 0
            } else {
                fillColor = Color(hex: "C0392B")
                textColor = .white
                borderOpacity = 0
            }
        } else {
            fillColor = Color.white
            textColor = OnboardingTheme.primaryBlue
            borderOpacity = 0.35
        }

        return Button(action: { selectedOption = index }) {
            HStack(spacing: 6) {
                Text(options[index])
                    .font(.system(size: 16, weight: .semibold))
                if isSelected {
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(fillColor)
            )
            .overlay(
                Capsule()
                    .stroke(OnboardingTheme.primaryBlue.opacity(borderOpacity), lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    Onboarding3()
}
