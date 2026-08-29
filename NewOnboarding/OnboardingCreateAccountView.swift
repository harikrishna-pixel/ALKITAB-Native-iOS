//
//  OnboardingCreateAccountView.swift
//  NKJV Bible
//

import SwiftUI

struct OnboardingCreateAccountView: View {
    @StateObject private var auth = OnboardingAuthManager()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: max(geometry.safeAreaInsets.top, 16) + 24)

                            OnboardingSerifTitle(
                                lines: ["Keep Your Journey", "With You"],
                                size: min(geometry.size.width * 0.09, 34),
                                alignment: .center,
                                onDark: false
                            )
                            .padding(.horizontal, 32)

                            OnboardingLede(
                                text: "Save your streak, reflections and progress across devices. Optional.",
                                alignment: .center
                            )
                            .padding(.horizontal, 36)
                            .padding(.top, 10)

                            VStack(spacing: 10) {
                                socialSignInButton(title: "Continue with Apple") {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 18, weight: .semibold))
                                } action: {
                                    auth.signInWithApple()
                                }

                                socialSignInButton(title: "Continue with Google") {
                                    Image("google_logo")
                                        .resizable()
                                        .scaledToFit()
                                } action: {
                                    auth.signInWithGoogle()
                                }
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 28)
                            .disabled(auth.isBusy)
                            .opacity(auth.isBusy ? 0.6 : 1)

                            if auth.isBusy {
                                SwiftUI.ProgressView()
                                    .padding(.top, 16)
                            }

                            if let errorMessage = auth.errorMessage, !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 28)
                                    .padding(.top, 12)
                            }

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingGhostButton(title: "Not Now", onDark: false) {
                        UIKitNavigationHelper.navigateToIAPView()
                    }
                    .padding(.horizontal, 26)
                    .disabled(auth.isBusy)

                    Spacer(minLength: max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func socialSignInButton<Icon: View>(
        title: String,
        @ViewBuilder icon: () -> Icon,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                icon()
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.system(size: 16.5, weight: .semibold))
            }
            .foregroundColor(OnboardingTheme.paperInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(OnboardingTheme.paperLine, lineWidth: 1)
            )
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingCreateAccountView()
}
