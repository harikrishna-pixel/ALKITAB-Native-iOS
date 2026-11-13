//
//  PaywallTriggerScreens.swift
//  NKJV Bible
//
//  Trigger screens from the paywall spec images. The current full paywall stays for other entries.
//

import SwiftUI
import UIKit
import SafariServices
import Combine
import MessageUI
import StoreKit
import Toast_Swift

enum PaywallTriggerReward {
    static var onReward: (() -> Void)?

    static func deliver() {
        let work = onReward
        onReward = nil
        DispatchQueue.main.async {
            work?()
        }
    }
}

enum PaywallTriggerScreen {
    case aiStudy
    case chatFree
    case chatCredits
    case imageLimit
    case chapters(Int)
    case adCard
    case book(String)
    case streak(Int)
    case day30
    case plans
    case feedback(String, Int)
    case feedbackForm
    case feedbackThanks
    case streakRating

    var isFullPage: Bool {
        switch self {
        case .book, .streak, .day30, .plans, .feedback, .feedbackForm, .feedbackThanks, .streakRating:
            return true
        default:
            return false
        }
    }

    static func from(trigger: String) -> PaywallTriggerScreen? {
        switch trigger {
        case "settings": return .plans
        case "aiExplain", "aiLimit": return .aiStudy
        case "chatLimit": return .chatFree
        case "chatCredits": return .chatCredits
        case "image": return .imageLimit
        case "chapter.5": return .chapters(5)
        case "chapter.10": return .chapters(10)
        case "streak.3": return .streak(3)
        case "streak.7": return .streak(7)
        case "streak.30": return .day30
        default:
            if trigger.hasPrefix("ad.3") { return .adCard }
            if trigger.hasPrefix("book.") {
                let name = String(trigger.dropFirst(5))
                return name.isEmpty ? nil : .book(name)
            }
            return nil
        }
    }
}

enum PaywallTriggerPresenter {
    static func canPresent(_ trigger: String) -> Bool {
        guard let screen = PaywallTriggerScreen.from(trigger: trigger) else { return false }
        return pricesReady(screen)
    }

    /// `onPresented` reports whether the sheet actually appeared (a busy screen can refuse it).
    static func show(trigger: String, from top: UIViewController, onClose: @escaping () -> Void, onPresented: ((Bool) -> Void)? = nil) -> Bool {
        guard let screen = PaywallTriggerScreen.from(trigger: trigger), pricesReady(screen) else { return false }
        present(screen, from: top, onboarding: false, onClose: onClose, onPresented: onPresented)
        return true
    }

    /// Opens the main plans paywall directly, without the trigger rules. False if prices are not loaded yet.
    @discardableResult
    static func showMainPlans(from top: UIViewController) -> Bool {
        guard pricesReady(.plans) else { return false }
        present(.plans, from: top, onboarding: false, onClose: {})
        return true
    }

    static func showFeedback(book: String, chapters: Int, from top: UIViewController) {
        present(.feedback(book, chapters), from: top, onboarding: false, onClose: {
            PaywallTriggerGate.shared.noteFeedbackFlowClosed()
        })
    }

    static func showStreakRating(from top: UIViewController) {
        present(.streakRating, from: top, onboarding: false, onClose: {})
    }

    private static func pricesReady(_ screen: PaywallTriggerScreen) -> Bool {
        switch screen {
        case .aiStudy, .chatFree, .chatCredits:
            return !TriggerPrices.year.isEmpty && !TriggerPrices.month.isEmpty
        case .plans:
            return !TriggerPrices.year.isEmpty && !TriggerPrices.month.isEmpty && !TriggerPrices.life.isEmpty
        case .streak(let day) where day == 3:
            return !TriggerPrices.life.isEmpty
        case .book:
            return !TriggerPrices.life.isEmpty
        case .imageLimit, .chapters, .streak:
            return !TriggerPrices.life.isEmpty && !TriggerPrices.year.isEmpty
        case .day30:
            return !TriggerPrices.life.isEmpty
        case .adCard, .feedback, .feedbackForm, .feedbackThanks, .streakRating:
            return true
        }
    }

    static func dismiss(_ host: UIViewController?) {
        guard let host = host else { return }
        if let presented = host.presentedViewController {
            presented.dismiss(animated: true) {
                host.dismiss(animated: true)
            }
        } else {
            host.dismiss(animated: true)
        }
    }

    private static func present(_ screen: PaywallTriggerScreen, from top: UIViewController, onboarding: Bool, onClose: @escaping () -> Void, onPresented: ((Bool) -> Void)? = nil, retry: Bool = true) {
        // An ad or another modal is still opening or closing — wait once, then present from the new top.
        if top.isBeingPresented || top.isBeingDismissed || top.transitionCoordinator != nil || top.presentedViewController?.isBeingDismissed == true {
            guard retry else {
                onPresented?(false)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let next = OnboardingAuthManager.topViewController() ?? top
                present(screen, from: next, onboarding: onboarding, onClose: onClose, onPresented: onPresented, retry: false)
            }
            return
        }
        let box = TriggerHostBox()
        let root = PaywallTriggerRoot(screen: screen, onboarding: onboarding, onClose: onClose, dismissHost: {
            PaywallTriggerPresenter.dismiss(box.host)
        })
        let host = UIHostingController(rootView: root)
        box.host = host
        // Match screen chrome under the status bar (cream was showing as a white top strip).
        let darkNavy = UIColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1)
        let cream = UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1)
        switch screen {
        case .plans, .day30:
            host.view.backgroundColor = darkNavy
        case .book, .streak, .feedback, .feedbackForm, .feedbackThanks, .streakRating:
            host.view.backgroundColor = cream
        default:
            host.view.backgroundColor = .clear
        }
        host.modalPresentationStyle = screen.isFullPage ? .fullScreen : .overFullScreen
        switch screen {
        case .aiStudy, .chatFree, .chatCredits, .imageLimit, .chapters:
            // Dim fades in place; TriggerSheetChrome slides the sheet up itself.
            host.modalTransitionStyle = .crossDissolve
        default:
            break
        }
        var reported = false
        let report: (Bool) -> Void = { shown in
            guard !reported else { return }
            reported = true
            onPresented?(shown)
        }
        top.present(host, animated: true) {
            report(host.presentingViewController != nil)
        }
        // UIKit may skip the completion when it refuses the present.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak host] in
            report(host?.presentingViewController != nil)
        }
    }
}

private final class TriggerHostBox {
    weak var host: UIViewController?
}

struct PaywallTriggerOnboardingView: View {
    var body: some View {
        PaywallTriggerRoot(screen: .plans, onboarding: true, onClose: {})
            .navigationBarHidden(true)
    }
}

private enum TriggerPrices {
    static var month: String { show(StoreManager.shared.price1, cache: "PriceTag1") }
    static var year: String { show(StoreManager.shared.price2, cache: "PriceTag2") }
    static var life: String { show(StoreManager.shared.price3, cache: "PriceTag3") }
    static var offer: String {
        let live = StoreManager.shared.exitOfferPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        return live.isEmpty ? "" : pretty(live)
    }

    static func show(_ live: String, cache: String) -> String {
        let trimmed = live.trimmingCharacters(in: .whitespacesAndNewlines)
        let raw = trimmed.isEmpty ? (UserDefaults.standard.string(forKey: cache) ?? "") : trimmed
        return pretty(raw)
    }

    static func pretty(_ raw: String) -> String {
        // Keep the exact StoreKit localized string (e.g. $14.99), no integer rounding.
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func amount(_ text: String) -> Double? {
        let digits = text.filter { $0.isNumber || $0 == "." }
        return Double(digits)
    }

    static func perMonth(_ yearly: String) -> String {
        guard let value = amount(yearly), value > 0 else { return "" }
        let month = value / 12.0
        let symbol = yearly.prefix { !$0.isNumber && $0 != "." && $0 != "," }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let number = formatter.string(from: NSNumber(value: month)) ?? String(format: "%.2f", month)
        return "\(symbol)\(number) / month"
    }
}

private final class PaywallTriggerModel: ObservableObject {
    let store = StoreManager()
    @Published var buying = false
    @Published var loading = false
    var onFinished: (() -> Void)?
    private var priceWatch: AnyCancellable?
    private var alertWatch: AnyCancellable?
    private var sheetWatch: AnyCancellable?
    private var restoring = false

    func prepare() {
        priceWatch = store.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        alertWatch = store.$showAlert.sink { [weak self] shown in
            guard shown else { return }
            DispatchQueue.main.async { self?.stopLoading() }
        }
        // Apple's purchase sheet makes the app resign active; restore keeps its loader until it finishes.
        sheetWatch = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            guard let self = self, !self.restoring else { return }
            self.loading = false
        }
        store.setupProducts()
        store.onPurchaseSuccess = { [weak self] in
            self?.stopLoading()
            UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
            self?.onFinished?()
        }
        store.onPurchaseFailure = { [weak self] _ in
            self?.stopLoading()
        }
        store.onRestoreSuccess = { [weak self] in
            self?.stopLoading()
            UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
            self?.onFinished?()
        }
        store.onRestoreFailed = { [weak self] in
            self?.stopLoading()
        }
    }

    func buy(_ identifier: String) {
        restoring = false
        buying = true
        loading = true
        store.purchaseProduct(with: identifier)
    }

    func restore() {
        restoring = true
        buying = true
        loading = true
        store.restorePurchases()
    }

    private func stopLoading() {
        restoring = false
        buying = false
        loading = false
    }

    var month: String { TriggerPrices.show(store.price1, cache: "PriceTag1") }
    var year: String { TriggerPrices.show(store.price2, cache: "PriceTag2") }
    var life: String { TriggerPrices.show(store.price3, cache: "PriceTag3") }
    var offer: String {
        let live = store.exitOfferPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        return live.isEmpty ? "" : TriggerPrices.pretty(live)
    }
}

private struct PaywallTriggerRoot: View {
    let screen: PaywallTriggerScreen
    var onboarding: Bool
    var onClose: () -> Void
    var dismissHost: () -> Void = {}

    @StateObject private var model = PaywallTriggerModel()
    @State private var followUp: PaywallTriggerScreen?
    @State private var showExit = false

    var body: some View {
        ZStack {
            // Fill under status bar so host never flashes a white/cream strip.
            rootFillColor.ignoresSafeArea()

            if showExit {
                TriggerExitOffer(model: model, onClose: finishOnboarding, onRestore: { model.restore() })
            } else if let followUp = followUp {
                screenBody(followUp)
            } else {
                screenBody(screen)
            }
            if model.loading {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 16) {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Processing...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .ignoresSafeArea()
        .alert(model.store.alertTitle, isPresented: Binding(
            get: { model.store.showAlert },
            set: { model.store.showAlert = $0 }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.store.alertMessage)
        }
        .onAppear {
            model.onFinished = {
                if onboarding {
                    finishOnboarding()
                } else {
                    closeModal()
                }
            }
            model.prepare()
            if case .streakRating = screen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    PaywallTriggerGate.shared.playSystemRating()
                }
            }
        }
    }

    private var rootFillColor: Color {
        if showExit { return Color(hex: "070E1E") }
        switch screen {
        case .plans, .day30:
            return Color(hex: "070E1E")
        case .book, .streak, .feedback, .feedbackForm, .feedbackThanks, .streakRating:
            return Color(hex: "F7F3EA")
        default:
            return .clear
        }
    }

    @ViewBuilder
    private func screenBody(_ item: PaywallTriggerScreen) -> some View {
        switch item {
        case .aiStudy:
            TriggerAISheet(
                title: "Go deeper in every chapter",
                subtitle: "Unlimited explanations, summaries and Bible Chat",
                button: "Continue with 1 Year",
                showAdLink: false,
                model: model,
                onClose: closeModal
            )
        case .chatFree:
            TriggerAISheet(
                title: "Keep the conversation going",
                subtitle: "You have used your 3 free messages. Premium is unlimited.",
                button: "Unlock Bible Chat",
                showAdLink: false,
                model: model,
                onClose: closeModal
            )
        case .chatCredits:
            TriggerAISheet(
                title: "Keep asking, keep growing",
                subtitle: "Your chat credits are finished. Premium is unlimited.",
                button: "Unlock Unlimited AI",
                showAdLink: true,
                model: model,
                onClose: closeModal
            )
        case .imageLimit:
            TriggerDownloadSheet(model: model, onClose: closeModal)
        case .chapters(let count):
            TriggerLifetimeSheet(
                title: count > 0 ? "Reading without interruptions" : "Read without ads",
                subtitle: count > 0
                    ? "You have read \(count) chapters. Pay once and keep reading ad-free."
                    : "Pay once. No ads, forever.",
                model: model,
                onClose: closeModal
            )
        case .adCard:
            TriggerAdSoftCard(onGo: openLifetimeSheet, onNotNow: closeModal)
        case .book(let name):
            TriggerPromptCard(
                icon: "book.fill",
                heading: "You finished \(name)",
                detail: chapterLine(name),
                cardTitle: "Read the next book without ads",
                cardDetail: "Pay once. No ads, forever.",
                nextLine: nextBookLine(name),
                onGo: { model.buy(SUBSCRIPTIONID_LifeTime) },
                onNotNow: closeModal
            )
        case .streak(let day):
            if day == 3 {
                TriggerDay3Card(
                    onGo: openMainPlans,
                    onNotNow: closeModal
                )
            } else {
                TriggerPromptCard(
                    icon: "flame.fill",
                    heading: "\(day)-day streak",
                    detail: "A full week with the Word",
                    cardTitle: "Keep your streak ad-free",
                    cardDetail: "Pay once and read without ads, forever.",
                    onGo: openLifetimeSheet,
                    onNotNow: closeModal
                )
            }
        case .day30:
            TriggerDay30(model: model, onClose: closeModal)
        case .plans:
            TriggerPlans(model: model, onClose: closePlans)
        case .feedback(let book, let chapters):
            TriggerFeedbackCard(
                book: book,
                chapters: chapters,
                onGreat: handleFeedbackGreat,
                onBetter: handleFeedbackBetter
            )
        case .feedbackForm:
            TriggerFeedbackForm(onClose: closeModal)
        case .feedbackThanks:
            TriggerFeedbackThanks(onClose: closeModal)
        case .streakRating:
            TriggerStreakRating(onClose: closeModal)
        }
    }

    private func handleFeedbackGreat() {
        if PaywallTriggerGate.shared.shouldOfferRatingAfterFeedbackGreat() {
            closeModal()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                PaywallTriggerGate.shared.playFeedbackGreatRating()
            }
        } else {
            followUp = .feedbackThanks
        }
    }

    /// "Could be better" opens the app's default Feedback screen.
    private func handleFeedbackBetter() {
        closeModal()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            SendMail.shared.FeedbackNavigation(presentViewcontroll: top)
        }
    }

    /// Close this card, then open the main plans paywall in its place.
    private func openMainPlans() {
        closeModal()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard let top = OnboardingAuthManager.topViewController(),
                  PaywallTriggerPresenter.showMainPlans(from: top) else {
                OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
                return
            }
        }
    }

    private func openLifetimeSheet() {
        guard !TriggerPrices.life.isEmpty, !TriggerPrices.year.isEmpty else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return
        }
        followUp = .chapters(0)
    }

    private func closePlans() {
        if onboarding {
            // Always show the exit offer; it shows its own loading / no-internet / retry price states.
            showExit = true
        } else if onboarding {
            finishOnboarding()
        } else {
            closeModal()
        }
    }

    private func closeModal() {
        dismissHost()
        onClose()
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
        OnboardingProgress.markCompleted()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let nav = window.rootViewController as? UINavigationController else {
            closeModal()
            return
        }
        let reader = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
        nav.setViewControllers([reader], animated: true)
    }

    private func chapterLine(_ book: String) -> String {
        guard UserDefaults.standard.string(forKey: "SelectedLanguage") != nil else { return "" }
        let count = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: book)
        guard count > 0 else { return "" }
        return "\(count) chapters read"
    }

    private func nextBookLine(_ book: String) -> String? {
        guard UserDefaults.standard.string(forKey: "SelectedLanguage") != nil else { return nil }
        let books = BibleContent.sharedInstance.BookToPosition()
        guard let index = books.firstIndex(where: { $0.caseInsensitiveCompare(book) == .orderedSame }),
              index + 1 < books.count else { return nil }
        let next = "\(books[index + 1]) 1"
        let version = (short_lang_code.isEmpty ? language_name : short_lang_code)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !version.isEmpty else { return next }
        return "\(next) · \(version)"
    }
}

private struct TriggerAISheet: View {
    let title: String
    let subtitle: String
    let button: String
    let showAdLink: Bool
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    @State private var yearly = true

    var body: some View {
        TriggerSheetChrome(onClose: onClose) {
            Text(title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(Color(hex: "12315C"))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "66758C"))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
            TriggerYearCard(price: model.year, perMonth: TriggerPrices.perMonth(model.year), selected: yearly) {
                yearly = true
            }
            .padding(.top, 16)
            Button(action: { yearly = false }) {
                Text("1 Month  ·  \(model.month)  ·  renews monthly")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "12315C"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(yearly ? Color(hex: "D5DEEE") : Color(hex: "2456C7"), lineWidth: yearly ? 1 : 1.5)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
            TriggerBuyButton(title: yearly ? button : "Continue with 1 Month", enabled: !model.buying) {
                model.buy(yearly ? SUBSCRIPTIONID_OneYear : SUBSCRIPTIONID_Six_month)
            }
            .padding(.top, 14)
            if showAdLink {
                Button(action: watchForCredits) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("Or watch an ad for credits")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "2456C7"))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 12)
            }
            Text(renewalLine)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8B95A7"))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            TriggerLegalRow(onRestore: { model.restore() })
                .padding(.top, 8)
        }
    }

    private var renewalLine: String {
        let price = yearly ? model.year : model.month
        let period = yearly ? "year" : "month"
        return "\(price) per \(period), renews every \(period) until cancelled. Cancel anytime in iPhone Settings → Apple ID → Subscriptions."
    }

    private func watchForCredits() {
        PaywallTriggerReward.onReward = {
            let add = rewardCoins > 0 ? rewardCoins : 20
            let balance = UserDefaults.standard.integer(forKey: "WalletMoney")
            UserDefaults.standard.set(balance + add, forKey: "WalletMoney")
            onClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                AIUsageLimiter.shared.noteChatCreditsAdded(add)
            }
        }
        guard let host = OnboardingAuthManager.topViewController() else { return }
        AdmobManager.shared.IronSource_Reward_ShowAds(vw: host, RewardAd: "PaywallTrigger")
    }
}

private struct TriggerDownloadSheet: View {
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    @State private var lifetime = true

    var body: some View {
        TriggerSheetChrome(onClose: onClose) {
            Text("3 free downloads used today")
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(Color(hex: "12315C"))
                .multilineTextAlignment(.center)
            Text("Watch a short ad for 3 more, or download without limits.")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "66758C"))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
            Button(action: watchForImages) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Watch an ad for 3 more images")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(Color(hex: "12315C"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "D5DEEE"), lineWidth: 1.5)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 16)
            TriggerPlanRow(
                title: "Lifetime",
                detail: "Unlimited downloads · no ads · no AI",
                price: model.life,
                badge: "Pay once",
                badgeGold: true,
                selected: lifetime
            ) { lifetime = true }
            .padding(.top, 10)
            TriggerPlanRow(
                title: "1 Year",
                detail: "Unlimited downloads + AI · \(TriggerPrices.perMonth(model.year))",
                price: model.year,
                badge: "Ad-free + AI",
                badgeGold: false,
                selected: !lifetime
            ) { lifetime = false }
            .padding(.top, 10)
            TriggerBuyButton(title: buyTitle, enabled: !model.buying && !buyPrice.isEmpty) {
                model.buy(lifetime ? SUBSCRIPTIONID_LifeTime : SUBSCRIPTIONID_OneYear)
            }
            .padding(.top, 14)
            Text(lifetime
                 ? "One-time purchase. Nothing renews. Removes ads and download limits; does not include AI."
                 : "\(model.year) per year, renews every year until cancelled. Cancel anytime in iPhone Settings → Apple ID → Subscriptions.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8B95A7"))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            TriggerLegalRow(onRestore: { model.restore() })
                .padding(.top, 8)
        }
    }

    private var buyPrice: String { lifetime ? model.life : model.year }
    private var buyTitle: String { lifetime ? "Get Lifetime · \(model.life)" : "Get 1 Year · \(model.year)" }

    private func watchForImages() {
        PaywallTriggerReward.onReward = {
            let bonus = UserDefaults.standard.integer(forKey: "PaywallTriggerImageBonus") + 3
            UserDefaults.standard.set(bonus, forKey: "PaywallTriggerImageBonus")
            onClose()
        }
        guard let host = OnboardingAuthManager.topViewController() else { return }
        AdmobManager.shared.IronSource_Reward_ShowAds(vw: host, RewardAd: "PaywallTrigger")
    }
}

private struct TriggerLifetimeSheet: View {
    let title: String
    let subtitle: String
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    @State private var lifetime = true

    var body: some View {
        TriggerSheetChrome(onClose: onClose) {
            Text(title.isEmpty ? "Read without ads" : title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(Color(hex: "12315C"))
                .multilineTextAlignment(.center)
            Text(subtitle.isEmpty ? "Pay once. No ads, forever." : subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "66758C"))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
            TriggerPlanRow(
                title: "Lifetime",
                detail: "Ad-free reading, no AI",
                price: model.life,
                badge: "Pay once",
                badgeGold: true,
                selected: lifetime
            ) { lifetime = true }
            .padding(.top, 16)
            TriggerPlanRow(
                title: "1 Year",
                detail: TriggerPrices.perMonth(model.year),
                price: model.year,
                badge: "Ad-free + AI",
                badgeGold: false,
                selected: !lifetime
            ) { lifetime = false }
            .padding(.top, 10)
            TriggerBuyButton(title: lifetime ? "Get Lifetime · \(model.life)" : "Get 1 Year · \(model.year)", enabled: !model.buying) {
                model.buy(lifetime ? SUBSCRIPTIONID_LifeTime : SUBSCRIPTIONID_OneYear)
            }
            .padding(.top, 14)
            Text(lifetime
                 ? "One-time purchase. Nothing renews. Removes ads; does not include AI."
                 : "\(model.year) per year, renews every year until cancelled. Cancel anytime in iPhone Settings → Apple ID → Subscriptions.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8B95A7"))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            TriggerLegalRow(onRestore: { model.restore() })
                .padding(.top, 8)
        }
    }
}

private struct TriggerSheetChrome<Content: View>: View {
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content
    @State private var dragOffset: CGFloat = 0
    @State private var isDismissing = false
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45 * dimOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismissSheet() }

            VStack(spacing: 0) {
                // Large top handle hit area — swipe down from here to dismiss.
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color(hex: "E1E6EF"))
                        .frame(width: 42, height: 5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .contentShape(Rectangle())
                .highPriorityGesture(sheetDismissDrag)

                // Wrapped so padding applies once to the block, not to every child view.
                VStack(spacing: 0) {
                    content()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, max(12, sheetBottomInset))
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .background(
                TopRoundedShape(radius: 28)
                    .fill(Color.white)
                    .ignoresSafeArea(edges: .bottom)
            )
            .offset(y: appeared ? max(0, dragOffset) : UIScreen.main.bounds.height)
            // Body can also pull down; simultaneous so plan/CTA taps still work.
            .simultaneousGesture(sheetDismissDrag)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
    }

    private var sheetBottomInset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }

    private var dimOpacity: Double {
        guard dragOffset > 0 else { return 1 }
        return max(0.25, 1 - Double(dragOffset) / 420)
    }

    private var sheetDismissDrag: some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { value in
                guard !isDismissing else { return }
                // Downward only — ignore upward rubber-band.
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                guard !isDismissing else { return }
                let pulled = value.translation.height
                let fling = value.predictedEndTranslation.height
                if pulled > 90 || fling > 160 {
                    dismissSheet()
                } else {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismissSheet() {
        guard !isDismissing else { return }
        isDismissing = true
        let travel = UIScreen.main.bounds.height
        withAnimation(.easeIn(duration: 0.22)) {
            dragOffset = travel
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onClose()
        }
    }
}

private struct TriggerYearCard: View {
    let price: String
    let perMonth: String
    let selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("1 Year")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                    Text(perMonth)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "66758C"))
                }
                Spacer()
                Text(price)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "F4F7FF"))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "2456C7"), lineWidth: selected ? 1.5 : 0))
            )
            .overlay(
                Text("Best value")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(hex: "2456C7")))
                    .offset(y: -12),
                alignment: .topTrailing
            )
            .padding(.top, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct TriggerPlanRow: View {
    let title: String
    let detail: String
    let price: String
    let badge: String
    let badgeGold: Bool
    let selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                    if !detail.isEmpty {
                        Text(detail)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "66758C"))
                    }
                }
                Spacer()
                Text(price)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selected ? Color(hex: "F4F7FF") : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selected ? Color(hex: "2456C7") : Color(hex: "D5DEEE"), lineWidth: selected ? 1.5 : 1)
                    )
            )
            .overlay(
                Text(badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(badgeGold ? Color(hex: "6B4E12") : .white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(badgeGold ? Color(hex: "E7C56A") : Color(hex: "2456C7")))
                    .offset(x: -10, y: -10),
                alignment: .topTrailing
            )
            .padding(.top, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct TriggerBuyButton: View {
    let title: String
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Capsule().fill(Color(hex: "2456C7")))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.55)
    }
}

private struct TriggerLegalRow: View {
    var onRestore: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button("Restore Purchases", action: onRestore)
            Text("·").foregroundColor(Color(hex: "2456C7"))
            Button("Terms") { open(TermsURL) }
            Text("·").foregroundColor(Color(hex: "2456C7"))
            Button("Privacy") { open(PrivacyURL) }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(Color(hex: "2456C7"))
        .buttonStyle(PlainButtonStyle())
    }

    private func open(_ urlString: String) {
        guard let url = URL(string: urlString),
              let host = OnboardingAuthManager.topViewController() else { return }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .close
        host.present(safari, animated: true)
    }
}

/// HTML image 04. Small card on the next screen. Go Ad-Free opens the Lifetime / 1 Year sheet.
private struct TriggerAdSoftCard: View {
    var onGo: () -> Void
    var onNotNow: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onNotNow)
            VStack(alignment: .leading, spacing: 12) {
                Text("Read without ads")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                Text("Pay once and read without ads, forever.")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "66758C"))
                Button(action: onGo) {
                    Text("Go Ad-Free")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color(hex: "2456C7")))
                }
                .buttonStyle(PlainButtonStyle())
                Button("Not now", action: onNotNow)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "8B95A7"))
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PlainButtonStyle())
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "EEF3FB")))
            .padding(.horizontal, 22)
        }
    }
}

/// HTML image 07. Soft card only: Go Ad-Free opens the main plans paywall.
private struct TriggerDay3Card: View {
    var onGo: () -> Void
    var onNotNow: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "F08A24"))
                    .padding(.top, 48)
                Text("3-day streak")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                    .padding(.top, 14)
                Text("You read the Word 3 days in a row")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "7A8494"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)
                HStack(spacing: 14) {
                    dayDot("1", filled: true)
                    dayDot("2", filled: true)
                    dayDot("3", filled: true)
                    dayDot("...", filled: false)
                }
                .padding(.top, 18)
                VStack(spacing: 12) {
                    Text("Read without ads")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Pay once, no ads, forever.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "66758C"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: onGo) {
                        Text("Go Ad-Free")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color(hex: "2456C7")))
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button("Not now", action: onNotNow)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "8B95A7"))
                        .buttonStyle(PlainButtonStyle())
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "EEF3FB")))
                .padding(.horizontal, 22)
                .padding(.top, 22)
                Spacer()
            }
        }
    }

    private func dayDot(_ title: String, filled: Bool) -> some View {
        Text(title)
            .font(.system(size: filled ? 16 : 14, weight: .bold))
            .foregroundColor(filled ? .white : Color(hex: "9AA3B2"))
            .frame(width: 40, height: 40)
            .background(Circle().fill(filled ? Color(hex: "2456C7") : Color(hex: "E4E7EE")))
    }
}

private struct TriggerPromptCard: View {
    var icon: String?
    var heading: String?
    var detail: String?
    let cardTitle: String
    let cardDetail: String
    var nextLine: String? = nil
    var onGo: () -> Void
    var onNotNow: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(spacing: 0) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 42))
                        .foregroundColor(icon == "flame.fill" ? Color(hex: "F08A24") : Color(hex: "C4493A"))
                        .padding(.top, 36)
                }
                if let heading = heading {
                    Text(heading)
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                }
                if let detail = detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "7A8494"))
                        .padding(.top, 4)
                }
                VStack(spacing: 12) {
                    Text(cardTitle)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(cardDetail)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "66758C"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: onGo) {
                        Text("Go Ad-Free")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color(hex: "2456C7")))
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button("Not now", action: onNotNow)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "8B95A7"))
                        .buttonStyle(PlainButtonStyle())
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "EEF3FB")))
                .padding(.horizontal, 22)
                .padding(.top, heading == nil ? 180 : 22)
                if let nextLine = nextLine {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Up next")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(Color(hex: "12315C"))
                        Text(nextLine)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "66758C"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                }
                Spacer()
            }
        }
    }
}

private struct TriggerFeedbackCard: View {
    let book: String
    let chapters: Int
    var onGreat: () -> Void
    var onBetter: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(spacing: 0) {
                Image(systemName: "book.fill")
                    .font(.system(size: 42))
                    .foregroundColor(Color(hex: "C4493A"))
                    .padding(.top, 36)
                Text("You finished \(book)")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
                if chapters > 0 {
                    Text("\(chapters) chapters read")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "7A8494"))
                        .padding(.top, 4)
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("How is your reading going?")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "12315C"))
                    HStack(spacing: 10) {
                        Button(action: onGreat) {
                            Text("Great")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "2456C7")))
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: onBetter) {
                            Text("Could be better")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "12315C"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "D5DEEE"), lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                .padding(.horizontal, 22)
                .padding(.top, 22)
                Spacer()
            }
        }
    }
}

private struct TriggerFeedbackForm: View {
    var onClose: () -> Void
    @State private var topic = "Reading"
    @State private var message = ""
    private let topics = ["Reading", "AI", "Verse images", "Streak", "Other"]

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "66758C"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Text("Tell us what to improve")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                    .frame(maxWidth: .infinity)
                Text("Private to our team. We read every message.")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "66758C"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                TriggerTopicWrap(topics: topics, selected: topic) { topic = $0 }
                    .padding(.top, 16)
                ZStack(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("What would make this better for you?")
                            .foregroundColor(Color(hex: "A0A8B8"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                    }
                    TextEditor(text: $message)
                        .padding(8)
                        .frame(height: 140)
                        .opacity(message.isEmpty ? 0.85 : 1)
                }
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "D5DEEE"), lineWidth: 1))
                .padding(.top, 16)
                Button(action: send) {
                    Text("Send feedback")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Color(hex: "2456C7")))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 16)
                Text("No account needed · Close anytime")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8B95A7"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                Spacer()
            }
            .padding(.horizontal, 22)
        }
    }

    private func send() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please enter your feedback", duration: 2.0, position: .top)
            return
        }
        UserDefaults.standard.set(topic, forKey: "PaywallTriggerFeedbackTopic")
        UserDefaults.standard.set(trimmed, forKey: "PaywallTriggerFeedbackNote")
        let subject = "App feedback · \(topic)"
        let body = "Topic: \(topic)\n\n\(trimmed)\n"
        TriggerFeedbackMail.send(subject: subject, body: body, onDone: onClose)
    }
}

private struct TriggerFeedbackThanks: View {
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 42))
                    .foregroundColor(Color(hex: "C4493A"))
                Text("Thanks for your feedback!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                    .multilineTextAlignment(.center)
                Text("Enjoy reading Bible")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "7A8494"))
                    .multilineTextAlignment(.center)
                Button(action: onClose) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Color(hex: "2456C7")))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 12)
                .padding(.horizontal, 22)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

/// Sends private feedback to support mail; falls back to the in-app Feedback web form.
private enum TriggerFeedbackMail {
    static func send(subject: String, body: String, onDone: @escaping () -> Void) {
        // Dismiss the trigger host first so Mail / default form can present cleanly.
        onDone()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = SendMail.shared
                mail.setToRecipients([FEEDBACKMAIL])
                mail.setSubject(subject)
                mail.setMessageBody(body, isHTML: false)
                top.present(mail, animated: true)
                return
            }
            let encode: (String) -> String = { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
            if let url = URL(string: "mailto:\(FEEDBACKMAIL)?subject=\(encode(subject))&body=\(encode(body))") {
                UIApplication.shared.open(url) { opened in
                    if !opened {
                        SendMail.shared.FeedbackNavigation(presentViewcontroll: top)
                    }
                }
                return
            }
            SendMail.shared.FeedbackNavigation(presentViewcontroll: top)
        }
    }
}

private struct TriggerTopicWrap: View {
    let topics: [String]
    let selected: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(Array(topics.prefix(4)), id: \.self) { topic in
                    topicButton(topic)
                }
            }
            if topics.count > 4 {
                topicButton(topics[4])
            }
        }
    }

    private func topicButton(_ topic: String) -> some View {
        Button(action: { onSelect(topic) }) {
            Text(topic)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "12315C"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(selected == topic ? Color(hex: "E7EEF9") : Color.white)
                )
                .overlay(Capsule().stroke(Color(hex: "D5DEEE"), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct TriggerStreakRating: View {
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F7F3EA").ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "F08A24"))
                    .padding(.top, 48)
                Text("7-day streak")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(Color(hex: "12315C"))
                Text("A full week with the Word")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "7A8494"))
                Spacer()
                Button("Continue", action: onClose)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "66758C"))
                    .padding(.bottom, 28)
            }
        }
    }
}

private struct TriggerPlans: View {
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    @State private var plan = 0

    var body: some View {
        GeometryReader { geo in
            let topInset = max(geo.safeAreaInsets.top, 12)
            let bottomInset = max(geo.safeAreaInsets.bottom, 10)
            // Short iPhones (SE / 8 size) only; taller phones and iPad keep the values below.
            let compact = geo.size.height < 750 && UIDevice.current.userInterfaceIdiom != .pad
            let topBgHeight = geo.size.height * (compact ? 0.55 : 0.42) + topInset
            let contentDown: CGFloat = 28
            // iPad: CTA + fine print sit at the bottom of the screen instead of under the cards.
            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            ZStack(alignment: .top) {
                Color(hex: "0A1A2F")

                // Photo + content share one ScrollView so bg moves with text/cards.
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        Image("main_paywall_bg")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: topBgHeight, alignment: .bottom)
                            .clipped()
                            .overlay(Color(hex: "0A1A2F").opacity(0.16))
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color(hex: "0A1A2F").opacity(0.35),
                                        Color(hex: "0A1A2F")
                                    ],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .frame(maxWidth: .infinity, alignment: .top)

                        VStack(spacing: 0) {
                            // X scrolls with bg + content.
                            HStack(alignment: .center) {
                                Text("PREMIUM")
                                    .font(.system(size: 11, weight: .heavy))
                                    .tracking(1.6)
                                    .foregroundColor(Color(hex: "F7D57C"))
                                Spacer(minLength: 8)
                                Button(action: onClose) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color.white.opacity(0.22)))
                                        .contentShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityLabel("Close")
                            }
                            .padding(.top, compact ? topInset + 16 : topInset + 8 + contentDown + 28)

                            Text("Know the Word Better.")
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                            Text("Read Scripture. Explore its meaning.\nTest what you’ve learned.")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "B9C6DE"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)

                            HStack(spacing: 0) {
                                planIcon("book", "Ad-free\nreading")
                                planIcon("lightbulb", "AI explanations\n& summaries")
                                // Clipboard with a checklist, like the design (iOS 16+). iOS 15 falls back to a checklist.
                                planIcon({ if #available(iOS 16.0, *) { return "list.clipboard" } else { return "checklist" } }(), "Quizzes &\nmemory tools")
                                planIcon("chart.bar", "Track your\nprogress")
                            }
                            .padding(.top, compact ? 150 : max(56, geo.size.height * 0.08) + contentDown + 32)

                            if pricePhase == .ready {
                            planCard(index: 0, title: "1 Year Premium", detail: "Ad-free + unlimited AI study", extra: TriggerPrices.perMonth(model.year), price: model.year, badge: "Best value")
                                .padding(.top, compact ? 40 : max(40, geo.size.height * 0.06))
                                .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
                            planCard(index: 1, title: "1 Month Premium", detail: "Ad-free + unlimited AI study", extra: "", price: model.month, badge: "")
                                .padding(.top, 10)
                            planCard(index: 2, title: "Lifetime Ad-Free", detail: "One payment · no AI", extra: "", price: model.life, badge: "")
                                .padding(.top, 10)
                            if isPad {
                                Spacer(minLength: 0)
                            }
                            Button(action: buy) {
                                Text(cta)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color(hex: "1B2536"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(ctaPrice.isEmpty || model.buying)
                            .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)
                            .padding(.top, 16)
                            Text(plan == 2 ? "Purchase managed by Apple" : "Cancel anytime · Purchase managed by Apple")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "B9C6DE"))
                                .padding(.top, 8)
                            Text(finePrint)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "8FA0BF"))
                                .multilineTextAlignment(.center)
                                .padding(.top, 6)
                            } else {
                                priceStatusCard
                                    .padding(.top, compact ? 40 : max(40, geo.size.height * 0.06))
                                if isPad {
                                    Spacer(minLength: 0)
                                }
                                if pricePhase == .loading || pricePhase == .retrying {
                                    // Disabled until a price arrives.
                                    Text("Loading price...")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color(hex: "1B2536"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "F7D57C").opacity(0.45)))
                                        .padding(.top, 16)
                                }
                            }
                            TriggerLegalRow(onRestore: { model.restore() })
                                .padding(.top, 10)
                                .padding(.bottom, bottomInset + 8)
                        }
                        .padding(.horizontal, 22)
                        .frame(minHeight: isPad ? geo.size.height : nil, alignment: .top)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }

    // MARK: - Price states (loading / no internet / unavailable / retrying)
    private enum PricePhase { case ready, loading, retrying, noInternet, unavailable }
    @State private var isRetryingPrices = false
    @State private var priceWaitExpired = false

    private var pricePhase: PricePhase {
        if !model.month.isEmpty || !model.year.isEmpty || !model.life.isEmpty { return .ready }
        let store = model.store
        let fetching = store.isLoading1 || store.isLoading2 || store.isLoading3
        let online = NetworkManager.sharedInstance.isConnectedToInternet()
        if isRetryingPrices { return fetching ? .retrying : (online ? .unavailable : .noInternet) }
        if fetching { return .loading }
        if !online { return .noInternet }
        if store.hasProductLoadError || priceWaitExpired { return .unavailable }
        return .loading
    }

    private func retryPrices() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return
        }
        isRetryingPrices = true
        model.store.retryAllPrices()
    }

    private var priceStatusCard: some View {
        let phase = pricePhase
        let waiting = phase == .loading || phase == .retrying
        let offline = phase == .noInternet
        return VStack(spacing: 10) {
            if waiting {
                SwiftUI.ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            } else {
                Image(systemName: offline ? "wifi.slash" : "exclamationmark.circle")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(offline ? Color(hex: "9FB0CC") : Color(hex: "FF6B5E"))
            }
            Text(waiting
                 ? (phase == .retrying ? "Retrying..." : "Getting your price...")
                 : (offline ? "No Internet Connection" : "Price unavailable"))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            Text(waiting
                 ? (phase == .retrying ? "Getting your price again..." : "Please wait a moment")
                 : (offline ? "Please check your internet connection and try again." : "We couldn't load the purchase price. This may be a temporary issue. Please try again."))
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "B9C6DE"))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
            if !waiting {
                Button(action: retryPrices) {
                    HStack(spacing: 8) {
                        Text("Try Again")
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "1B2536"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.16), lineWidth: 1))
        )
        .onAppear {
            // Never spin forever if Apple does not answer.
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) { priceWaitExpired = true }
        }
    }

    private var ctaPrice: String {
        plan == 0 ? model.year : (plan == 1 ? model.month : model.life)
    }

    private var cta: String {
        if plan == 0 { return "Get Yearly Access" }
        if plan == 1 { return "Start 3-Day Free Trial" }
        return "Get Lifetime Access"
    }

    private var finePrint: String {
        if plan == 2 {
            return "One-time purchase. Nothing renews. Removes banners and interstitial ads; does not include AI."
        }
        let price = plan == 0 ? model.year : model.month
        let period = plan == 0 ? "year" : "month"
        return "\(price) per \(period), renews every \(period) until cancelled. Cancel anytime in iPhone Settings → Apple ID → Subscriptions."
    }

    private func buy() {
        let productId = plan == 0 ? SUBSCRIPTIONID_OneYear : (plan == 1 ? SUBSCRIPTIONID_Six_month : SUBSCRIPTIONID_LifeTime)
        let trying: PaywallOwnedPlanGuard.Plan = plan == 0 ? .year : (plan == 1 ? .month : .lifetime)
        // Already has a plan: show the "Already Have an Active Plan" alert first (same as iPhone paywall).
        PaywallOwnedPlanGuard.check(
            store: model.store,
            trying: trying,
            onProceed: { model.buy(productId) },
            onRestore: { model.restore() }
        )
    }

    private func planIcon(_ symbol: String, _ title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white.opacity(0.05)))
                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            // Wrap to as many lines as needed so the label is never cut with "...".
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func planCard(index: Int, title: String, detail: String, extra: String, price: String, badge: String) -> some View {
        let selected = plan == index
        return Button(action: { plan = index }) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(extra.isEmpty ? detail : "\(detail)\n\(extra)")
                        .font(.system(size: 12))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                // Price is never cut; the description wraps instead.
                Text(price)
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(1)
                    .fixedSize()
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
            }
            .foregroundColor(selected ? Color(hex: "12315C") : .white)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(selected ? LinearGradient(colors: [Color.white, Color(hex: "F6EDD6")], startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color.white.opacity(0.07), Color.white.opacity(0.07)], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected ? Color(hex: "E8B64C") : Color.white.opacity(0.16), lineWidth: 1))
            )
            .overlay(
                Group {
                    if !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "1B2536"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color(hex: "F7D57C")))
                            .offset(y: -10)
                    }
                },
                alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct TriggerDay30: View {
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void

    private var proof: String {
        let chapters = CoreDataModel.sharedInstance.GetMarkasReadStatus(entity: CDMarkAsRead).count
        guard chapters > 0 else { return "" }
        return "30 days · \(chapters) chapters read"
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "1B3A73"), Color(hex: "0B1A36"), Color(hex: "070E1E")], startPoint: .top, endPoint: .bottom)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.55))
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.white.opacity(0.12)))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 8)
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "F7D57C"))
                        .frame(width: 72, height: 72)
                        .background(Circle().stroke(Color(hex: "F7D57C").opacity(0.45), lineWidth: 1))
                        .padding(.top, 8)
                    Text("30-DAY READING STREAK")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color(hex: "F7D57C"))
                        .padding(.top, 14)
                    Text("30 Days.\nKeep Going Deeper.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    Text("You’ve made the Word part of your routine.\nKeep reading without interruptions.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "B9C6DE"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    if !proof.isEmpty {
                        Text(proof)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "F7D57C"))
                            .padding(.top, 8)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lifetime Ad-Free")
                                .font(.system(size: 18, weight: .bold))
                            Text("One payment · no AI")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "5E7194"))
                        }
                        Spacer()
                        Text(model.life)
                            .font(.system(size: 26, weight: .heavy))
                    }
                    .foregroundColor(Color(hex: "12315C"))
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 18).fill(LinearGradient(colors: [Color.white, Color(hex: "F6EDD6")], startPoint: .top, endPoint: .bottom)))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "E8B64C"), lineWidth: 1))
                    .padding(.top, 22)
                    HStack(spacing: 16) {
                        Label("No ads while reading", systemImage: "speaker.slash.fill")
                        Label("Yours forever", systemImage: "infinity")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "B9C6DE"))
                    .padding(.top, 16)
                    Button(action: { model.buy(SUBSCRIPTIONID_LifeTime) }) {
                        Text("Get Lifetime · \(model.life)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "1B2536"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(model.life.isEmpty || model.buying)
                    .padding(.top, 18)
                    Button("Continue Reading", action: onClose)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "B9C6DE"))
                        .padding(.top, 12)
                    TriggerLegalRow(onRestore: { model.restore() })
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 22)
            }
        }
        .ignoresSafeArea()
    }
}

private struct TriggerExitOffer: View {
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    var onRestore: () -> Void

    private var salePrice: String { model.offer.isEmpty ? model.life : model.offer }
    private var showsOldPrice: Bool { !model.offer.isEmpty && model.life != model.offer && !model.life.isEmpty }
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    // Exit offer price states (slow / no network)
    private enum ExitPhase { case ready, loading, retrying, noInternet, unavailable }
    @State private var exitRetrying = false
    @State private var exitWaitExpired = false
    @State private var exitWaitToken = 0

    private var exitPhase: ExitPhase {
        if !model.offer.isEmpty { return .ready }
        if SUBSCRIPTIONID_ExitOffer.isEmpty && !model.life.isEmpty { return .ready }
        if !NetworkManager.sharedInstance.isConnectedToInternet() { return .noInternet }
        if exitRetrying { return .retrying }
        if exitWaitExpired { return .unavailable }
        return .loading
    }

    /// Stops waiting for the exit-offer price after 10 seconds and shows "Price unavailable".
    private func startExitPriceWait(retry: Bool) {
        exitWaitToken += 1
        let token = exitWaitToken
        exitWaitExpired = false
        exitRetrying = retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            guard token == exitWaitToken else { return }
            exitRetrying = false
            exitWaitExpired = true
        }
    }

    private func retryExitPrice() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return
        }
        startExitPriceWait(retry: true)
        model.store.retryLifetimePrice()
        model.store.retryExitOfferPrice()
    }

    private var exitStatusCard: some View {
        let phase = exitPhase
        let waiting = phase == .loading || phase == .retrying
        let offline = phase == .noInternet
        return VStack(spacing: 10) {
            if waiting {
                SwiftUI.ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C9862A")))
                    .scaleEffect(1.2)
            } else {
                Image(systemName: offline ? "wifi.slash" : "exclamationmark.circle")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(offline ? Color(hex: "5E7194") : Color(hex: "D6453B"))
            }
            Text(waiting
                 ? (phase == .retrying ? "Retrying..." : "Getting your price...")
                 : (offline ? "No Internet Connection" : "Price unavailable"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "12315C"))
            Text(waiting
                 ? (phase == .retrying ? "Getting your price again..." : "Please wait a moment")
                 : (offline ? "Please check your internet connection and try again." : "We couldn't load the purchase price. This may be a temporary issue. Please try again."))
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "5E7194"))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
            if !waiting {
                Button(action: retryExitPrice) {
                    HStack(spacing: 8) {
                        Text("Try Again")
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1B2536"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 18).fill(LinearGradient(colors: [Color.white, Color(hex: "F6EDD6")], startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "E8B64C"), lineWidth: 1.5))
        .onAppear {
            guard model.offer.isEmpty else { return }
            startExitPriceWait(retry: false)
            if NetworkManager.sharedInstance.isConnectedToInternet() {
                model.store.retryExitOfferPrice()
            }
        }
    }

    var body: some View {
        GeometryReader { geo in
            // iPad: keep content high + pin X to top-trailing. Phone layout unchanged.
            let topPad = isPad
                ? max(geo.safeAreaInsets.top, 16)
                : max(geo.safeAreaInsets.top, closeTopInset)
            let bottomPad = max(geo.safeAreaInsets.bottom, closeBottomInset)
            // iPad: the night sky fills the whole screen (no empty dark band under it).
            let bgHeight = max(geo.size.height, 1)
            let cardTop = isPad ? 28 : max(56, geo.size.height * 0.08)
            let contentWidth = isPad ? min(geo.size.width, 560) : geo.size.width

            ZStack(alignment: .top) {
                Color(hex: "070E1E")

                // Head + X + bg + card all scroll together on phone; on iPad X is fixed overlay.
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        Image("exit_offer_night")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: bgHeight, alignment: .top)
                            .clipped()
                            .frame(maxWidth: .infinity, alignment: .top)

                        VStack(spacing: 0) {
                            if isPad {
                                // Room for the fixed top-trailing X only — no extra empty band.
                                Color.clear
                                    .frame(height: topPad + 36)
                            } else {
                                HStack {
                                    Spacer()
                                    exitCloseButton
                                }
                                .padding(.top, topPad)
                                .padding(.trailing, -6)
                            }

                            Text("A ONE-TIME LIFETIME OPTION")
                                .font(.system(size: 11, weight: .heavy))
                                .kerning(1.1)
                                .foregroundColor(Color(hex: "F7D57C"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .overlay(Capsule().stroke(Color(hex: "F7D57C"), lineWidth: 1))
                                .padding(.top, isPad ? 0 : 10)

                            VStack(spacing: 0) {
                                Text("Read ad-free,")
                                    .foregroundColor(.white)
                                Text("for good")
                                    .foregroundColor(Color(hex: "F7D57C"))
                            }
                            .font(.system(size: isPad ? 38 : 34, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center)
                            .padding(.top, isPad ? 10 : 14)

                            Text("Pay once. No renewals. Yours to keep.")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "B9C6DE"))
                                .padding(.top, 10)

                            if exitPhase == .ready {
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Lifetime")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(hex: "12315C"))
                                    Text("Ad-free reading · no AI")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "5E7194"))
                                }
                                Spacer(minLength: 8)
                                VStack(alignment: .trailing, spacing: 1) {
                                    if showsOldPrice {
                                        Text(model.life)
                                            .font(.system(size: 13, weight: .semibold))
                                            .strikethrough()
                                            .foregroundColor(Color(hex: "8AA0C2"))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    Text(salePrice)
                                        .font(.system(size: 32, weight: .heavy))
                                        .foregroundColor(Color(hex: "C9862A"))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                    Text("Special price")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hex: "C9862A"))
                                }
                                .layoutPriority(1)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 18).fill(LinearGradient(colors: [Color.white, Color(hex: "F6EDD6")], startPoint: .top, endPoint: .bottom)))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "E8B64C"), lineWidth: 1.5))
                            // Referral gap under subtitle — card a bit lower (phone). Tighter on iPad.
                            .padding(.top, cardTop)
                            } else {
                                exitStatusCard
                                    .padding(.top, cardTop)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                exitLine("One payment, no renewals")
                                exitLine("No banners or interstitial ads")
                                exitLine("Restore anytime with your Apple ID")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 14)
                            .padding(.leading, 8)

                            Button(action: {
                                guard NetworkManager.sharedInstance.isConnectedToInternet() else {
                                    OnboardingAuthManager.topViewController()?.view.makeToast("No internet connection", duration: 2.0, position: .top)
                                    return
                                }
                                model.buy(SUBSCRIPTIONID_ExitOffer.isEmpty ? SUBSCRIPTIONID_LifeTime : SUBSCRIPTIONID_ExitOffer)
                            }) {
                                Text(exitPhase == .loading || exitPhase == .retrying ? "Loading price..." : "Get Lifetime Access")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color(hex: "1B2536"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                                    .opacity(exitPhase == .ready ? 1 : 0.55)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(model.buying || salePrice.isEmpty || exitPhase != .ready)
                            .shadow(color: Color(hex: "F7D57C").opacity(0.35), radius: 14, y: 6)
                            .padding(.top, 16)

                            Text("One-time purchase. Nothing renews. Ad-free only; does not include AI.")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "8FA0BF"))
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)

                            HStack(spacing: 6) {
                                Button("Restore Purchases", action: onRestore)
                                Text("·")
                                Button("Terms") { legal(TermsURL) }
                                Text("·")
                                Button("Privacy") { legal(PrivacyURL) }
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "B9C6DE"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 12)
                            .padding(.bottom, bottomPad + 8)
                        }
                        .padding(.horizontal, isPad ? 32 : 24)
                        .frame(width: contentWidth, alignment: .top)
                        .frame(maxWidth: .infinity, alignment: .top)
                        // iPad only: centre the offer on the full-screen background. Phone keeps minHeight 0.
                        .frame(minHeight: isPad ? geo.size.height : 0, alignment: .center)
                    }
                }

                if isPad {
                    HStack {
                        Spacer()
                        exitCloseButton
                    }
                    .padding(.top, topPad)
                    .padding(.trailing, 20)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }

    private var exitCloseButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.22))
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Close")
    }

    private var closeTopInset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let inset = window?.safeAreaInsets.top ?? 0
        if inset > 0 { return inset }
        return UIDevice.current.userInterfaceIdiom == .pad ? 24 : 54
    }

    private var closeBottomInset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let inset = window?.safeAreaInsets.bottom ?? 0
        return inset > 0 ? inset : 16
    }

    private func exitLine(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "F7D57C"))
            Text(text)
                .foregroundColor(Color(hex: "DCE7F8"))
        }
        .font(.system(size: 14, weight: .semibold))
    }

    private func legal(_ urlString: String) {
        guard let url = URL(string: urlString),
              let host = OnboardingAuthManager.topViewController() else { return }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .close
        host.present(safari, animated: true)
    }
}

// MARK: - Already-have-a-plan check before a purchase
/// Same "You Already Have an Active Plan" alert as the BibleSubscriptionView paywall.
/// Used by the 3-plan paywall and the Pro paywall so iPhone and iPad behave the same.
enum PaywallOwnedPlanGuard {
    enum Plan { case month, year, lifetime }

    private static var isChecking = false
    private static weak var hud: UIView?

    /// Calls `onProceed` when the user may buy. Shows the alert instead when a plan is already active.
    static func check(store: StoreManager, trying: Plan, onProceed: @escaping () -> Void, onRestore: @escaping () -> Void) {
        guard !isChecking else { return }
        if let saved = savedLastPlan() {
            if let expiry = saved.expiry, saved.kind != .lifetime, expiry.timeIntervalSinceNow < 0 {
                onProceed()
                return
            }
            present(owned: saved.kind, expiry: saved.expiry, trying: trying, onProceed: onProceed, onRestore: onRestore)
            return
        }
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            onProceed()
            return
        }
        isChecking = true
        showHUD()
        store.lookupLastStorePlans { plans, cancelled in
            isChecking = false
            hideHUD()
            if cancelled { return }
            if let found = lastStorePlan(from: plans) {
                let expiry = found.kind == .lifetime ? nil : storePlanExpiry(kind: found.kind, purchasedAt: found.purchasedAt)
                if let expiry = expiry, expiry.timeIntervalSinceNow < 0 {
                    onProceed()
                    return
                }
                present(owned: found.kind, expiry: expiry, trying: trying, onProceed: onProceed, onRestore: onRestore)
                return
            }
            onProceed()
        }
    }

    // MARK: Saved / store plan

    private static func savedLastPlan() -> (kind: Plan, expiry: Date?)? {
        let paymentId = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
        var kind = planKind(from: paymentId)
        if kind == nil && UserDefaults.standard.bool(forKey: "HasLifetimePurchase") {
            kind = .lifetime
        }
        let expiry = savedPlanExpiry()
        if kind == nil && expiry != nil {
            kind = .month
        }
        guard let kind = kind else { return nil }
        return (kind, kind == .lifetime ? nil : expiry)
    }

    private static func lastStorePlan(from plans: [(id: String, purchasedAt: Date?)]) -> (kind: Plan, purchasedAt: Date?)? {
        var newestKind: Plan?
        var newestDate: Date?
        var undated: [Plan] = []
        for plan in plans {
            guard let kind = planKind(from: plan.id) else { continue }
            if let date = plan.purchasedAt {
                if newestDate == nil || date > newestDate! {
                    newestDate = date
                    newestKind = kind
                }
            } else {
                undated.append(kind)
            }
        }
        if let newestKind = newestKind { return (newestKind, newestDate) }
        if undated.contains(.year) { return (.year, nil) }
        if undated.contains(.month) { return (.month, nil) }
        if undated.contains(.lifetime) { return (.lifetime, nil) }
        return nil
    }

    private static func storePlanExpiry(kind: Plan, purchasedAt: Date?) -> Date? {
        guard let purchasedAt = purchasedAt else { return nil }
        let days: Int
        switch kind {
        case .year: days = 365
        case .month: days = 30
        case .lifetime: return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(byAdding: .day, value: days, to: purchasedAt)
    }

    private static func savedPlanExpiry() -> Date? {
        let stamp = UserDefaults.standard.double(forKey: "SubscriptionExpiryGMT")
        if stamp > 0 {
            return Date(timeIntervalSince1970: stamp)
        }
        let stored = CoreDataModel.sharedInstance.GetEndDate(entity: CDPaymentdateAPI)
        guard !stored.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.date(from: stored)
    }

    private static func planKind(from productId: String) -> Plan? {
        let id = productId.lowercased()
        guard !id.isEmpty else { return nil }
        if id.contains("lifetime")
            || productId == SUBSCRIPTIONID_LifeTime
            || productId == SUBSCRIPTIONID_ExitOffer
            || productId == FallbackIAPConstants.lifetimeProductID
            || productId == FallbackIAPConstants.exitOfferProductID {
            return .lifetime
        }
        if id.contains("oneyear") || id.contains("1year")
            || productId == SUBSCRIPTIONID_OneYear
            || productId == FallbackIAPConstants.oneYearProductID {
            return .year
        }
        if id.contains("onemonth") || id.contains("sixmonth") || id.contains("month")
            || productId == SUBSCRIPTIONID_Six_month
            || productId == FallbackIAPConstants.oneMonthProductID {
            return .month
        }
        return nil
    }

    // MARK: Alert

    private static func planName(_ kind: Plan) -> String {
        switch kind {
        case .month: return "1 Month"
        case .year: return "1 Year"
        case .lifetime: return "Lifetime"
        }
    }

    private static func present(owned: Plan, expiry: Date?, trying: Plan, onProceed: @escaping () -> Void, onRestore: @escaping () -> Void) {
        let tryingLifetime = trying == .lifetime
        let tryingYear = trying == .year
        let ownedLifetime = owned == .lifetime
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "MMM d, yyyy"
        let expiryLabel = expiry.map { formatter.string(from: $0) }

        let title = ownedLifetime ? "You Already Own\nLifetime" : "You Already Have\nan Active Plan"
        var message: String
        if ownedLifetime {
            message = tryingLifetime
                ? "You already have Lifetime access."
                : "You have Lifetime access. The \(tryingYear ? "1 Year" : "1 Month") plan will renew automatically \(tryingYear ? "each year" : "each month")."
        } else if let expiryLabel = expiryLabel {
            message = "Your last \(planName(owned)) plan is currently active until \(expiryLabel). Purchasing another plan will create an additional charge.\n\nExpires on \(expiryLabel)"
        } else {
            message = "Your last plan is \(planName(owned)). Purchasing another plan will create an additional charge."
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(UIAlertAction(title: "Restore My Current Plan", style: .default) { _ in onRestore() })
        if ownedLifetime && !tryingLifetime {
            let addLabel = tryingYear ? "Add 1 Year Plan" : "Add 1 Month Plan"
            alert.addAction(UIAlertAction(title: addLabel, style: .default) { _ in onProceed() })
        }
        DispatchQueue.main.async {
            OnboardingAuthManager.topViewController()?.present(alert, animated: true)
        }
    }

    // MARK: Loader

    private static func showHUD() {
        DispatchQueue.main.async {
            guard hud == nil, let container = OnboardingAuthManager.topViewController()?.view.window else { return }
            let dim = UIView(frame: container.bounds)
            dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dim.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.center = CGPoint(x: dim.bounds.midX, y: dim.bounds.midY)
            spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            spinner.startAnimating()
            dim.addSubview(spinner)
            container.addSubview(dim)
            hud = dim
        }
    }

    private static func hideHUD() {
        DispatchQueue.main.async {
            hud?.removeFromSuperview()
            hud = nil
        }
    }
}
