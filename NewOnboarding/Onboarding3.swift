//
//  Onboarding3.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding3: View {
    @State private var selectedOption: Int? = nil
    private let options = ["strength", "hope", "peace"]

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

                            VStack(alignment: .leading, spacing: 14) {
                                Text("For I can do everything through Christ, who gives me ________.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("Philippians 4:13")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(OnboardingTheme.textSecondary)

                                VStack(spacing: 10) {
                                    ForEach(options.indices, id: \.self) { index in
                                        Button(action: { selectedOption = index }) {
                                            HStack {
                                                Text(options[index])
                                                    .font(.system(size: 16, weight: .semibold))
                                                Spacer()
                                                if selectedOption == index {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                }
                                            }
                                            .foregroundColor(selectedOption == index ? .white : OnboardingTheme.primaryBlue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 13)
                                            .background(
                                                Capsule()
                                                    .fill(selectedOption == index ? OnboardingTheme.primaryBlue : Color.white)
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(OnboardingTheme.primaryBlue.opacity(selectedOption == index ? 0 : 0.35), lineWidth: 1.5)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                            .padding(.horizontal, 24)

                            if selectedOption != nil {
                                HStack(spacing: 8) {
                                    Text("Great! 🥳 Keep going and remember His Word today.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(OnboardingTheme.primaryBlue)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(OnboardingTheme.primaryBlue.opacity(0.08))
                                )
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }

                    OnboardingPrimaryLink(title: "Try It Now", destination: Onboarding4())
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
}

#Preview {
    Onboarding3()
}
