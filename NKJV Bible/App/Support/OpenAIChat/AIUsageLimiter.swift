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

    var creditCost: Int {
        switch self {
        case .quiz: return 10
        default: return 20
        }
    }

    /// Fill the Verse stays free. Other quiz types charge `creditCost` (10) per question after today's free quiz.
    var chargesCredits: Bool { true }

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
    /// The chat limit sheet has already been shown. Later sends can spend credits.
    private var chatUpsellShown = false

    func markChatUpsellShown() {
        chatUpsellShown = true
    }

    static let chatCreditsAdded = Notification.Name("AIUsageChatCreditsAdded")

    func noteChatCreditsAdded(_ amount: Int) {
        chatUpsellShown = true
        NotificationCenter.default.post(name: Self.chatCreditsAdded, object: nil, userInfo: ["amount": amount])
    }

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
        !AIUsageFeature.quiz.chargesCredits || hasUnlimitedPlan || freeUsesLeft(.quiz) > 0
    }

    func isLocked(_ feature: AIUsageFeature) -> Bool {
        guard feature.chargesCredits, !hasUnlimitedPlan, freeUsesLeft(feature) == 0 else { return false }
        if feature == .aiChat && ChallengeWallet.coins >= feature.creditCost { return false }
        return true
    }

    private static let lockBadgeTag = 0x10C4

    /// Shows a small lock icon at the trailing edge of `button` while `feature` has no free uses left.
    func applyLockBadge(to button: UIButton?, feature: AIUsageFeature, tint: UIColor? = nil) {
        guard let button = button else { return }
        let locked = isLocked(feature)
        alignLockTitle(on: button, locked: locked)
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
            badge.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            badge.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 14),
            badge.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    /// Shift a plain title left so the lock sits beside it. Buttons that already place an icon keep their insets.
    private func alignLockTitle(on button: UIButton, locked: Bool) {
        guard button.image(for: .normal) == nil else { return }
        button.titleEdgeInsets = locked
            ? UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 22)
            : .zero
    }

    /// Calls `onGranted` when the user may proceed. Call `commit(_:)` after the result succeeds.
    /// `units` multiplies the credit cost (e.g. number of quiz questions).
    func requestAccess(_ feature: AIUsageFeature, units: Int = 1, from host: UIViewController? = nil, onGranted: @escaping () -> Void) {
        // Keep onGranted alive across the disclaimer dismiss — do not rely on the caller's view staying around.
        let grant = onGranted
        if !AIDisclaimer.isAccepted {
            AIDisclaimer.present {
                // Singleton — always re-enter after Continue so the explanation/chat/summary/quiz opens.
                AIUsageLimiter.shared.requestAccess(feature, units: units, from: host, onGranted: grant)
            }
            return
        }
        if !feature.chargesCredits || hasUnlimitedPlan {
            pending[feature] = .unlimited
            DispatchQueue.main.async(execute: grant)
            return
        }
        if freeUsesLeft(feature) > 0 {
            pending[feature] = .free
            DispatchQueue.main.async(execute: grant)
            return
        }
        DispatchQueue.main.async {
            self.presentLimitReachedAlert(feature, cost: feature.creditCost * max(1, units), from: host, onGranted: grant)
        }
    }

    static let usageChanged = Notification.Name("AIUsageLimiterUsageChanged")

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
        NotificationCenter.default.post(name: Self.usageChanged, object: nil, userInfo: ["feature": feature.rawValue])
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

    /// The trigger sheet stays closed for 30 minutes. Offer credits, or say the free use is gone.
    private func offerCreditsOrToast(_ feature: AIUsageFeature, cost: Int, onGranted: @escaping () -> Void) {
        let kind = feature == .chapterSummary ? "chapter summary" : "explanation"
        guard ChallengeWallet.coins >= cost else {
            OnboardingAuthManager.topViewController()?.view.makeToast("You've used today's free \(kind).", duration: 2.0, position: .top)
            return
        }
        guard let presenter = OnboardingAuthManager.topViewController() else { return }
        if presenter.presentedViewController != nil { return }
        let alert = UIAlertController(
            title: "Use \(cost) credits?",
            message: "Today's free \(kind) is used. You have \(ChallengeWallet.coins) credits.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Use \(cost) Credits", style: .default) { [weak self] _ in
            self?.pending[feature] = .credits(cost)
            onGranted()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presenter.present(alert, animated: true)
    }

    private func presentLimitReachedAlert(_ feature: AIUsageFeature, cost: Int, from host: UIViewController?, onGranted: @escaping () -> Void) {
        if PaywallTriggerGate.shared.isEnabled && feature != .quiz {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self = self else { return }
                App_Protocol.delegateReader?.CloseMenu()
                if feature == .aiChat && self.chatUpsellShown && ChallengeWallet.coins >= cost {
                    self.pending[feature] = .credits(cost)
                    onGranted()
                    return
                }
                if feature == .aiChat {
                    let name = ChallengeWallet.coins <= 0 ? "chatCredits" : "chatLimit"
                    PaywallTriggerGate.shared.requestUserStarted(name)
                    return
                }
                if PaywallTriggerGate.shared.isUserStartedCoolingDown("aiExplain") {
                    self.offerCreditsOrToast(feature, cost: cost, onGranted: onGranted)
                    return
                }
                PaywallTriggerGate.shared.requestUserStarted("aiExplain")
            }
            return
        }
        guard let presenter = host ?? OnboardingAuthManager.topViewController() else { return }
        if presenter.presentedViewController is UIAlertController { return }

        let freeText = feature.dailyFreeLimit == 1 ? "free \(feature.title)" : "\(feature.dailyFreeLimit) free \(feature.title) uses"
        let message = "You've used today's \(freeText). Use \(cost) credits (you have \(ChallengeWallet.coins)) or get unlimited with a plan."

        let alert = UIAlertController(title: "Daily Free Limit Reached", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use \(cost) Credits", style: .default) { [weak self] _ in
            // The alert is still closing. Opening the Wallet on it freezes the screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                App_Protocol.delegateReader?.CloseMenu()
                guard ChallengeWallet.coins >= cost else {
                    if feature == .aiChat && PaywallTriggerGate.shared.isEnabled {
                        PaywallTriggerGate.shared.requestUserStarted("chatCredits")
                        return
                    }
                    ChallengeWallet.openWalletScreen()
                    return
                }
                self?.pending[feature] = .credits(cost)
                onGranted()
            }
        })
        alert.addAction(UIAlertAction(title: "Get Unlimited", style: .default) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.presentPaywall()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presenter.present(alert, animated: true)
    }

    private func presentPaywall() {
        if PaywallTriggerGate.shared.isEnabled {
            let name = "aiLimit"
            PaywallTriggerGate.shared.requestUserStarted(name)
            return
        }
        DispatchQueue.main.async {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            guard NetworkManager.sharedInstance.isConnectedToInternet() else {
                top.view.makeToast("No internet connection", duration: 2.0, position: .top)
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
