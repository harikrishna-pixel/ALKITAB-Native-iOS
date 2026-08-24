//
//  Onboarding4.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding4: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.12))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.orange)
                            }
                            .padding(.top, 16)

                            Text("Understand With Clarity")
                                .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 28)

                            Text("Get simple explanations and chapter insights whenever you need more context.")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .foregroundColor(OnboardingTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 36)

                            insightRow(
                                icon: "bubble.left.and.bubble.right.fill",
                                iconColor: Color(hex: "2A9D8F"),
                                title: "Explain This Verse",
                                subtitle: "Get easy-to-understand explanations for any verse"
                            )
                            insightRow(
                                icon: "book.fill",
                                iconColor: OnboardingTheme.primaryBlue,
                                title: "Chapter at a Glance",
                                subtitle: "See the key points and the big picture quickly"
                            )

                            HStack(spacing: 10) {
                                badge("1 free explanation daily")
                                badge("1 free chapter insight daily")
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            .padding(.bottom, 12)
                        }
                    }

                    OnboardingPrimaryLink(title: "Continue", destination: Onboarding5())
                        .padding(.horizontal, 24)

                    OnboardingPageDots(current: 3, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func insightRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(OnboardingTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 24)
    }

    private func badge(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 11))
                .foregroundColor(Color.orange)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "8B6B3D"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(hex: "F5E6D3"))
        )
    }
}

#Preview {
    Onboarding4()
}
