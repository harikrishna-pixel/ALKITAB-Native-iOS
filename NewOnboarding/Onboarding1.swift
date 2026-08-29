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

                OnboardingTheme.darkPageGradient
                    .opacity(0.55)
                    .edgesIgnoringSafeArea(.all)

                LinearGradient(
                    colors: [Color.black.opacity(0.15), Color.black.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            OnboardingTopBar()
                                .padding(.horizontal, 20)
                                .padding(.top, max(geometry.safeAreaInsets.top, 12))

                            Spacer(minLength: geometry.size.height * 0.08)

                            OnboardingBrandTag()

                            OnboardingSerifTitle(
                                lines: ["Scripture", "Made Clear"],
                                goldWord: "Clear",
                                size: min(geometry.size.width * 0.1, 41)
                            )
                            .padding(.horizontal, 24)

                            OnboardingGoldOrnament()

                            OnboardingLede(
                                text: "Read and remember God's Word\nin clear, modern English.",
                                onDark: true
                            )
                            .padding(.horizontal, 32)

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPillarRow(items: [
                        ("book.fill", "Read"),
                        ("brain.head.profile", "Remember"),
                        ("heart", "Reflect")
                    ])
                    .padding(.bottom, 20)

                    OnboardingPrimaryButton(title: "Continue") {
                        requestTrackingThenContinue()
                    }
                    .padding(.horizontal, 26)
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
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
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
