//
//  OnboardingCreateAccountView.swift
//  NKJV Bible
//

import SwiftUI

struct OnboardingCreateAccountView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(OnboardingTheme.primaryBlue.opacity(0.12))
                            .frame(width: 84, height: 84)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(OnboardingTheme.primaryBlue)
                    }

                    Text("Keep Your Journey With You.")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)

                    Text("Save your reading progress, streaks, reflections and Prayer Wall activity.")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(OnboardingTheme.textSecondary)
                        .padding(.horizontal, 36)

                    VStack(spacing: 12) {
                        socialButton(title: "Continue with Apple", fill: .black, textColor: .white) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        socialButton(title: "Continue with Google", fill: .white, textColor: .black, bordered: true) {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        socialButton(title: "Continue with Email", fill: .white, textColor: .black, bordered: true) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 8)

                    Button(action: {
                        UIKitNavigationHelper.navigateToIAPView()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(OnboardingTheme.textSecondary)
                    }
                    .padding(.top, 8)

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func socialButton<Icon: View>(
        title: String,
        fill: Color,
        textColor: Color,
        bordered: Bool = false,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        Button(action: {
            // UI only — continue to existing IAP flow
            UIKitNavigationHelper.navigateToIAPView()
        }) {
            HStack(spacing: 12) {
                icon()
                    .frame(width: 22, height: 22)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(fill)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(bordered ? Color.black.opacity(0.15) : Color.clear, lineWidth: 1)
            )
        }
    }
}

#Preview {
    OnboardingCreateAccountView()
}
