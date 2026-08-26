//
//  Onboarding5.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding5: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Soft off-white + blue glow (matches required UI)
                Color(hex: "F7F8FC").ignoresSafeArea()
                VStack {
                    Spacer()
                    RadialGradient(
                        colors: [
                            OnboardingTheme.primaryBlue.opacity(0.14),
                            Color.clear
                        ],
                        center: .bottom,
                        startRadius: 20,
                        endRadius: max(geometry.size.width * 0.75, 220)
                    )
                    .frame(height: geometry.size.height * 0.45)
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "FF9F0A"))
                                .padding(.top, 20)

                            Text("Stay Rooted Every Day")
                                .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(OnboardingTheme.navy)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 28)

                            Text("Read. Remember. Reflect.\nWatch your Scripture journey grow.")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .foregroundColor(OnboardingTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 36)

                            VStack(alignment: .leading, spacing: 16) {
                                Text("7 Day Streak 🔥")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack {
                                    ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { index, day in
                                        VStack(spacing: 6) {
                                            Text(day)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                            streakCompletionIndicator(done: index < 6, pending: index == 6)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 14) {
                                    checklistRow(icon: "book.fill", title: "Today's Verse", done: true)
                                    checklistRow(icon: "brain.head.profile", title: "Memory Challenge", done: true)
                                    checklistRow(icon: "heart.fill", title: "Reflection", done: false)
                                }
                                .padding(.top, 6)
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(OnboardingTheme.navy)
                            )
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        }
                    }

                    OnboardingPrimaryLink(title: "Build My Bible Habit", destination: OnboardingCreateAccountView())
                        .padding(.horizontal, 24)

                    OnboardingPageDots(current: 4, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .navigationBarHidden(true)
    }

    /// Left feature icon + title; completion status on the right (as in UI).
    private func checklistRow(icon: String, title: String, done: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 22)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            streakCompletionIndicator(done: done)
        }
    }

    private func streakCompletionIndicator(done: Bool, pending: Bool = false) -> some View {
        ZStack {
            if done {
                Circle()
                    .fill(Color(hex: "34C759"))
                    .frame(width: 22, height: 22)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            } else if pending {
                Circle()
                    .stroke(Color(hex: "C9A227").opacity(0.85), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            } else {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
    }
}

#Preview {
    Onboarding5()
}
