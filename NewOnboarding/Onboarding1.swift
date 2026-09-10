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
            let h = geometry.size.height
            let isCompact = h < 700
            let titleSize = min(geometry.size.width * (isCompact ? 0.095 : 0.1), isCompact ? 36 : 41)
            // Reference: hero sits mid–upper sky (below Skip, above mountains / book).
            let heroTop = h * (isCompact ? 0.10 : 0.14)

            ZStack {
                Image("onboarding1_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                // Light top-to-bottom wash — keep sunrise + book clear (reference).
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.28),
                        Color.clear,
                        Color.black.opacity(0.38)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    OnboardingTopBar()
                        .padding(.horizontal, 20)
                        .padding(.top, geometry.safeAreaInsets.top + 8)

                    VStack(spacing: 0) {
                        Text(OnboardingTheme.brandTitle)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(4.2)
                            .foregroundColor(Color.white.opacity(0.9))

                        OnboardingSerifTitle(
                            lines: ["Scripture", "Made Clear"],
                            goldWord: "Clear",
                            size: titleSize
                        )
                        .padding(.top, isCompact ? 8 : 10)
                        .padding(.horizontal, 24)

                        OnboardingGoldOrnament()
                            .padding(.top, isCompact ? 8 : 10)

                        Text("Read and remember God's Word\nclearly and simply.")
                            .font(.system(size: isCompact ? 14 : 15, weight: .medium))
                            .lineSpacing(4)
                            .foregroundColor(Color.white.opacity(0.96))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 4, x: 0, y: 1)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                            .padding(.top, isCompact ? 10 : 12)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, heroTop)
                    .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: isCompact ? 8 : 16)

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
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 20) + (isCompact ? 16 : 28))
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
        DispatchQueue.main.async {
            guard let navigationController = topNavigationController() else {
                print("⚠️ [UIKitNavigationHelper] No UINavigationController — cannot open paywall")
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
    }

    static func navigateToReaderViewController() {
        OnboardingProgress.markCompleted()

        DispatchQueue.main.async {
            guard let navigationController = topNavigationController() else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let readerVC = storyboard.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController {
                navigationController.pushViewController(readerVC, animated: true)
            }
        }
    }

    /// Prefer root nav; fall back to nav that currently hosts the top VC (onboarding hosting).
    private static func topNavigationController() -> UINavigationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let root = window.rootViewController else {
            return nil
        }
        if let nav = root as? UINavigationController {
            return nav
        }
        if let nav = root.navigationController {
            return nav
        }
        var current: UIViewController? = root
        while let presented = current?.presentedViewController {
            current = presented
        }
        if let nav = current as? UINavigationController {
            return nav
        }
        return current?.navigationController
    }
}
