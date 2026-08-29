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
                OnboardingTheme.paper.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            OnboardingTopBar(onLight: true)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)

                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 24))
                                .foregroundColor(OnboardingTheme.gold)
                                .padding(.top, 4)
                                .padding(.bottom, 6)

                            OnboardingEyebrow(text: "Today's verse")

                            OnboardingSerifTitle(
                                lines: ["Start With", "His Word"],
                                size: min(geometry.size.width * 0.08, 31),
                                onDark: false
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 4)

                            OnboardingLede(text: "Discover a daily verse and keep Scripture part of every day.")
                                .padding(.horizontal, 36)
                                .padding(.top, 8)
                                .padding(.bottom, 4)

                            OnboardingPhotocard(
                                verseText: OnboardingBibleVerse.text,
                                reference: OnboardingBibleVerse.reference
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            OnboardingJourneyRail(activeIndex: 0)
                                .padding(.horizontal, 26)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                        }
                    }

                    OnboardingPrimaryLink(title: "Continue", destination: Onboarding3())
                        .padding(.horizontal, 26)

                    OnboardingPageDots(current: 1, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    Onboarding2()
}
