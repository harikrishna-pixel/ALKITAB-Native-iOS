//
//  Onboarding1.swift
//  NKJV Bible
//

import SwiftUI
import AppTrackingTransparency

struct Onboarding1: View {
    @State private var navigateToNext = false

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                onboardingContent
            }
        } else {
            NavigationView {
                onboardingContent
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    private var onboardingContent: some View {
        GeometryReader { geometry in
            ZStack {
                Image("onboarding1_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.2), Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    OnboardingBrandHeader(lightContent: true)
                        .padding(.top, max(geometry.safeAreaInsets.top, 12) + 12)
                        .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        Text("Scripture Made Clear")
                            .font(.system(size: min(geometry.size.width * 0.085, 34), weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)

                        Text("Read the Bible in a beautiful, focused Bible experience.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)

                        HStack(spacing: 36) {
                            iconLabel(systemName: "book.fill", title: "Read")
                            iconLabel(systemName: "brain.head.profile", title: "Remember")
                            iconLabel(systemName: "heart.fill", title: "Reflect")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                    }
                    .padding(.top, 28)

                    Spacer(minLength: 16)

                    OnboardingPrimaryButton(title: "Start Reading") {
                        requestTrackingThenContinue()
                    }
                    .padding(.horizontal, 24)
                    .background(
                        NavigationLink(
                            destination: Onboarding2(),
                            isActive: $navigateToNext
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )

                    OnboardingPageDots(current: 0, total: 5, onDark: true)
                        .padding(.top, 16)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }

    private func requestTrackingThenContinue() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    navigateToNext = true
                }
            }
        } else {
            navigateToNext = true
        }
    }

    private func iconLabel(systemName: String, title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 18))
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.95))
    }
}

#Preview {
    Onboarding1()
}

struct UIKitNavigationHelper {
    static func navigateToIAPView() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navigationController = window.rootViewController as? UINavigationController else {
            return
        }

        if #available(iOS 15.0, *) {
            let subscriptionView = BibleSubscriptionView()
            let hostingController = UIHostingController(rootView: subscriptionView)
            navigationController.pushViewController(hostingController, animated: true)
        } else {
            navigateToReaderViewController()
        }
    }

    static func navigateToReaderViewController() {
        OnboardingProgress.markCompleted()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navigationController = window.rootViewController as? UINavigationController else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let readerVC = storyboard.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController {
            navigationController.pushViewController(readerVC, animated: true)
        }
    }
}
