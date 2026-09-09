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
                    .edgesIgnoringSafeArea(.all)

                // Light top-to-bottom wash only — keep sunrise + book clear (reference).
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.22),
                        Color.clear,
                        Color.black.opacity(0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    OnboardingTopBar()
                        .padding(.horizontal, 20)
                        .padding(.top, max(geometry.safeAreaInsets.top, 54) + 20)

                    VStack(spacing: 0) {
                        // Nudge title block down toward the book top (reference).
                        Spacer(minLength: geometry.size.height * 0.16)

                        Text(OnboardingTheme.brandTitle)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(4.2)
                            .foregroundColor(Color.white.opacity(0.85))

                        OnboardingSerifTitle(
                            lines: ["Scripture", "Made Clear"],
                            goldWord: "Clear",
                            size: min(geometry.size.width * 0.1, 41)
                        )
                        .padding(.top, 10)
                        .padding(.horizontal, 24)

                        OnboardingGoldOrnament()
                            .padding(.top, 10)

                        // Fully visible subtitle (was too dim against the sky / glow).
                        Text("Read and remember God's Word\nclearly and simply.")
                            .font(.system(size: 15, weight: .medium))
                            .lineSpacing(4)
                            .foregroundColor(Color.white.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.45), radius: 3, x: 0, y: 1)
                            .padding(.top, 12)
                            .padding(.horizontal, 32)

                        Spacer(minLength: geometry.size.height * 0.28)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34) + 36)
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
            // Offline + no cached Yearly/Lifetime prices → skip blank paywall for these users.
            let cachedYearly = UserDefaults.standard.string(forKey: "PriceTag2") ?? ""
            let cachedLifetime = UserDefaults.standard.string(forKey: "PriceTag3") ?? ""
            let hasYearly = !cachedYearly.isEmpty || !StoreManager.shared.price2.isEmpty
            let hasLifetime = !cachedLifetime.isEmpty || !StoreManager.shared.price3.isEmpty
            let offline = !NetworkManager.sharedInstance.isConnectedToInternet()
            if offline && !hasYearly && !hasLifetime {
                UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
                navigateToReaderViewController()
                return
            }

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
