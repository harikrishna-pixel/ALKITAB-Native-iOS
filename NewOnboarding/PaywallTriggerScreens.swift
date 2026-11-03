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
    case streakRating

    var isFullPage: Bool {
        switch self {
        case .book, .streak, .day30, .plans, .feedback, .feedbackForm, .streakRating:
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

    static func show(trigger: String, from top: UIViewController, onClose: @escaping () -> Void) -> Bool {
        guard let screen = PaywallTriggerScreen.from(trigger: trigger), pricesReady(screen) else { return false }
        present(screen, from: top, onboarding: false, onClose: onClose)
        return true
    }

    static func showFeedback(book: String, chapters: Int, from top: UIViewController) {
        present(.feedback(book, chapters), from: top, onboarding: false, onClose: {})
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
        case .adCard, .feedback, .feedbackForm, .streakRating:
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

    private static func present(_ screen: PaywallTriggerScreen, from top: UIViewController, onboarding: Bool, onClose: @escaping () -> Void) {
        let box = TriggerHostBox()
        let root = PaywallTriggerRoot(screen: screen, onboarding: onboarding, onClose: onClose, dismissHost: {
            PaywallTriggerPresenter.dismiss(box.host)
        })
        let host = UIHostingController(rootView: root)
        box.host = host
        host.view.backgroundColor = screen.isFullPage ? UIColor(red: 0.97, green: 0.95, blue: 0.92, alpha: 1) : .clear
        if case .day30 = screen {
            host.view.backgroundColor = UIColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1)
        }
        if case .plans = screen {
            host.view.backgroundColor = UIColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1)
        }
        host.modalPresentationStyle = screen.isFullPage ? .fullScreen : .overFullScreen
        top.present(host, animated: true)
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
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let full = trimmed.cleanPrice()
        guard !full.isEmpty else { return "" }
        if full.hasSuffix(".00") { return String(full.dropLast(3)) }
        return full
    }

    static func amount(_ text: String) -> Double? {
        let digits = text.filter { $0.isNumber || $0 == "." }
        return Double(digits)
    }

    static func perMonth(_ yearly: String) -> String {
        guard let value = amount(yearly), value > 0 else { return "" }
        let month = Int((value / 12.0).rounded())
        let symbol = yearly.prefix { !$0.isNumber && $0 != "." && $0 != "," }
        return "\(symbol)\(month) / month"
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
                    : "Pay once. No ads on any screen, forever.",
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
                cardDetail: "Pay once. No ads on any screen, forever.",
                nextLine: nextBookLine(name),
                onGo: { model.buy(SUBSCRIPTIONID_LifeTime) },
                onNotNow: closeModal
            )
        case .streak(let day):
            if day == 3 {
                TriggerDay3Card(
                    onGo: { model.buy(SUBSCRIPTIONID_LifeTime) },
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
            TriggerFeedbackCard(book: book, chapters: chapters, onGreat: closeModal, onBetter: { followUp = .feedbackForm })
        case .feedbackForm:
            TriggerFeedbackForm(onClose: closeModal)
        case .streakRating:
            TriggerStreakRating(onClose: closeModal)
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
        if onboarding && !model.offer.isEmpty && !model.life.isEmpty {
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
            Text(subtitle.isEmpty ? "Pay once. No ads on any screen, forever." : subtitle)
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

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
            VStack(spacing: 0) {
                Button(action: onClose) {
                    Capsule()
                        .fill(Color(hex: "E1E6EF"))
                        .frame(width: 42, height: 5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)
                ScrollView(showsIndicators: false) {
                    content()
                        .padding(.top, 4)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                }
            }
            .background(Color.white)
            .cornerRadius(28)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.78)
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

/// HTML image 07. Soft card only: Go Ad-Free buys Lifetime here. No follow-up sheet.
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
        UserDefaults.standard.set(topic, forKey: "PaywallTriggerFeedbackTopic")
        UserDefaults.standard.set(message, forKey: "PaywallTriggerFeedbackNote")
        OnboardingAuthManager.topViewController()?.view.makeToast("Thanks, we received your note.", duration: 2.0, position: .center)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onClose()
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
        ZStack {
            LinearGradient(colors: [Color(hex: "1B3A73"), Color(hex: "0B1A36"), Color(hex: "070E1E")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("VERSEDEEP")
                                .font(.system(size: 11, weight: .heavy))
                            Text("PREMIUM")
                                .font(.system(size: 11, weight: .heavy))
                        }
                        .foregroundColor(Color(hex: "F7D57C"))
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
                    .padding(.top, 12)
                    Text("Know the Word Better.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    Text("Read Scripture. Explore its meaning.\nTest what you’ve learned.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "B9C6DE"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    HStack(spacing: 0) {
                        planIcon("book.fill", "Ad-free\nreading")
                        planIcon("lightbulb.fill", "AI explanations\n& summaries")
                        planIcon("list.bullet.rectangle", "Quizzes &\nmemory tools")
                        planIcon("chart.bar.fill", "Track your\nprogress")
                    }
                    .padding(.top, 18)
                    planCard(index: 0, title: "1 Year Premium", detail: "Ad-free + unlimited AI study", extra: TriggerPrices.perMonth(model.year), price: model.year, badge: "Best value")
                        .padding(.top, 18)
                    planCard(index: 1, title: "1 Month Premium", detail: "Ad-free + unlimited AI study", extra: "", price: model.month, badge: "")
                        .padding(.top, 10)
                    planCard(index: 2, title: "Lifetime Ad-Free", detail: "One payment · no AI", extra: "", price: model.life, badge: "")
                        .padding(.top, 10)
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
                    TriggerLegalRow(onRestore: { model.restore() })
                        .padding(.top, 10)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private var ctaPrice: String {
        plan == 0 ? model.year : (plan == 1 ? model.month : model.life)
    }

    private var cta: String {
        if plan == 0 { return "Get 1 Year · \(model.year)" }
        if plan == 1 { return "Get 1 Month · \(model.month)" }
        return "Get Lifetime · \(model.life)"
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
        if plan == 0 { model.buy(SUBSCRIPTIONID_OneYear) }
        else if plan == 1 { model.buy(SUBSCRIPTIONID_Six_month) }
        else { model.buy(SUBSCRIPTIONID_LifeTime) }
    }

    private func planIcon(_ symbol: String, _ title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "F7D57C"))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.08)))
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "B9C6DE"))
                .multilineTextAlignment(.center)
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
                    Text(extra.isEmpty ? detail : "\(detail)\n\(extra)")
                        .font(.system(size: 12))
                }
                Spacer()
                Text(price)
                    .font(.system(size: 20, weight: .heavy))
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
                .ignoresSafeArea()
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
    }
}

private struct TriggerExitOffer: View {
    @ObservedObject var model: PaywallTriggerModel
    var onClose: () -> Void
    var onRestore: () -> Void

    private var salePrice: String { model.offer.isEmpty ? model.life : model.offer }
    private var showsOldPrice: Bool { !model.offer.isEmpty && model.life != model.offer && !model.life.isEmpty }

    var body: some View {
        ZStack {
            Color(hex: "070E1E").ignoresSafeArea()
            Image("exit_offer_night")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
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
                    .padding(.top, closeTopInset + 28)
                    .padding(.trailing, -6)
                    Color.clear.frame(height: max(4, geo.size.height * 0.025 - 20))
                    Text("A ONE-TIME LIFETIME OPTION")
                        .font(.system(size: 11, weight: .heavy))
                        .kerning(1.1)
                        .foregroundColor(Color(hex: "F7D57C"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(Capsule().stroke(Color(hex: "F7D57C"), lineWidth: 1))
                        .padding(.top, -18)
                    VStack(spacing: 0) {
                        Text("Read ad-free,")
                            .foregroundColor(.white)
                        Text("for good")
                            .foregroundColor(Color(hex: "F7D57C"))
                    }
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    Text("Pay once. No renewals. Yours to keep.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "B9C6DE"))
                        .padding(.top, 10)
                    Spacer(minLength: 16)
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
                            }
                            Text(salePrice)
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(Color(hex: "C9862A"))
                            Text("Special price")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "C9862A"))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 18).fill(LinearGradient(colors: [Color.white, Color(hex: "F6EDD6")], startPoint: .top, endPoint: .bottom)))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "E8B64C"), lineWidth: 1.5))
                    VStack(alignment: .leading, spacing: 12) {
                        exitLine("One payment, no renewals")
                        exitLine("No banners or interstitial ads")
                        exitLine("Restore anytime with your Apple ID")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 18)
                    .padding(.leading, 8)
                    Button(action: { model.buy(SUBSCRIPTIONID_ExitOffer.isEmpty ? SUBSCRIPTIONID_LifeTime : SUBSCRIPTIONID_ExitOffer) }) {
                        Text("Get Lifetime · \(salePrice)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "1B2536"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [Color(hex: "F7D57C"), Color(hex: "D9A23A")], startPoint: .leading, endPoint: .trailing)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(model.buying || salePrice.isEmpty)
                    .shadow(color: Color(hex: "F7D57C").opacity(0.35), radius: 14, y: 6)
                    .padding(.top, 20)
                    Text("One-time purchase. Nothing renews. Ad-free only; does not include AI.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8FA0BF"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                    HStack(spacing: 6) {
                        Button("No thanks", action: onClose)
                        Text("·")
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
                    .padding(.top, 14)
                    .padding(.bottom, closeBottomInset + 8)
                }
                .padding(.horizontal, 24)
                .frame(width: geo.size.width)
                .frame(minHeight: geo.size.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .clipped()
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
