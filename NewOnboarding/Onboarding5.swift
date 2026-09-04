//
//  Onboarding5.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding5: View {
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    private let journeyItems = [
        ("Today's Verse", true),
        ("Memory Challenge", false),
        ("Reflection", false)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 0) {
                            OnboardingSerifTitle(
                                lines: ["Stay Rooted", "Every Day"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 12)

                            OnboardingLede(
                                text: "Read. Remember. Reflect.\nYour journey starts today.",
                                onDark: true,
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            streakCard
                                .padding(.horizontal, 26)
                                .padding(.top, 18)

                            VStack(spacing: 0) {
                                ForEach(Array(journeyItems.enumerated()), id: \.offset) { index, item in
                                    journeyRow(title: item.0, done: item.1, showDivider: index > 0)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 10)

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryLink(title: "Build My Bible Habit", destination: OnboardingCreateAccountView())
                        .padding(.horizontal, 26)

                    OnboardingPageDots(current: 4, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 4) {
                    Text("Day 1")
                    Image(systemName: "flame.fill")
                        .foregroundColor(OnboardingTheme.gold)
                }
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.white)
                Spacer()
                Text("This week")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(OnboardingTheme.dim)
            }

            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 7) {
                        Text(day)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(index == 0 ? .white : Color(hex: "7C93B8"))
                        Circle()
                            .fill(index == 0 ? OnboardingTheme.gold : Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(
                                        index == 0 ? OnboardingTheme.gold : Color.white.opacity(0.2),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 28, height: 28)
                            .shadow(color: index == 0 ? OnboardingTheme.gold.opacity(0.5) : .clear, radius: 9)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 18)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 19)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func journeyRow(title: String, done: Bool, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 1)
            }
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "DCE7F8"))
                Spacer()
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(done ? OnboardingTheme.grow : Color(hex: "4C5F7E"))
            }
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    Onboarding5()
}
