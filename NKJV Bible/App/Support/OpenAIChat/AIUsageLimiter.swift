//
//  AIUsageLimiter.swift
//  NKJV Bible
//
//  Daily free uses for AI features, then credits (WalletMoney) or unlimited with an auto-renewing plan.
//

import UIKit
import SwiftUI
import Toast_Swift

enum AIUsageFeature: String {
    case explanation
    case chapterSummary
    case aiChat
    case quiz

    var dailyFreeLimit: Int {
        switch self {
        case .explanation: return 1
        case .chapterSummary: return 1
        case .aiChat: return 3
        case .quiz: return 1
        }
    }

    var creditCost: Int { 20 }

    var title: String {
        switch self {
        case .explanation: return "Get Explanation"
        case .chapterSummary: return "Chapter Summary"
        case .aiChat: return "AI Chat"
        case .quiz: return "Quiz"
        }
    }
}

final class AIUsageLimiter {

    static let shared = AIUsageLimiter()

    private enum Payment {
        case unlimited
        case free
        case credits(Int)
    }

    /// Access granted but not yet charged; charged in `commit` once the result succeeds.
    private var pending: [AIUsageFeature: Payment] = [:]

    /// Legacy paid-app customers and Monthly / Yearly (auto-renewing) plans are unlimited. Lifetime IAP (and exit offer) still uses credits.
    var hasUnlimitedPlan: Bool {
        if LegacyPaidAppService.shared.isLegacyPaidAppUser { return true }
        guard PaymentHistory.sharedInstance.hasActivePurchase() else { return false }
        let paymentId = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
        let isLifetime = !SUBSCRIPTIONID_LifeTime.isEmpty && paymentId == SUBSCRIPTIONID_LifeTime
        return !isLifetime
    }

    func freeUsesLeft(_ feature: AIUsageFeature) -> Int {
        max(0, feature.dailyFreeLimit - usedToday(feature))
    }

    /// Quiz types other than Fill in the Verse are locked once today's free quiz is used.
    var isQuizUnlocked: Bool {
        hasUnlimitedPlan || freeUsesLeft(.quiz) > 0
    }

    func isLocked(_ feature: AIUsageFeature) -> Bool {
        !hasUnlimitedPlan && freeUsesLeft(feature) == 0
    }

    private static let lockBadgeTag = 0x10C4

    /// Shows a small lock icon at the trailing edge of `button` while `feature` has no free uses left.
    func applyLockBadge(to button: UIButton?, feature: AIUsageFeature, tint: UIColor? = nil) {
        guard let button = button else { return }
        let locked = isLocked(feature)
        if let existing = button.viewWithTag(Self.lockBadgeTag) {
            existing.isHidden = !locked
            existing.tintColor = tint ?? button.currentTitleColor
            return
        }
        guard locked else { return }
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let badge = UIImageView(image: UIImage(systemName: "lock.fill", withConfiguration: config))
        badge.tag = Self.lockBadgeTag
        badge.tintColor = tint ?? button.currentTitleColor
        badge.contentMode = .scaleAspectFit
        badge.isUserInteractionEnabled = false
        badge.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
            badge.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    /// Calls `onGranted` when the user may proceed. Call `commit(_:)` after the result succeeds.
    func requestAccess(_ feature: AIUsageFeature, from host: UIViewController? = nil, onGranted: @escaping () -> Void) {
        if hasUnlimitedPlan {
            pending[feature] = .unlimited
            onGranted()
            return
        }
        if freeUsesLeft(feature) > 0 {
            pending[feature] = .free
            onGranted()
            return
        }
        DispatchQueue.main.async {
            self.presentLimitReachedAlert(feature, from: host, onGranted: onGranted)
        }
    }

    func commit(_ feature: AIUsageFeature) {
        guard let payment = pending.removeValue(forKey: feature) else { return }
        switch payment {
        case .unlimited:
            break
        case .free:
            setUsedToday(feature, count: usedToday(feature) + 1)
        case .credits(let cost):
            _ = ChallengeWallet.spend(cost)
        }
    }

    // MARK: Daily counter

    private func countKey(_ feature: AIUsageFeature) -> String { "AIUsage_\(feature.rawValue)_count" }
    private func dateKey(_ feature: AIUsageFeature) -> String { "AIUsage_\(feature.rawValue)_date" }
    private var today: String { Date().string(format: "dd-MM-yyyy") }

    private func usedToday(_ feature: AIUsageFeature) -> Int {
        guard UserDefaults.standard.string(forKey: dateKey(feature)) == today else { return 0 }
        return UserDefaults.standard.integer(forKey: countKey(feature))
    }

    private func setUsedToday(_ feature: AIUsageFeature, count: Int) {
        UserDefaults.standard.set(today, forKey: dateKey(feature))
        UserDefaults.standard.set(count, forKey: countKey(feature))
    }

    // MARK: Alerts

    private func presentLimitReachedAlert(_ feature: AIUsageFeature, from host: UIViewController?, onGranted: @escaping () -> Void) {
        guard let presenter = host ?? OnboardingAuthManager.topViewController() else { return }
        if presenter.presentedViewController is UIAlertController { return }

        let cost = feature.creditCost
        let freeText = feature.dailyFreeLimit == 1 ? "free \(feature.title)" : "\(feature.dailyFreeLimit) free \(feature.title) uses"
        let message = "You've used today's \(freeText). Use \(cost) credits (you have \(ChallengeWallet.coins)) or get unlimited with a plan."

        let alert = UIAlertController(title: "Daily Free Limit Reached", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use \(cost) Credits", style: .default) { [weak self] _ in
            guard ChallengeWallet.coins >= cost else {
                ChallengeWallet.openWalletScreen()
                return
            }
            self?.pending[feature] = .credits(cost)
            onGranted()
        })
        alert.addAction(UIAlertAction(title: "Get Unlimited", style: .default) { [weak self] _ in
            self?.presentPaywall()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presenter.present(alert, animated: true)
    }

    private func presentPaywall() {
        DispatchQueue.main.async {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            guard NetworkManager.sharedInstance.isConnectedToInternet() else {
                top.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                return
            }
            if #available(iOS 15.0, *) {
                var swiftUIView = BibleSubscriptionView(isPresentedFromOnboarding: false)
                swiftUIView.dismissHandler = { [weak top] in
                    top?.dismiss(animated: true, completion: nil)
                }
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                top.present(hostingController, animated: true, completion: nil)
            } else {
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
                if let nav = top.navigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    top.present(vc, animated: true)
                }
            }
        }
    }
}
