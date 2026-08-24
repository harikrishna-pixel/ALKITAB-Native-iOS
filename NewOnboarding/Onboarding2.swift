//
//  Onboarding2.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct Onboarding2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 22))
                                .foregroundColor(OnboardingTheme.gold)
                                .padding(.top, 8)

                            Text("TODAY'S VERSE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(OnboardingTheme.navy)
                                .tracking(1.4)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            Text("Start With His Word")
                                .font(.system(size: min(geometry.size.width * 0.075, 30), weight: .bold, design: .serif))
                                .foregroundColor(OnboardingTheme.navy)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)

                            Text("Discover a daily verse and keep Scripture part of every day.")
                                .font(.system(size: 15))
                                .foregroundColor(OnboardingTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 36)

                            let cardWidth = geometry.size.width - 48
                            let cardHeight = cardWidth * (340.0 / 512.0)

                            ZStack {
                                Image("onboarding2_image")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: cardWidth, height: cardHeight)

                                VStack(spacing: 8) {
                                    Text("For I can do everything through Christ, who gives me strength.")
                                        .font(.system(size: 17, weight: .regular, design: .serif))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text("Philippians 4:13")
                                        .font(.system(size: 14, weight: .regular, design: .serif))
                                        .foregroundColor(.black.opacity(0.72))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 22)
                                .frame(width: cardWidth, height: cardHeight)

                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text(APPNAME)
                                            .font(.system(size: 11, weight: .medium, design: .serif))
                                            .foregroundColor(.white.opacity(0.95))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 12)
                                }
                                .frame(width: cardWidth, height: cardHeight)
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                            VStack(spacing: 14) {
                                Text("TODAY'S JOURNEY  1/4")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(OnboardingTheme.navy)
                                    .tracking(1.2)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 0) {
                                    journeyStep(icon: "book.fill", title: "Read", active: true)
                                    journeyArrow()
                                    journeyStep(icon: "brain.head.profile", title: "Remember", active: false)
                                    journeyArrow()
                                    journeyStep(icon: "heart.fill", title: "Reflect", active: false)
                                    journeyArrow()
                                    journeyStep(icon: "flame.fill", title: "Streak", active: false)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }

                    OnboardingPrimaryLink(title: "Continue", destination: Onboarding3())
                        .padding(.horizontal, 24)

                    OnboardingPageDots(current: 1, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func journeyStep(icon: String, title: String, active: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(active ? OnboardingTheme.primaryBlue : Color.black.opacity(0.06))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(active ? .white : OnboardingTheme.primaryBlue.opacity(0.7))
            }
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(active ? OnboardingTheme.primaryBlue : .black.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }

    private func journeyArrow() -> some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color.black.opacity(0.25))
            .padding(.bottom, 18)
    }
}

#Preview {
    Onboarding2()
}
