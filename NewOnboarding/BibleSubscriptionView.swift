//
//  BibleSubscriptionView.swift
//  NKJV Bible
//
//  Created by Marberx Technologies on 12/11/25.
import SwiftUI
import StoreKit
import Toast_Swift

@available(iOS 15.0, *)
struct BibleSubscriptionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager = StoreManager()
    @StateObject private var planSelection = PaywallPlanSelection()
    @State private var showLoader = false
    @State private var isRestoring = false
    @State private var isCheckingOwnedPlan = false
    @State private var shouldNavigateToReader = false
    @State private var showCloseButton = true
    @State private var showExitOffer = false
    @State private var exitOfferTimeRemaining = 600 // 10 minutes in seconds
    @State private var exitOfferTimerTask: Task<Void, Never>?
    @State private var didSkipMissingPrices = false
    @State private var priceSheetWatcher = PriceSheetWatcher()
    // FIXED: Parameters for navigation behavior
    var isPresentedFromOnboarding: Bool = true
    var dismissHandler: (() -> Void)?  // ADDED: For UIKit dismiss
    var onDismissToReader: (() -> Void)?
    
    private let screenHeight = UIScreen.main.bounds.height
    private var isSmallDevice: Bool {
        screenHeight < 700
    }
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    /// Stable status-bar inset (GeometryReader can report 0 after ignoresSafeArea).
    private var topSafeInset: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let inset = window?.safeAreaInsets.top ?? 0
        if inset > 0 { return inset }
        return isPad ? 24 : 54
    }
    
    // MARK: - UserDefaults Keys for Exit Offer
    private let exitOfferStartTimeKey = "ExitOfferStartTime"
    private let exitOfferTimeRemainingKey = "ExitOfferTimeRemaining"
    private let exitOfferExpiredKey = "ExitOfferExpired"
    private let exitOfferFirstInstallShownKey = "ExitOfferFirstInstallShown"
    private let exitOfferTimerDuration = 600 // 10 minutes in seconds
    
    var body: some View {
        paywallRoot
        .navigationBarHidden(true)
        
        .onAppear {
              // Keep a short delay so X doesn't flash before layout settles.
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                  withAnimation(.easeInOut(duration: 0.15)) {
                      showCloseButton = true
                  }
              }
              
              setupStoreManager()
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                  skipPaywallIfMissingPrices()
              }
              // Offline, StoreKit can stay "loading" forever — skip if prices still haven't arrived.
              DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                  skipPaywallIfMissingPrices(ignoreLoading: true)
              }
              
              // Start timer in background if conditions are met, but don't show exit offer automatically
              // Exit offer will only show when user taps X icon
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                  startTimerInBackground()
              }
          }

        .alert(storeManager.alertTitle, isPresented: $storeManager.showAlert) {
            Button("OK", role: .cancel) {
                // Dismiss loader when alert is dismissed (especially for offline case)
                showLoader = false
                storeManager.isLoading = false
                
                if storeManager.alertTitle == "Restore Successful" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shouldNavigateToReader = true
                    }
                }
            }
        } message: {
            Text(storeManager.alertMessage)
        }
        .onChange(of: shouldNavigateToReader) { newValue in
            if newValue {
                navigateToReaderViewController()
            }
        }
        .onChange(of: storeManager.restoreEvent) { _ in
            isRestoring = false
            showLoader = false
            PaywallProcessHUD.hide()
            guard storeManager.restoreSucceeded else { return }
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
            showExitOffer = false
            clearExitOfferData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                closePaywallAfterRestore()
            }
        }
        .onChange(of: storeManager.showAlert) { showing in
            if showing {
                showLoader = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Backup: Apple purchase sheet is on screen — hide the paywall loader.
            // Restore keeps its loader until the receipt check finishes.
            if showLoader && !isRestoring {
                clearPurchaseLoading()
            }
        }
        .onChange(of: storeManager.isLoading2) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.isLoading3) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.isLoading) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.hasProductLoadError) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.price2) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.price3) { _ in skipPaywallIfMissingPrices() }
        .onDisappear {
            priceSheetWatcher.stop()
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
            PaywallProcessHUD.hide()
        }
    }
    
    private var paywallRoot: some View {
        ZStack {
            Color(hex: "021B40").ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            
            GeometryReader { geo in
                ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    PaywallScrollStackView(
                        planSelection: planSelection,
                        storeManager: storeManager,
                        monthlyPriceDisplay: monthlyPriceDisplay,
                        yearlyPriceDisplay: yearlyPriceDisplay,
                        lifetimePriceDisplay: lifetimePriceDisplay,
                        yearlySaveLine: yearlySaveLine,
                        yearlyPerMonthLine: yearlyPerMonthLine,
                        isPad: isPad,
                        isSmallDevice: isSmallDevice,
                        topSafeInset: topSafeInset,
                        geoSize: geo.size,
                        bottomInset: geo.safeAreaInsets.bottom,
                        isRestoring: isRestoring,
                        onPurchase: { handlePurchaseAction() },
                        onContinueFree: { handleCloseAction() },
                        onRestore: {
                            beginRestore()
                        }
                    )
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .top)
                }
            }
            .ignoresSafeArea(edges: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showLoader {
                paywallLoaderOverlay
            }
            
            if showExitOffer && !storeManager.exitOfferPrice.isEmpty && !storeManager.exitOfferOriginalPrice.isEmpty {
            }
        }
        .overlay(alignment: .topTrailing) {
            paywallCloseButton
        }
    }
    
    private var paywallLoaderOverlay: some View {
        ZStack {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(60)
    }
    
    private var paywallCloseButton: some View {
        Button(action: handlePaywallCloseTap) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.22))
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .fixedSize()
        .accessibilityLabel("Close")
        .opacity(showCloseButton ? 1 : 0)
        .disabled(!showCloseButton)
        .padding(.trailing, isPad ? 28 : 18)
        .padding(.top, topSafeInset + 8)
        .ignoresSafeArea()
    }
    
    // MARK: - Paywall display helpers (UI only)
    private var monthlyPriceDisplay: String {
        let p = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
        return p.isEmpty ? "—" : "\(p) / month"
    }
    
    private var yearlyPriceDisplay: String {
        let p = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        return p.isEmpty ? "—" : "\(p) / year"
    }
    
    private var lifetimePriceDisplay: String {
        let p = storeManager.price3.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag3") ?? "") : storeManager.price3
        return p.isEmpty ? "—" : p
    }
    
    private var yearlyPerMonthLine: String {
        // Do not show yearly price / 12. That extra figure was the wrong price on iPad.
        return ""
    }
    
    private var yearlySaveLine: String {
        let monthly = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
        let yearly = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        let m = Double(monthly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        let y = Double(yearly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        guard m > 0, y > 0, (m * 12) > y else { return "" }
        let save = (m * 12) - y
        let symbol = yearly.prefix { !$0.isNumber && $0 != "." && $0 != "," }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let number = formatter.string(from: NSNumber(value: save)) ?? String(format: "%.2f", save)
        return "Save \(symbol)\(number)"
    }
    
    // MARK: - Setup StoreManager
    private func setupStoreManager() {
        storeManager.setupProducts()
        
        storeManager.onPurchaseSuccess = { [self] in
            clearPurchaseLoading()
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
            showExitOffer = false
            clearExitOfferData()
            // Toast is shown by StoreManager on every successful purchase.
            PaywallProcessHUD.didClosePaywall = false
            // iPad needs longer for the App Store sheet to leave before the paywall closes.
            let delay: TimeInterval = UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.closePaywallAfterRestore()
            }
        }
        
        storeManager.onPurchaseFailure = { [self] error in
            clearPurchaseLoading()
        }
        
        storeManager.onRestoreSuccess = { [self] in
            isRestoring = false
            showLoader = false
            PaywallProcessHUD.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.closePaywallAfterRestore()
            }
        }
        
        storeManager.onRestoreFailed = { [self] in
            isRestoring = false
            showLoader = false
            PaywallProcessHUD.hide()
        }
    }

    /// Onboarding only: if Yearly + Lifetime prices never arrive, skip blank paywall.
    private func skipPaywallIfMissingPrices(ignoreLoading: Bool = false) {
        guard isPresentedFromOnboarding, !didSkipMissingPrices else { return }

        let yearly = storeManager.price2.isEmpty
            ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "")
            : storeManager.price2
        let lifetime = storeManager.price3.isEmpty
            ? (UserDefaults.standard.string(forKey: "PriceTag3") ?? "")
            : storeManager.price3
        guard yearly.isEmpty && lifetime.isEmpty else { return }

        if !ignoreLoading {
            let stillLoading = storeManager.isLoading || storeManager.isLoading2 || storeManager.isLoading3
            guard !stillLoading else { return }
        }

        let offline = !NetworkManager.sharedInstance.isConnectedToInternet()
        guard offline || storeManager.hasProductLoadError else { return }

        didSkipMissingPrices = true
        print("⏭️ [BibleSubscriptionView] Skipping onboarding paywall — no Yearly/Lifetime prices available")
        handleCloseAction()
    }
    
    // MARK: - Handle Purchase Action
    private func handlePurchaseAction() {
        if let message = getConnection.shared.networkBlockMessage() {
            OnboardingAuthManager.topViewController()?.view.makeToast(message, duration: 2.0, position: .top)
            return
        }
        if let owned = savedLastPlan() {
            showOwnedPlanAfterLoading(owned: owned.kind, expiry: owned.expiry)
            return
        }
        guard !storeManager.isLoading else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please wait.", duration: 2.0, position: .top)
            return
        }
        guard !isCheckingOwnedPlan else { return }
        isCheckingOwnedPlan = true
        PaywallProcessHUD.show()
        storeManager.lookupLastStorePlans { [self] plans, cancelled in
            isCheckingOwnedPlan = false
            PaywallProcessHUD.hide()
            if cancelled {
                return
            }
            if let found = lastStorePlan(from: plans) {
                presentAlreadyOwnedPlan(
                    owned: found.kind,
                    expiry: found.kind == .lifetime ? nil : storePlanExpiry(kind: found.kind, purchasedAt: found.purchasedAt),
                    trying: planSelection.plan
                )
                return
            }
            beginSelectedPurchase()
        }
    }

    /// Loading stays up until the plan check finishes, then the already-purchased alert is shown.
    private func showOwnedPlanAfterLoading(owned: PaywallOwnedKind, expiry: Date?) {
        guard !isCheckingOwnedPlan else { return }
        isCheckingOwnedPlan = true
        PaywallProcessHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard self.isCheckingOwnedPlan else { return }
            self.isCheckingOwnedPlan = false
            PaywallProcessHUD.hide()
            self.presentAlreadyOwnedPlan(owned: owned, expiry: expiry, trying: self.planSelection.plan)
        }
    }

    /// Restore runs only from the Restore button. The buy button never starts it.
    private func beginRestore() {
        isCheckingOwnedPlan = false
        showLoader = false
        isRestoring = true
        PaywallProcessHUD.didClosePaywall = false
        PaywallProcessHUD.show()
        // Also checks the legacy paid-download status, same as the onboarding paywall.
        storeManager.restorePurchases(includeLegacyPaidDownload: true)
    }

    private func beginSelectedPurchase() {
        showLoader = true
        // Same as onboarding: clear loader as soon as Apple's purchase sheet appears.
        let before = PriceSheetWatcher.currentChrome()
        if planSelection.plan == .monthly {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_Six_month)
        } else if planSelection.plan == .yearly {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_OneYear)
        } else if planSelection.plan == .lifetime {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_LifeTime)
        }
        priceSheetWatcher.start(before: before) { [self] in
            clearPurchaseLoading()
        }
    }

    /// Hides purchase loader when the StoreKit sheet is up — does not affect Restore.
    private func clearPurchaseLoading() {
        guard !isRestoring else { return }
        priceSheetWatcher.stop()
        showLoader = false
        storeManager.isLoading = false
    }

    /// Last plan saved on this phone. Lifetime, 1 Year, then 1 Month.
    private func savedLastPlan() -> (kind: PaywallOwnedKind, expiry: Date?)? {
        let paymentId = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
        var kind = paywallKind(from: paymentId)
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

    /// Newest App Store plan. A dated plan wins. Otherwise 1 Year, then 1 Month, then Lifetime.
    private func lastStorePlan(from plans: [(id: String, purchasedAt: Date?)]) -> (kind: PaywallOwnedKind, purchasedAt: Date?)? {
        var newestKind: PaywallOwnedKind?
        var newestDate: Date?
        var undated: [PaywallOwnedKind] = []
        for plan in plans {
            guard let kind = paywallKind(from: plan.id) else { continue }
            if let date = plan.purchasedAt {
                if newestDate == nil || date > newestDate! {
                    newestDate = date
                    newestKind = kind
                }
            } else {
                undated.append(kind)
            }
        }
        if let newestKind = newestKind {
            return (newestKind, newestDate)
        }
        if undated.contains(.year) { return (.year, nil) }
        if undated.contains(.month) { return (.month, nil) }
        if undated.contains(.lifetime) { return (.lifetime, nil) }
        return nil
    }

    private func storePlanExpiry(kind: PaywallOwnedKind, purchasedAt: Date?) -> Date? {
        guard let purchasedAt = purchasedAt else { return nil }
        let days: Int
        switch kind {
        case .year:
            days = 365
        case .month:
            days = 30
        case .lifetime:
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(byAdding: .day, value: days, to: purchasedAt)
    }

    private func savedPlanExpiry() -> Date? {
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

    private func paywallKind(from productId: String) -> PaywallOwnedKind? {
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

    private func presentAlreadyOwnedPlan(owned: PaywallOwnedKind, expiry: Date?, trying: SubscriptionPlan) {
        let tryingLifetime = trying == .lifetime
        let tryingYear = trying == .yearly
        let ownedLifetime = owned == .lifetime
        let lastPlanLabel = planName(owned)
        let expired = expiry.map { $0.timeIntervalSinceNow < 0 } ?? false
        let expiryLabel = expiry.map(paywallExpiryText)

        let title = ownedLifetime
            ? "You Already Own\nLifetime"
            : "You Already Have\nan Active Plan"

        let body: String
        if ownedLifetime {
            if tryingLifetime {
                body = "You already have Lifetime access."
            } else {
                body = "You have Lifetime access. The \(tryingYear ? "1 Year" : "1 Month") plan will renew automatically \(tryingYear ? "each year" : "each month")."
            }
        } else if expired, let expiryLabel = expiryLabel {
            body = "Your last plan was \(lastPlanLabel). It expired on \(expiryLabel). Purchasing another plan will create an additional charge."
        } else if let expiryLabel = expiryLabel {
            body = "Your last \(lastPlanLabel) plan is currently active until \(expiryLabel). Purchasing another plan will create an additional charge."
        } else {
            body = "Your last plan is \(lastPlanLabel). Purchasing another plan will create an additional charge."
        }

        var message = body
        if !ownedLifetime, let expiryLabel = expiryLabel {
            message += "\n\n" + (expired ? "Expired on \(expiryLabel)" : "Expires on \(expiryLabel)")
        }

        let hideAdd = !ownedLifetime || tryingLifetime
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        alert.addAction(UIAlertAction(title: "Restore My Current Plan", style: .default) { [self] _ in
            beginRestore()
        })
        if !hideAdd {
            let addLabel = tryingYear ? "Add 1 Year Plan" : "Add 1 Month Plan"
            alert.addAction(UIAlertAction(title: addLabel, style: .default) { [self] _ in
                beginSelectedPurchase()
            })
        }
        presentOwnedPlanAlert(alert, attempt: 0)
    }

    /// Shows the alert after loading. Waits until the App Store sheet has left the screen.
    private func presentOwnedPlanAlert(_ alert: UIAlertController, attempt: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            PaywallProcessHUD.hide()
            let host = self.visiblePaywallController() ?? OnboardingAuthManager.topViewController()
            guard let host = host else { return }
            if host.presentedViewController != nil && attempt < 40 {
                self.presentOwnedPlanAlert(alert, attempt: attempt + 1)
                return
            }
            if host.presentedViewController == nil {
                host.present(alert, animated: true)
                return
            }
            OnboardingAuthManager.topViewController()?.present(alert, animated: true)
        }
    }

    private func planName(_ kind: PaywallOwnedKind) -> String {
        switch kind {
        case .month:
            return "1 Month"
        case .year:
            return "1 Year"
        case .lifetime:
            return "Lifetime"
        }
    }

    private func paywallExpiryText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Handle Close Action
    private func handlePaywallCloseTap() {
        if storeManager.exitOfferPrice.isEmpty && StoreManager.shared.isExitOfferProductLoaded {
            storeManager.exitOfferPrice = StoreManager.shared.exitOfferPrice
            storeManager.exitOfferOriginalPrice = StoreManager.shared.exitOfferOriginalPrice
            storeManager.isExitOfferProductLoaded = true
            print("🔄 [BibleSubscriptionView] Synced exit offer price from shared instance")
        }
        
        if shouldShowExitOffer() {
            if UserDefaults.standard.object(forKey: exitOfferStartTimeKey) == nil {
                saveExitOfferStartTime()
            }
            exitOfferTimeRemaining = getRemainingTime()
            
            if exitOfferTimeRemaining > 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showExitOffer = true
                }
                handleCloseAction()
            } else {
                clearExitOfferData()
                handleCloseAction()
            }
        } else {
            print("🔒 [BibleSubscriptionView] Exit offer not available, closing IAP")
            handleCloseAction()
        }
    }
    
    private func handleCloseAction() {
        // Set UserDefaults flag to prevent IAP from showing again
        UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
        
        // Navigate to Reader (same as purchase/restore)
        navigateToReaderViewController()
    }
    
    // MARK: - Start Timer in Background (without showing exit offer)
    private func startTimerInBackground() {
        // Only start timer if conditions are met, but don't show exit offer automatically
        guard shouldShowExitOffer() else { return }
        
        // Save start time if not already saved (this starts the timer)
        if UserDefaults.standard.object(forKey: exitOfferStartTimeKey) == nil {
            saveExitOfferStartTime()
        }
        
        // Check if timer has expired
        let remaining = getRemainingTime()
        if remaining <= 0 {
            clearExitOfferData()
        }
        // Note: We don't show the exit offer here - it will only show when user taps X
    }
    
    // MARK: - Exit Offer Timer
    private func startExitOfferTimer() {
        // Always calculate remaining time from start time
        exitOfferTimeRemaining = getRemainingTime()
        
        // If already expired, don't start timer and hide offer
        if exitOfferTimeRemaining <= 0 {
            showExitOffer = false
            clearExitOfferData()
            return
        }
        
        exitOfferTimerTask?.cancel()
        
        exitOfferTimerTask = Task {
            while exitOfferTimeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                if !Task.isCancelled {
                    await MainActor.run {
                        // Recalculate remaining time based on actual elapsed time
                        exitOfferTimeRemaining = getRemainingTime()
                        
                        if exitOfferTimeRemaining <= 0 {
                            showExitOffer = false
                            clearExitOfferData()
                            handleCloseAction()
                        }
                    }
                }
            }
        }
    }


    /// Closes the paywall after a successful purchase or restore.
    /// Onboarding opens Home. A paywall opened from Reading returns to that Reading screen.
    private func closePaywallAfterRestore() {
        guard !PaywallProcessHUD.didClosePaywall else { return }
        PaywallProcessHUD.didClosePaywall = true
        UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
        PaywallProcessHUD.hide()

        let host = visiblePaywallController()
        if isPresentedFromOnboarding {
            OnboardingProgress.markCompleted()
            let readerVC = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
            let nav = host?.navigationController ?? keyNavigationController()
            if let nav = nav {
                nav.setViewControllers([readerVC], animated: true)
                return
            }
            performNavigationToReaderWithHome()
            return
        }

        if let host = host {
            if let nav = host.navigationController, nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
                return
            }
            host.dismiss(animated: true, completion: nil)
            return
        }
        dismissHandler?()
    }

    private func visiblePaywallController() -> UIViewController? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        for window in windows {
            if let found = findPaywallController(window.rootViewController) {
                return found
            }
        }
        return nil
    }

    private func findPaywallController(_ vc: UIViewController?) -> UIViewController? {
        guard let vc = vc else { return nil }
        if String(describing: type(of: vc)).contains("BibleSubscription") {
            return vc
        }
        if let presented = vc.presentedViewController, let found = findPaywallController(presented) {
            return found
        }
        if let nav = vc as? UINavigationController {
            for child in nav.viewControllers {
                if let found = findPaywallController(child) {
                    return found
                }
            }
        }
        if let tab = vc as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                if let found = findPaywallController(child) {
                    return found
                }
            }
        }
        for child in vc.children {
            if let found = findPaywallController(child) {
                return found
            }
        }
        return nil
    }

    private func keyNavigationController() -> UINavigationController? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        let window = windows.first(where: { $0.isKeyWindow }) ?? windows.first
        if let nav = window?.rootViewController as? UINavigationController {
            return nav
        }
        return window?.rootViewController?.navigationController
    }

    // MARK: - Navigate to ReaderViewController
    private func navigateToReaderViewController() {
        // Set flag to prevent IAP from showing again
        UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // OLD CODE: Always navigated to ReaderVC without HomeController, causing flicker
        // When dismissing IAP, it would briefly show DailyVerse content before navigating to home
        
        // NEW CODE: Check if we're coming from onboarding or from within the app
        // If from onboarding (isPresentedFromOnboarding = true), navigate to ReaderVC with HomeController
        // If from ReaderVC/SlideCard, just dismiss smoothly
        
        if isPresentedFromOnboarding {
            // Coming from onboarding - navigate to ReaderVC with HomeController
            // Dismiss any presented view controllers (including purchase sheet) before navigation
            if let rootVC = window.rootViewController {
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                // If there's a presented view controller, dismiss it first
                if topVC != rootVC {
                    topVC.dismiss(animated: false) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.performNavigationToReaderWithHome()
                        }
                    }
                    return
                }
            }
            
            performNavigationToReaderWithHome()
        } else {
            // Coming from ReaderVC or SlideCard - just dismiss smoothly
            // OLD CODE: Dismiss without proper animation caused abrupt transition
            
            // NEW CODE: Use smooth default animation for dismiss
            if let dismissHandler = dismissHandler {
                // Use custom dismiss handler with smooth animation
                dismissHandler()
            } else {
                // Fallback: dismiss the hosting controller with smooth animation
                if let rootVC = window.rootViewController {
                    var topVC = rootVC
                    while let presented = topVC.presentedViewController {
                        topVC = presented
                    }
                    
                    // Use default smooth animation (slide down)
                    topVC.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func performNavigationToReaderWithHome() {
        OnboardingProgress.markCompleted()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let readerVC = kStoryboardMainIphone.instantiateViewController(withIdentifier: "ReaderViewController") as! ReaderViewController
        
        if let navController = window.rootViewController as? UINavigationController {
            // OLD CODE: Navigation showed ReaderSourceViewController briefly before home
            // The issue was that ReaderVC's viewDidLoad sets up default view (daily verse)
            // before we could call CallHomeView(), causing a flicker
            
            // NEW CODE: Set view controllers without animation
            // The ReaderVC's viewDidLoad already handles showing home by default
            // (it sets SelectedTab = "0" and calls CallHomeView())
            // So we don't need to do anything extra here
            navController.setViewControllers([readerVC], animated: false)
        }
    }
    
    // MARK: - Exit Offer First Install Logic
    private func isFirstInstall() -> Bool {
        // Check if exit offer has been shown on first install
        return !UserDefaults.standard.bool(forKey: exitOfferFirstInstallShownKey)
    }
    
    private func shouldShowExitOffer() -> Bool {
        // NEW: First check if exit offer product is loaded (immediate check, no delay)
        if !storeManager.isExitOfferProductLoaded {
            print("🔒 [BibleSubscriptionView] Exit offer product not loaded, not showing exit offer")
            return false
        }
        
        // Check if exit offer price is available
        if storeManager.exitOfferPrice.isEmpty || storeManager.exitOfferOriginalPrice.isEmpty {
            print("🔒 [BibleSubscriptionView] Exit offer price not available, not showing exit offer")
            return false
        }
        
        // Check if exit offer has already expired
        if UserDefaults.standard.bool(forKey: exitOfferExpiredKey) {
            return false // Already expired, don't show
        }
        
        // Check if we have a start time (means exit offer was already shown)
        if let startTimeInterval = UserDefaults.standard.object(forKey: exitOfferStartTimeKey) as? TimeInterval {
            // Calculate remaining time
            let startTime = Date(timeIntervalSince1970: startTimeInterval)
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = exitOfferTimerDuration - Int(elapsed)
            
            // Only show if within 10 minutes
            return remaining > 0
        }
        
        // No start time - only show if it's first install
        return isFirstInstall()
    }
    
    private func getRemainingTime() -> Int {
        guard let startTimeInterval = UserDefaults.standard.object(forKey: exitOfferStartTimeKey) as? TimeInterval else {
            return exitOfferTimerDuration
        }
        
        let startTime = Date(timeIntervalSince1970: startTimeInterval)
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = exitOfferTimerDuration - Int(elapsed)
        
        // If time has expired, mark as expired
        if remaining <= 0 {
            UserDefaults.standard.set(true, forKey: exitOfferExpiredKey)
        }
        
        return max(0, remaining)
    }
    
    private func saveExitOfferStartTime() {
        // Only save if not already saved (to preserve original start time)
        if UserDefaults.standard.object(forKey: exitOfferStartTimeKey) == nil {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: exitOfferStartTimeKey)
            // Mark that we've shown the exit offer on first install
            UserDefaults.standard.set(true, forKey: exitOfferFirstInstallShownKey)
        }
    }
    
    private func clearExitOfferData() {
        // Mark as expired - prevents showing again after 10 minutes
        UserDefaults.standard.set(true, forKey: exitOfferExpiredKey)
        UserDefaults.standard.removeObject(forKey: exitOfferStartTimeKey)
        UserDefaults.standard.removeObject(forKey: exitOfferTimeRemainingKey)
    }

}

// MARK: - Price Formatting Utility
extension String {
    /// Clean price string - format with two decimal points
    /// Used across all subscription views to format prices consistently
    func cleanPrice() -> String {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        
        // Use regex to find numeric part (including commas and decimals)
        let pattern = "[0-9,]+(?:\\.[0-9]+)?"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)),
           let range = Range(match.range, in: trimmed) {
            
            let numericPart = String(trimmed[range])
            // Remove commas and parse
            let cleanNumeric = numericPart.replacingOccurrences(of: ",", with: "")
            
            if let number = Double(cleanNumeric) {
                // Format with thousand separators and two decimal places
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = ","
                formatter.usesGroupingSeparator = true
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
                
                if let formattedNumber = formatter.string(from: NSNumber(value: number)) {
                    // Replace the numeric part in the original string
                    return trimmed.replacingOccurrences(of: numericPart, with: formattedNumber)
                } else {
                    // Fallback: format manually with two decimals
                    return trimmed.replacingOccurrences(of: numericPart, with: String(format: "%.2f", number))
                }
            }
        }
        return trimmed
    }
}

// MARK: - Paywall scroll stack (extracted so the compiler can type-check)
@available(iOS 15.0, *)
private struct PaywallScrollStackView: View {
    @ObservedObject var planSelection: PaywallPlanSelection
    @ObservedObject var storeManager: StoreManager
    let monthlyPriceDisplay: String
    let yearlyPriceDisplay: String
    let lifetimePriceDisplay: String
    let yearlySaveLine: String
    let yearlyPerMonthLine: String
    let isPad: Bool
    let isSmallDevice: Bool
    let topSafeInset: CGFloat
    let geoSize: CGSize
    let bottomInset: CGFloat
    /// Only true during Restore — regular purchase must not disable Restore.
    let isRestoring: Bool
    let onPurchase: () -> Void
    let onContinueFree: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            closeSpacer
            titleBlock
            subtitleBlock
            featureSpacing
            featureGrid
            if isPad { Spacer(minLength: 16) }
            planAndCTA
            if isPad { Spacer(minLength: 16) }
            trustRow
            legalRow
            continueFreeButton
            if isPad { Spacer(minLength: 8) }
        }
        .frame(maxWidth: isPad ? 720 : .infinity)
        .frame(maxWidth: .infinity, minHeight: geoSize.height, alignment: isPad ? .center : .top)
        .padding(.horizontal, isPad ? 48 : 0)
        .background {
            ZStack(alignment: .top) {
                Color(hex: "021B40")
                glowBackground
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var closeSpacer: some View {
        Color.clear
            .frame(height: 34)
            .padding(.horizontal, isPad ? 28 : 18)
            .padding(.top, topSafeInset + 8)
    }

    private var titleBlock: some View {
        VStack(spacing: isPad ? 4 : 2) {
            if OnboardingLocale.isIndonesian {
                Text("Selami Lebih Dalam").foregroundColor(.white)
                Text("Firman Tuhan").foregroundColor(Color(hex: "F0C75E"))
            } else {
                Text("Go Deeper").foregroundColor(.white)
                Text("in God's Word").foregroundColor(Color(hex: "F0C75E"))
            }
        }
        .font(.system(size: isPad ? 36 : (isSmallDevice ? 26 : 30), weight: .bold, design: .serif))
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 24)
        .padding(.top, isPad ? 8 : 28)
    }

    private var subtitleBlock: some View {
        VStack(spacing: 2) {
            Text(OnboardingLocale.text(
                id: "Alat belajar yang kuat untuk membantu",
                en: "Powerful study tools to help you"
            ))
            Text(OnboardingLocale.text(
                id: "membaca, memahami, dan bertumbuh.",
                en: "read, understand and grow."
            ))
        }
        .font(.system(size: isPad ? 16 : (isSmallDevice ? 12 : 13), weight: .medium))
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 1)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 28)
        .padding(.top, isPad ? 8 : 6)
    }

    @ViewBuilder
    private var featureSpacing: some View {
        if isPad {
            Spacer(minLength: 12)
        } else {
            Color.clear.frame(height: isSmallDevice ? 28 : 36)
        }
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: isPad ? 12 : 8),
            GridItem(.flexible(), spacing: isPad ? 12 : 8),
            GridItem(.flexible(), spacing: isPad ? 12 : 8)
        ], spacing: isPad ? 12 : 8) {
            PaywallFeatureTile(systemIcon: "doc.text.magnifyingglass", iconColor: Color(hex: "4DA3FF"), title: OnboardingLocale.text(id: "Penjelasan AI Tanpa Batas", en: "Unlimited AI Explanations"))
            PaywallFeatureTile(systemIcon: "doc.plaintext", iconColor: Color(hex: "4CD964"), title: OnboardingLocale.text(id: "Ringkasan Pasal Tanpa Batas", en: "Unlimited Chapter Summaries"))
            PaywallFeatureTile(systemIcon: "bubble.left.and.bubble.right.fill", iconColor: Color(hex: "B07CFF"), title: OnboardingLocale.text(id: "Tanya Alkitab AI", en: "Ask Bible AI"))
            PaywallFeatureTile(systemIcon: "gamecontroller.fill", iconColor: Color(hex: "FF9F0A"), title: OnboardingLocale.text(id: "Buat Kuis Tanpa Batas", en: "Unlimited Quiz Generation"))
            PaywallFeatureTile(systemIcon: "nosign", iconColor: Color(hex: "FF453A"), title: OnboardingLocale.text(id: "Baca Tanpa Iklan", en: "Ad-Free Reading"))
            PaywallFeatureTile(systemIcon: "book.fill", iconColor: Color(hex: "64D2FF"), title: OnboardingLocale.text(id: "Pengalaman Baca yang Nyaman", en: "Clean Reading Experience"))
        }
        .padding(.horizontal, isPad ? 8 : 14)
        .padding(.bottom, isPad ? 8 : 8)
    }

    private var planAndCTA: some View {
        PaywallPlanAndCTASection(
            planSelection: planSelection,
            storeManager: storeManager,
            monthlyPriceDisplay: monthlyPriceDisplay,
            yearlyPriceDisplay: yearlyPriceDisplay,
            lifetimePriceDisplay: lifetimePriceDisplay,
            yearlySaveLine: yearlySaveLine,
            yearlyPerMonthLine: yearlyPerMonthLine,
            isPad: isPad,
            isSmallDevice: isSmallDevice,
            onPurchase: onPurchase
        )
    }

    private var footerBottomPadding: CGFloat {
        let windowInset = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .safeAreaInsets.bottom ?? 0
        return max(bottomInset, windowInset, 20) + 8
    }

    private var continueFreeButton: some View {
        Button(action: onContinueFree) {
            Text(OnboardingLocale.text(id: "Lanjut dengan versi gratis", en: "Continue with Free version"))
                .font(.system(size: isPad ? 15 : 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.92))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 6)
        .padding(.bottom, footerBottomPadding)
    }

    private var trustRow: some View {
        HStack(spacing: 20) {
            if planSelection.plan != .lifetime {
                Label("Cancel anytime", systemImage: "checkmark.shield.fill")
            }
            Label("Secure payment", systemImage: "lock.fill")
        }
        .font(.system(size: isPad ? 13 : 12, weight: .medium))
        .foregroundColor(Color.white.opacity(0.85))
        .padding(.bottom, isPad ? 10 : 8)
    }

    private var legalRow: some View {
        HStack(spacing: 8) {
            Button(action: { storeManager.openTerms() }) {
                Text("Terms of Use")
            }
            Text("|")
            Button(action: { storeManager.openPrivacy() }) {
                Text("Privacy Policy")
            }
            Text("|")
            Button(action: onRestore) {
                Text("Restore Purchase")
            }
            // Block double-tap only while Restore is running — not during a regular purchase.
            .disabled(isRestoring)
        }
        .font(.system(size: isPad ? 13 : 12, weight: .medium))
        .foregroundColor(Color.white.opacity(0.7))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var glowBackground: some View {
        Image("paywall_bible_glow")
            .resizable()
            .scaledToFill()
            .frame(width: geoSize.width, height: geoSize.height)
            .clipped()
            .allowsHitTesting(false)
    }
}

// Supporting views remain the same...
struct PaywallFeatureTile: View {
    let systemIcon: String
    let iconColor: Color
    let title: String

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack(spacing: isPad ? 8 : 6) {
            Image(systemName: systemIcon)
                .font(.system(size: isPad ? 22 : 18, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: isPad ? 40 : 34, height: isPad ? 40 : 34)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.18))
                )
            Text(title)
                .font(.system(size: isPad ? 13 : 10, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: isPad ? 96 : 78)
        .padding(.vertical, isPad ? 14 : 10)
        .padding(.horizontal, isPad ? 8 : 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "0B1B3A").opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

@available(iOS 15.0, *)
private struct PaywallPlanAndCTASection: View {
    @ObservedObject var planSelection: PaywallPlanSelection
    @ObservedObject var storeManager: StoreManager
    let monthlyPriceDisplay: String
    let yearlyPriceDisplay: String
    let lifetimePriceDisplay: String
    let yearlySaveLine: String
    let yearlyPerMonthLine: String
    let isPad: Bool
    let isSmallDevice: Bool
    let onPurchase: () -> Void

    /// "Save X%" of Yearly versus paying Monthly for 12 months.
    private var yearlySavePercentBadge: String {
        let monthly = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
        let yearly = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        let m = Double(monthly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        let y = Double(yearly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        guard m > 0, y > 0, (m * 12) > y else { return "" }
        let percent = Int((((m * 12) - y) / (m * 12) * 100).rounded())
        return percent > 0 ? "Save \(percent)%" : ""
    }

    private var ctaTitle: String {
        switch planSelection.plan {
        case .lifetime, .yearly:
            return "Continue"
        case .monthly:
            return "Start 3-Day Free Trial"
        }
    }

    private var ctaSubtitle: String {
        switch planSelection.plan {
        case .lifetime:
            return "One-time purchase • Lifetime access"
        case .yearly:
            let yearly = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
            return "Then \(yearly.isEmpty ? "—" : yearly)/year. Auto-renews unless cancelled."
        case .monthly:
            let monthly = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
            return "Then \(monthly.isEmpty ? "—" : monthly)/month. Auto-renews unless cancelled."
        }
    }

    // MARK: - Price states (loading / no internet / unavailable / retrying)
    private enum PricePhase { case ready, loading, retrying, noInternet, unavailable }
    @State private var isRetryingPrices = false
    @State private var priceGraceExpired = false

    private var hasAnyPrice: Bool {
        let p1 = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
        let p2 = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        let p3 = storeManager.price3.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag3") ?? "") : storeManager.price3
        return !p1.isEmpty || !p2.isEmpty || !p3.isEmpty
    }

    private var isFetchingPrices: Bool {
        storeManager.isLoading1 || storeManager.isLoading2 || storeManager.isLoading3
    }

    private var pricePhase: PricePhase {
        if hasAnyPrice { return .ready }
        let online = NetworkManager.sharedInstance.isConnectedToInternet()
        if isRetryingPrices { return isFetchingPrices ? .retrying : (online ? .unavailable : .noInternet) }
        if isFetchingPrices { return .loading }
        if !online { return .noInternet }
        if storeManager.hasProductLoadError || priceGraceExpired { return .unavailable }
        return .loading
    }

    private func retryPrices() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return
        }
        isRetryingPrices = true
        storeManager.retryAllPrices()
    }

    private var priceStatusCard: some View {
        VStack(spacing: 8) {
            switch pricePhase {
            case .loading, .retrying:
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    .frame(height: 36)
                Text(pricePhase == .retrying
                     ? OnboardingLocale.text(id: "Mencoba lagi...", en: "Retrying...")
                     : OnboardingLocale.text(id: "Mengambil harga...", en: "Getting your price..."))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                Text(pricePhase == .retrying
                     ? OnboardingLocale.text(id: "Mengambil harga lagi...", en: "Getting your price again...")
                     : OnboardingLocale.text(id: "Mohon tunggu sebentar", en: "Please wait a moment"))
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8B95A7"))
            case .noInternet, .unavailable, .ready:
                let offline = pricePhase == .noInternet
                Image(systemName: offline ? "wifi.slash" : "exclamationmark.circle")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(offline ? Color(hex: "607089") : Color(hex: "E5483B"))
                Text(offline
                     ? OnboardingLocale.text(id: "Tidak Ada Koneksi Internet", en: "No Internet Connection")
                     : OnboardingLocale.text(id: "Harga tidak tersedia", en: "Price unavailable"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                Text(offline
                     ? OnboardingLocale.text(id: "Periksa koneksi internetmu dan coba lagi.", en: "Please check your internet connection and try again.")
                     : OnboardingLocale.text(id: "Kami tidak bisa memuat harga pembelian. Ini mungkin masalah sementara. Silakan coba lagi.", en: "We couldn't load the purchase price. This may be a temporary issue. Please try again."))
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8B95A7"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                Button(action: retryPrices) {
                    HStack(spacing: 8) {
                        Text(OnboardingLocale.text(id: "Coba Lagi", en: "Try Again"))
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color(hex: "2F6BFF")))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .padding(.horizontal, isPad ? 8 : 12)
        .padding(.top, isPad ? 4 : 2)
        .padding(.bottom, isPad ? 8 : 10)
    }

    var body: some View {
        VStack(spacing: 0) {
            if pricePhase == .ready {
            HStack(alignment: .top, spacing: isPad ? 14 : 8) {
                PaywallPlanCardView(
                    style: .monthly,
                    title: "Monthly",
                    priceLine: monthlyPriceDisplay,
                    secondaryLine: "3-Day Free Trial",
                    tertiaryLine: "You won't be charged today",
                    isLoading: storeManager.isLoading1,
                    planSelection: planSelection
                )
                PaywallPlanCardView(
                    style: .yearly,
                    title: "Yearly",
                    priceLine: yearlyPriceDisplay,
                    secondaryLine: yearlySaveLine,
                    tertiaryLine: yearlyPerMonthLine,
                    isLoading: storeManager.isLoading2,
                    planSelection: planSelection,
                    badgeText: yearlySavePercentBadge
                )
                PaywallPlanCardView(
                    style: .lifetime,
                    title: "Lifetime Study",
                    priceLine: lifetimePriceDisplay,
                    secondaryLine: "One-time payment",
                    tertiaryLine: "Ad-free reading only AI features use credits",
                    isLoading: storeManager.isLoading3,
                    planSelection: planSelection,
                    badgeText: "Best Value"
                )
            }
            .padding(.horizontal, isPad ? 8 : 12)
            .padding(.top, isPad ? 4 : 2)
            .padding(.bottom, isPad ? 8 : 10)
            } else {
                priceStatusCard
            }

            if pricePhase == .loading || pricePhase == .retrying {
                // Same height as the purchase button, disabled until a price arrives.
                Text(OnboardingLocale.text(id: "Memuat harga...", en: "Loading price..."))
                    .font(.system(size: isPad ? 18 : 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isPad ? 56 : (isSmallDevice ? 48 : 52))
                    .background(Color(hex: "2F6BFF").opacity(0.45))
                    .cornerRadius(16)
                    .padding(.horizontal, isPad ? 8 : 18)
                    .padding(.bottom, isPad ? 12 : 8)
            }

            if pricePhase == .ready {
            Button(action: onPurchase) {
                HStack(spacing: 8) {
                    Text(ctaTitle)
                        .font(.system(size: isPad ? 18 : 17, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: isPad ? 56 : (isSmallDevice ? 48 : 52))
                .background(Color(hex: "2F6BFF"))
                .cornerRadius(16)
            }
            .padding(.horizontal, isPad ? 8 : 18)
            .padding(.bottom, isPad ? 12 : 8)

            Text(ctaSubtitle)
                .font(.system(size: isPad ? 13 : 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, isPad ? 10 : 8)
            }
        }
        .onAppear {
            // Safety: never spin forever if the price request never starts or never answers.
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) { priceGraceExpired = true }
        }
    }
}

struct PaywallPlanCardView: View {
    enum Style {
        case monthly
        case yearly
        case lifetime
    }

    let style: Style
    let title: String
    let priceLine: String
    let secondaryLine: String
    let tertiaryLine: String
    let isLoading: Bool
    @ObservedObject var planSelection: PaywallPlanSelection
    var badgeText: String? = nil

    private var accent: Color { Color(hex: "2F6BFF") }
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    private var plan: SubscriptionPlan {
        switch style {
        case .monthly: return .monthly
        case .yearly: return .yearly
        case .lifetime: return .lifetime
        }
    }
    private var isSelected: Bool { planSelection.plan == plan }

    var body: some View {
        Button {
            planSelection.plan = plan
        } label: {
            VStack(spacing: isPad ? 8 : 6) {
                Text(title)
                    .font(.system(size: isPad ? 15 : 13, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if isLoading {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        .frame(height: 36)
                } else {
                    Text(priceLine)
                        .font(.system(size: style == .lifetime ? (isPad ? 17 : 15) : (isPad ? 16 : 14), weight: .bold))
                        .foregroundColor(accent)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .multilineTextAlignment(.center)

                    if !secondaryLine.isEmpty {
                        Text(secondaryLine)
                            .font(.system(size: isPad ? 13 : 11, weight: style == .yearly ? .bold : .semibold))
                            .foregroundColor(style == .yearly ? Color(hex: "E53935") : accent)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }

                    if !tertiaryLine.isEmpty {
                        Text(tertiaryLine)
                            .font(.system(size: isPad ? 11 : 9, weight: .medium))
                            .foregroundColor(Color(hex: "6B6B6B"))
                            .lineLimit(nil)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: isPad ? 132 : 118)
            .padding(.horizontal, isPad ? 12 : 8)
            .padding(.vertical, isPad ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? accent : Color.black.opacity(0.12), lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: isSelected ? accent.opacity(0.45) : Color.black.opacity(0.15), radius: isSelected ? 10 : 4, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(alignment: .top) {
            if let badgeText, !badgeText.isEmpty {
                Text(badgeText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accent))
                    .offset(y: -12)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct FeatureRow: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

struct YearlyPlanCard: View {
    let price: String
    let originalPrice: String
    let isSelected: Bool
    let isLoading: Bool
    let isSmallDevice: Bool
    let showOffer: Bool
    let action: () -> Void
    
    // State to hold offer value and make view reactive
    @State private var offerValue: String = ""
    
    // Read offer_enabled directly from UserDefaults to make it reactive
    @AppStorage("offer_enabled") private var offerEnabled: String = ""
    
    // Computed property to check if offer should be shown
    // Show badge if offer value exists (regardless of offer_enabled flag)
    // This matches the behavior where if API provides a discount value, show it
    private var shouldShowOffer: Bool {
        return !offerValue.isEmpty
    }

    /// Prefer live StoreKit price; fall back to last cached price for offline UI. No rounding.
    private var displayPriceText: String {
        if !price.isEmpty { return price }
        if let cached = UserDefaults.standard.string(forKey: "PriceTag2"), !cached.isEmpty {
            return cached
        }
        return ""
    }
    
    // Helper to read offer value from UserDefaults (handles both Int and String)
    private func readOfferValue() -> String {
        // Try reading as Int first (API might store as number)
        if let intValue = UserDefaults.standard.object(forKey: "sub_identifier_oneyear_value") as? Int {
            return String(intValue)
        }
        // Try reading as String
        if let stringValue = UserDefaults.standard.string(forKey: "sub_identifier_oneyear_value"), !stringValue.isEmpty {
            return stringValue
        }
        return ""
    }
    
    // Computed property to get the strikeout price (calculate dynamically if needed)
    private var strikeoutPrice: String {
        // Always calculate dynamically when there's an offer to ensure accuracy
        // This ensures we get the correct value even if originalPrice is incorrectly set
        if shouldShowOffer, let discount = Float(offerValue), !price.isEmpty {
            // Extract numeric value - remove commas and other formatting
            let strippedNumeric = price.strippedtext.replacingOccurrences(of: ",", with: "")
            guard let numericValue = Float(strippedNumeric), numericValue > 0 else {
                print("⚠️ [YearlyPlanCard] Failed to parse price: '\(price)' -> stripped: '\(price.strippedtext)' -> numeric: '\(strippedNumeric)'")
                return ""
            }
            
            // Calculate original price: if discounted price = original * (100 - discount) / 100
            // Then original = discounted * 100 / (100 - discount). Keep cents — no Int rounding.
            let originalValue = (numericValue / (100 - discount)) * 100
            
            // Extract currency symbol by removing all digits, commas, dots, and spaces
            let symbol = price.replacingOccurrences(of: "[0-9,.]", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            let number = formatter.string(from: NSNumber(value: originalValue)) ?? String(format: "%.2f", originalValue)
            
            print("💰 [YearlyPlanCard] Price calculation: price=\(price), discount=\(discount)%, numeric=\(numericValue), original=\(number)")
            print("💰 [YearlyPlanCard] Extracted symbol: '\(symbol)'")
            print("💰 [YearlyPlanCard] Strikeout price result: '\(symbol)\(number)'")
            
            return "\(symbol)\(number)"
        }
        
        // Fallback: If no offer but originalPrice is provided, use it (remove decimals if present)
        if !originalPrice.isEmpty {
            // Remove .00 or .0 from the end if present
            var cleanedPrice = originalPrice
            if cleanedPrice.hasSuffix(".00") {
                cleanedPrice = String(cleanedPrice.dropLast(3))
            } else if cleanedPrice.hasSuffix(".0") {
                cleanedPrice = String(cleanedPrice.dropLast(2))
            }
            return cleanedPrice
        }
        
        return ""
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Card content
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Yearly")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Full access for 1 year")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .italic()
                    }
                    
                    Spacer()
                    
                    if isLoading && price.isEmpty {
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            .scaleEffect(1.2)
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            // Show strikeout original price if offer exists (before current price)
                            if shouldShowOffer && !strikeoutPrice.isEmpty {
                                Text(strikeoutPrice)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                    .strikethrough(true, color: Color(red: 0.6, green: 0.6, blue: 0.6))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .onAppear {
                                        print("🎨 [YearlyPlanCard] Displaying strikeout price: '\(strikeoutPrice)' -> cleaned: '\(strikeoutPrice.cleanPrice())'")
                                    }
                            }
                            
                            // Current discounted price (cached price still shows offline)
                            Text(displayPriceText)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color(hex: "1C46B2") : Color(red: 0.85, green: 0.85, blue: 0.85),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                )
                
                // Badge - positioned on top of the card
                if shouldShowOffer {
                    Text("Save \(offerValue)%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "1C46B2"))
                        )
                        .offset(x: -8, y: -8)
                        .zIndex(10) // Ensure badge is on top
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Debug logging
            let currentOfferValue = readOfferValue()
            print("🔍 [YearlyPlanCard] onAppear:")
            print("   → showOffer (passed): \(showOffer)")
            print("   → offerEnabled (@AppStorage): '\(offerEnabled)'")
            print("   → offerValue from UserDefaults: '\(currentOfferValue)'")
            print("   → shouldShowOffer: \(shouldShowOffer)")
            print("   → offer_enabled (global): '\(offer_enabled)'")
            
            // Update offer value when view appears
            offerValue = currentOfferValue
            
            // Check again after delays (in case value is set after view appears)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let newValue = readOfferValue()
                print("   → After 0.5s - offerValue: '\(newValue)', shouldShowOffer: \(!newValue.isEmpty)")
                if newValue != offerValue {
                    offerValue = newValue
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newValue = readOfferValue()
                print("   → After 1.0s - offerValue: '\(newValue)', shouldShowOffer: \(!newValue.isEmpty)")
                if newValue != offerValue {
                    offerValue = newValue
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let newValue = readOfferValue()
                print("   → After 2.0s - offerValue: '\(newValue)'")
                print("   → Final check - shouldShowOffer: \(!newValue.isEmpty) (badge will show if value exists)")
                if newValue != offerValue {
                    offerValue = newValue
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            let newValue = readOfferValue()
            if newValue != offerValue {
                print("   → UserDefaults changed, new offerValue: '\(newValue)'")
                offerValue = newValue
            }
        }
        .onChange(of: showOffer) { newValue in
            print("   → showOffer changed to: \(newValue)")
            offerValue = readOfferValue()
        }
    }
}




struct LifetimePlanCard: View {
    let price: String
    let originalPrice: String
    let isSelected: Bool
    let isLoading: Bool
    let isSmallDevice: Bool
    let showOffer: Bool
    let action: () -> Void

    /// Prefer live StoreKit price; fall back to last cached price for offline UI. No rounding.
    private var displayPriceText: String {
        if !price.isEmpty { return price }
        if let cached = UserDefaults.standard.string(forKey: "PriceTag3"), !cached.isEmpty {
            return cached
        }
        return ""
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lifetime")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Pay once, Grow forever")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .italic()
                }
                
                Spacer()
                
                if isLoading && price.isEmpty {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        .scaleEffect(1.2)
                } else {
                    VStack(spacing: 2) {
                       
                        Text(displayPriceText)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color(hex: "1C46B2") : Color(red: 0.85, green: 0.85, blue: 0.85),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
                
                // ✅ ADDED: "Best Value" badge for Lifetime plan
                Text("Best Value")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "1C46B2"))
                    )
                    .offset(x: -8, y: -8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}




final class PaywallPlanSelection: ObservableObject {
    @Published var plan: SubscriptionPlan = .yearly
}

enum SubscriptionPlan: Equatable {
    case monthly
    case yearly
    case lifetime
}

private enum PaywallOwnedKind {
    case month
    case year
    case lifetime
}


// Add this at the top of your file, before BibleSubscriptionView
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        
        // CRITICAL FIX: Set color so it's visible on white background
        activityIndicator.color = UIColor(red: 0.11, green: 0.27, blue: 0.7, alpha: 1.0) // Match your blue theme
        
        // CRITICAL FIX: Don't hide when stopped (for debugging)
        activityIndicator.hidesWhenStopped = false
        
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}


// MARK: - Exit Offer View
@available(iOS 15.0, *)
struct ExitOfferView: View {
    let originalPrice: String
    let discountedPrice: String
    let discountText: String
    let planText: String
    let timeRemaining: Int
    let hasError: Bool
    let onPurchase: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    Image(systemName: "percent")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(OnboardingTheme.gold)
                        .padding(14)
                        .background(Circle().stroke(OnboardingTheme.gold.opacity(0.6), lineWidth: 1.5))

                    Text("ONE MORE OPTION")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(OnboardingTheme.gold)

                    Text("Keep Growing for Less.")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    VStack(spacing: 8) {
                        Text("SPECIAL OFFER")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(OnboardingTheme.gold)
                        Text("\(discountedPrice) / year")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        if !originalPrice.isEmpty {
                            Text(originalPrice)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.45))
                                .strikethrough()
                        }
                        Text("Limited Time Offer")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(OnboardingTheme.gold.opacity(0.7), lineWidth: 1.5)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        exitCheck("Unlimited explanations")
                        exitCheck("Unlimited chapter insights")
                        exitCheck("All challenges")
                        exitCheck("Ad-free experience")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: onPurchase) {
                        Text("Claim Offer")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(OnboardingTheme.navy)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(OnboardingTheme.gold)
                            .cornerRadius(27)
                    }

                    Button(action: onDismiss) {
                        Text("Continue Free")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .padding(.bottom, 8)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(OnboardingTheme.navy)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private func exitCheck(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(OnboardingTheme.gold)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }
}

// MARK: - Custom Button Style for better interaction
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Shape with rounded top corners and flat bottom
struct TopRoundedShape: Shape {
    var radius: CGFloat = 16
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tr = CGSize(width: radius, height: radius)
        let tl = CGSize(width: radius, height: radius)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.minX + radius, y: rect.minY),
                    radius: radius)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY + radius),
                    radius: radius)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Full-screen restore loader on the paywall window. Works for iPhone and iPad.
private enum PaywallProcessHUD {
    private static weak var overlay: UIView?
    static var didClosePaywall = false

    static func show() {
        let present = {
            guard overlay == nil, let container = hostView() else { return }
            let dim = UIView(frame: container.bounds)
            dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dim.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            dim.layer.zPosition = CGFloat.greatestFiniteMagnitude

            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.startAnimating()

            let label = UILabel()
            label.text = "Processing..."
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .medium)

            let stack = UIStackView(arrangedSubviews: [spinner, label])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 16
            stack.translatesAutoresizingMaskIntoConstraints = false

            let card = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            card.layer.cornerRadius = 16
            card.clipsToBounds = true
            card.translatesAutoresizingMaskIntoConstraints = false
            card.contentView.addSubview(stack)
            dim.addSubview(card)
            container.addSubview(dim)
            container.bringSubviewToFront(dim)
            overlay = dim

            NSLayoutConstraint.activate([
                card.centerXAnchor.constraint(equalTo: dim.centerXAnchor),
                card.centerYAnchor.constraint(equalTo: dim.centerYAnchor),
                stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 30),
                stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -30),
                stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 30),
                stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -30)
            ])
        }
        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }

    static func hide() {
        let remove = {
            overlay?.removeFromSuperview()
            overlay = nil
        }
        if Thread.isMainThread {
            remove()
        } else {
            DispatchQueue.main.async(execute: remove)
        }
    }

    private static func hostView() -> UIView? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        if let paywallWindow = OnboardingAuthManager.topViewController()?.view.window {
            return paywallWindow
        }
        return windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        BibleSubscriptionView()
    }
}

/// Plan prompts for the individual app's current paywall only. The Pro paywall does not use this.
final class PaywallTriggerGate {

    static let shared = PaywallTriggerGate()

    private let installKey = "PaywallTriggerInstallAt"
    private let lastPopupKey = "PaywallTriggerLastPopupAt"
    private let lastRatingKey = "PaywallTriggerLastRatingAt"
    private let ratingVersionKey = "PaywallTriggerRatingVersion"
    private let imageDayKey = "PaywallTriggerImageDay"
    private let imageCountKey = "PaywallTriggerImageCount"
    private let adDayKey = "PaywallTriggerAdDay"
    private let adCountKey = "PaywallTriggerAdCount"
    private let shownKey = "PaywallTriggerShown"
    private let finishedBooksKey = "PaywallTriggerFinishedBooks"
    private let feedbackAtKey = "PaywallTriggerFeedbackAt"

    private var shownThisSession = false
    private var paywallShownThisSession = false
    private var negativeThisSession = false
    private var pendingMilestone: String?
    private var openingMilestones = Set<String>()
    private var pendingFeedback = false
    private var pendingFeedbackBook = ""
    private var pendingFeedbackChapters = 0
    private var skipDay30Flush = false
    private var didDeferDay30 = false
    private var suppressDay3ThisSession = false
    private var day3Tries = 0
    private let day3PendingDayKey = "PaywallTriggerDay3PendingDay"
    private var imageSheetTries = 0
    private var imageSheetOpening = false
    private var feedbackTries = 0
    private var feedbackOpening = false
    private var userCooldown: [String: Date] = [:]

    private init() {}

    /// Individual single-book app, on the current paywall. Pro onboarding never enters here.
    var isEnabled: Bool { APP_TYPE == "1" && usesOldOnboarding }

    var showsSettingsPremiumRow: Bool { isEnabled && !isEntitled }

    func isUserStartedCoolingDown(_ name: String) -> Bool {
        if name == "settings" || name == "chatLimit" || name == "chatCredits" { return false }
        guard let last = userCooldown[name] else { return false }
        return Date().timeIntervalSince(last) < 30 * 60
    }

    /// Explanation / summary limit sheet. Shown on every tap (no cooldown or rating block). `onClosed` runs when it closes.
    /// Returns false when nothing will open (paid users, gate off).
    @discardableResult
    func requestAILimitSheet(onClosed: @escaping () -> Void) -> Bool {
        guard isEnabled, !isEntitled else { return false }
        noteAIActiveDay()
        // The sheet shows once, then again after 7 more active days. In between, a tap shows only the toast.
        guard aiLimitSheetIsDue else {
            OnboardingAuthManager.topViewController()?.view.makeToast(Self.aiInsightsToast, duration: 2.0, position: .top)
            return true
        }
        guard NetworkManager.sharedInstance.isConnectedToInternet(),
              PaywallTriggerPresenter.canPresent("aiExplain") else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return true
        }
        UserDefaults.standard.set(aiActiveDays.count, forKey: aiSheetShownAtCountKey)
        presentCurrentPaywall(countsAsPopup: false, trigger: "aiExplain", onClose: onClosed)
        return true
    }

    static let aiInsightsToast = "Unlock unlimited Bible insights with Premium!"
    private let aiActiveDaysKey = "PaywallTriggerAIActiveDays"
    private let aiSheetShownAtCountKey = "PaywallTriggerAISheetShownAtCount"

    private var aiActiveDays: [String] {
        UserDefaults.standard.stringArray(forKey: aiActiveDaysKey) ?? []
    }

    /// Counts each calendar day the app was used (reader opened or a limit tap).
    private func noteAIActiveDay() {
        var days = aiActiveDays
        guard !days.contains(today) else { return }
        days.append(today)
        UserDefaults.standard.set(days, forKey: aiActiveDaysKey)
    }

    private var aiLimitSheetIsDue: Bool {
        guard UserDefaults.standard.object(forKey: aiSheetShownAtCountKey) != nil else { return true }
        let shownAt = UserDefaults.standard.integer(forKey: aiSheetShownAtCountKey)
        return aiActiveDays.count - shownAt >= 7
    }

    /// Separate trigger for Get Summary, Get Explanation and AI Chat. Each feature has its own counter,
    /// so one feature using its trigger never blocks another. Shows the first time the limit is over,
    /// then again after 7 more active days. Returns false when nothing opened (not due, offline, paid user),
    /// so the caller can show the credits card or toast instead. `onClosed` runs when the sheet closes.
    @discardableResult
    func requestFeatureLimitSheet(feature: String, trigger: String, onClosed: @escaping () -> Void) -> Bool {
        guard isEnabled, !isEntitled else { return false }
        noteAIActiveDay()
        let key = "PaywallTriggerFeatureSheetAtCount_" + feature
        if UserDefaults.standard.object(forKey: key) != nil {
            let shownAt = UserDefaults.standard.integer(forKey: key)
            guard aiActiveDays.count - shownAt >= 7 else { return false }
        }
        guard NetworkManager.sharedInstance.isConnectedToInternet(),
              PaywallTriggerPresenter.canPresent(trigger) else { return false }
        UserDefaults.standard.set(aiActiveDays.count, forKey: key)
        presentCurrentPaywall(countsAsPopup: false, trigger: trigger, onClose: onClosed)
        return true
    }

    /// Returns false when nothing will open, so the caller can show another response instead of doing nothing.
    @discardableResult
    func requestUserStarted(_ name: String) -> Bool {
        guard isEnabled else { return false }
        guard !isEntitled else { return false }
        guard !isBusy else { return false }
        if name != "settings", blockedAfterRating() { return false }
        let chatCanRepeat = name == "chatLimit" || name == "chatCredits"
        if name != "settings", !chatCanRepeat, isUserStartedCoolingDown(name) { return false }
        guard PaywallTriggerPresenter.canPresent(name) else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return true
        }
        presentCurrentPaywall(countsAsPopup: false, trigger: name)
        return true
    }

    func noteChapterMarked(book: String, marked: [String]) {
        guard isEnabled, !book.isEmpty else { return }
        let total = marked.count
        if total == 5 { pendingMilestone = "chapter.5" }
        if total == 10 { pendingMilestone = "chapter.10" }
        let prefix = book + "-"
        let readInBook = marked.filter { $0.hasPrefix(prefix) }.count
        let chapterCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: book)
        guard chapterCount > 0, readInBook >= chapterCount else { return }
        var finished = UserDefaults.standard.stringArray(forKey: finishedBooksKey) ?? []
        guard !finished.contains(book) else { return }
        let firstBook = finished.isEmpty
        finished.append(book)
        UserDefaults.standard.set(finished, forKey: finishedBooksKey)
        if firstBook || feedbackIsDue() {
            rememberFeedback(book: book, chapters: readInBook)
            presentPendingFeedback()
        } else {
            pendingMilestone = "book." + book
            presentPendingBookCard()
        }
    }

    private func feedbackIsDue() -> Bool {
        let last = UserDefaults.standard.double(forKey: feedbackAtKey)
        if last == 0 { return true }
        return Date().timeIntervalSince1970 - last >= 60 * 24 * 60 * 60
    }

    private func rememberFeedback(book: String, chapters: Int) {
        pendingFeedback = true
        pendingFeedbackBook = book
        pendingFeedbackChapters = chapters
        pendingMilestone = nil
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "PaywallTriggerFeedbackPending")
        defaults.set(book, forKey: "PaywallTriggerFeedbackBook")
        defaults.set(chapters, forKey: "PaywallTriggerFeedbackChapters")
    }

    /// After the first finished book, then at most every 60 days.
    /// Great → rating (if last rating ≥ 60 days ago) or thanks. Could be better → private form + support mail.
    private func presentPendingFeedback() {
        guard isEnabled else { return }
        guard UserDefaults.standard.bool(forKey: "PaywallTriggerFeedbackPending") || pendingFeedback else { return }
        let last = UserDefaults.standard.double(forKey: feedbackAtKey)
        if last > 0 && Date().timeIntervalSince1970 - last < 60 * 24 * 60 * 60 {
            UserDefaults.standard.set(false, forKey: "PaywallTriggerFeedbackPending")
            pendingFeedback = false
            return
        }
        guard !feedbackOpening else { return }
        guard !isBusy else {
            feedbackTries += 1
            guard feedbackTries <= 20 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.presentPendingFeedback()
            }
            return
        }
        let book = UserDefaults.standard.string(forKey: "PaywallTriggerFeedbackBook") ?? pendingFeedbackBook
        let chapters = max(UserDefaults.standard.integer(forKey: "PaywallTriggerFeedbackChapters"), pendingFeedbackChapters)
        feedbackOpening = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.feedbackOpening = false
            guard let top = OnboardingAuthManager.topViewController() else { return }
            if top.presentedViewController != nil {
                self.feedbackTries += 1
                guard self.feedbackTries <= 20 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                    self?.presentPendingFeedback()
                }
                return
            }
            PaywallTriggerPresenter.showFeedback(book: book, chapters: chapters, from: top)
            UserDefaults.standard.set(false, forKey: "PaywallTriggerFeedbackPending")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: self.feedbackAtKey)
            self.pendingFeedback = false
            self.feedbackTries = 0
            self.shownThisSession = true
        }
    }

    /// Great on the finished-book card: rating again only if last ask was ≥ 60 days ago (or never).
    func shouldOfferRatingAfterFeedbackGreat() -> Bool {
        let last = UserDefaults.standard.double(forKey: lastRatingKey)
        if last == 0 { return true }
        return Date().timeIntervalSince1970 - last >= 60 * 24 * 60 * 60
    }

    func playFeedbackGreatRating() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        UserDefaults.standard.set(version, forKey: ratingVersionKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastRatingKey)
        shownThisSession = true
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    /// Mark-as-Read quiz was deferred while the feedback card was showing.
    func noteMarkAsReadQuizDeferred() {
        UserDefaults.standard.set(true, forKey: "PaywallTriggerQuizAfterFeedback")
    }

    func noteFeedbackFlowClosed() {
        flush()
        guard UserDefaults.standard.bool(forKey: "PaywallTriggerQuizAfterFeedback") else { return }
        UserDefaults.standard.set(false, forKey: "PaywallTriggerQuizAfterFeedback")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            App_Protocol.delegateReader?.MarkAsReadPopup()
        }
    }

    /// HTML image 15: the finished-book card stays on the reading screen. It is not dropped if another rule blocks this moment.
    private func presentPendingBookCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self = self else { return }
            guard self.isEnabled, !self.isEntitled, !self.isBusy else { return }
            guard let key = self.pendingMilestone, key.hasPrefix("book.") else { return }
            guard !self.hasShown(key), !self.openingMilestones.contains(key) else { return }
            guard PaywallTriggerPresenter.canPresent(key) else { return }
            self.pendingMilestone = nil
            self.presentCurrentPaywall(countsAsPopup: true, milestone: key, trigger: key)
        }
    }

    func noteVerseImageSaved() {
        guard isEnabled else { return }
        let defaults = UserDefaults.standard
        if defaults.string(forKey: imageDayKey) != today {
            defaults.set(0, forKey: "PaywallTriggerImageBonus")
        }
        let count = savedImagesToday() + 1
        defaults.set(today, forKey: imageDayKey)
        defaults.set(count, forKey: imageCountKey)
        if count == 3 { requestRatingIfEligible() }
        let free = 3 + defaults.integer(forKey: "PaywallTriggerImageBonus")
        if count == free + 1 {
            defaults.set(true, forKey: "PaywallTriggerImageSheetPending")
            imageSheetTries = 0
            presentImageLimitSheet()
        }
    }

    /// HTML image 03. The 4th download of the day opens this sheet, and it stays pending until it can show.
    private func presentImageLimitSheet() {
        guard isEnabled, !isEntitled else {
            UserDefaults.standard.set(false, forKey: "PaywallTriggerImageSheetPending")
            return
        }
        guard UserDefaults.standard.bool(forKey: "PaywallTriggerImageSheetPending") else { return }
        guard !imageSheetOpening else { return }
        guard !isBusy, PaywallTriggerPresenter.canPresent("image") else {
            imageSheetTries += 1
            guard imageSheetTries <= 6 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.presentImageLimitSheet()
            }
            return
        }
        imageSheetOpening = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageSheetOpening = false
            guard let top = OnboardingAuthManager.topViewController() else { return }
            guard NetworkManager.sharedInstance.isConnectedToInternet() else { return }
            guard PaywallTriggerPresenter.show(trigger: "image", from: top, onClose: {}) else { return }
            UserDefaults.standard.set(false, forKey: "PaywallTriggerImageSheetPending")
            self.imageSheetTries = 0
            self.paywallShownThisSession = true
        }
    }

    func noteInterstitialClosed() {
        guard isEnabled else { return }
        let defaults = UserDefaults.standard
        if defaults.string(forKey: adDayKey) != today {
            defaults.set(0, forKey: "PaywallTriggerAd3At")
        }
        let count = interstitialsToday() + 1
        defaults.set(today, forKey: adDayKey)
        defaults.set(count, forKey: adCountKey)
        let key = "ad.3." + today
        guard count >= 3, !negativeThisSession, !hasShown(key) else { return }
        if defaults.double(forKey: "PaywallTriggerAd3At") == 0 {
            defaults.set(Date().timeIntervalSince1970, forKey: "PaywallTriggerAd3At")
        }
    }

    func noteNegativeMoment() {
        guard isEnabled else { return }
        negativeThisSession = true
    }

    func noteStreakDay(_ day: Int) {
        guard isEnabled else { return }
        guard day == 3 || day == 7 || day == 30 else { return }
        if day == 3 {
            // Remember the day-3 card even if the celebration was closed another way; it shows on a later day.
            let defaults = UserDefaults.standard
            if !hasShown("streak.3"), !defaults.bool(forKey: "PaywallTriggerDay3Pending") {
                defaults.set(true, forKey: "PaywallTriggerDay3Pending")
                defaults.set(today, forKey: day3PendingDayKey)
            }
            return
        }
        if day == 30 {
            UserDefaults.standard.set(true, forKey: "PaywallTriggerDay30Pending")
            if !didDeferDay30 {
                didDeferDay30 = true
                skipDay30Flush = true
            }
            return
        }
        if day == 7, ratingIsEligible(), !hasShown("streak.7") {
            markShown("streak.7")
            playSystemRating()
            return
        }
        showMilestone("streak.\(day)")
    }

    /// HTML: after the streak celebration. Day 3 card. Day 7 is Apple's rating, or the card when rating is not allowed. Day 30 is the Lifetime screen. Never rating and the card together.
    func noteStreakCelebrationFinished(_ day: Int) {
        guard isEnabled else { return }
        switch day {
        case 30:
            UserDefaults.standard.set(true, forKey: "PaywallTriggerDay30Pending")
            skipDay30Flush = false
            showMilestone("streak.30")
            if hasShown("streak.30") {
                UserDefaults.standard.set(false, forKey: "PaywallTriggerDay30Pending")
            }
        case 7:
            guard !hasShown("streak.7") else { return }
            if ratingIsEligible() {
                markShown("streak.7")
                playSystemRating()
            } else {
                showMilestone("streak.7")
            }
        case 3:
            guard !hasShown("streak.3") else { return }
            UserDefaults.standard.set(true, forKey: "PaywallTriggerDay3Pending")
            UserDefaults.standard.set(today, forKey: day3PendingDayKey)
            suppressDay3ThisSession = true
        default:
            break
        }
    }

    func playSystemRating() {
        requestRatingIfEligible()
    }

    /// Day-3 card waits for a later day than the one the streak reached 3.
    private var day3CardIsDue: Bool {
        let defaults = UserDefaults.standard
        guard !suppressDay3ThisSession,
              defaults.bool(forKey: "PaywallTriggerDay3Pending"),
              !hasShown("streak.3") else { return false }
        return defaults.string(forKey: day3PendingDayKey) != today
    }

    /// App open can be busy (other screen, prices loading). Try the day-3 card a few more times.
    private func retryDay3Card() {
        guard day3Tries < 10 else { return }
        day3Tries += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, self.day3CardIsDue,
                  !self.openingMilestones.contains("streak.3") else { return }
            self.showMilestone("streak.3")
            if self.hasShown("streak.3") {
                UserDefaults.standard.set(false, forKey: "PaywallTriggerDay3Pending")
                return
            }
            if self.openingMilestones.contains("streak.3") { return }
            self.retryDay3Card()
        }
    }

    func flush() {
        guard isEnabled else { return }
        noteAIActiveDay()
        if UserDefaults.standard.bool(forKey: "PaywallTriggerImageSheetPending") {
            imageSheetTries = 0
            presentImageLimitSheet()
        }
        if day3CardIsDue {
            showMilestone("streak.3")
            if hasShown("streak.3") {
                UserDefaults.standard.set(false, forKey: "PaywallTriggerDay3Pending")
            }
            if hasShown("streak.3") || openingMilestones.contains("streak.3") { return }
            retryDay3Card()
        }
        let adAt = UserDefaults.standard.double(forKey: "PaywallTriggerAd3At")
        if UserDefaults.standard.string(forKey: adDayKey) != today {
            UserDefaults.standard.set(0, forKey: "PaywallTriggerAd3At")
        } else if adAt > 0 {
            let elapsed = Date().timeIntervalSince1970 - adAt
            let key = "ad.3." + today
            if elapsed >= 60, !hasShown(key) {
                showMilestone(key)
                if hasShown(key) || openingMilestones.contains(key) {
                    UserDefaults.standard.set(0, forKey: "PaywallTriggerAd3At")
                    return
                }
            }
        }
        if !skipDay30Flush, UserDefaults.standard.bool(forKey: "PaywallTriggerDay30Pending") {
            showMilestone("streak.30")
            if hasShown("streak.30") {
                UserDefaults.standard.set(false, forKey: "PaywallTriggerDay30Pending")
            }
            if hasShown("streak.30") { return }
        }
        if skipDay30Flush { skipDay30Flush = false }
        if pendingFeedback || UserDefaults.standard.bool(forKey: "PaywallTriggerFeedbackPending") {
            feedbackTries = 0
            presentPendingFeedback()
            return
        }
        guard let key = pendingMilestone else { return }
        if key.hasPrefix("book.") {
            presentPendingBookCard()
            return
        }
        pendingMilestone = nil
        showMilestone(key)
    }

    private var isEntitled: Bool {
        if PaymentHistory.sharedInstance.hasActivePurchase() { return true }
        if LegacyPaidAppService.shared.isLegacyPaidAppUser { return true }
        let paymentId = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
        let lower = paymentId.lowercased()
        if !lower.isEmpty && lower.contains("lifetime") { return true }
        let ids = [
            SUBSCRIPTIONID_LifeTime,
            SUBSCRIPTIONID_ExitOffer,
            FallbackIAPConstants.lifetimeProductID,
            FallbackIAPConstants.exitOfferProductID
        ]
        return ids.contains { !$0.isEmpty && $0.caseInsensitiveCompare(paymentId) == .orderedSame }
    }

    private var isBusy: Bool {
        guard let top = OnboardingAuthManager.topViewController() else { return true }
        if top.presentedViewController != nil { return true }
        let name = String(describing: type(of: top))
        if name.contains("Quiz") { return true }
        return false
    }

    private func showMilestone(_ key: String) {
        guard automaticRulesPass() else { return }
        guard !hasShown(key), !openingMilestones.contains(key) else { return }
        guard PaywallTriggerPresenter.canPresent(key) else {
            pendingMilestone = key
            return
        }
        openingMilestones.insert(key)
        presentCurrentPaywall(countsAsPopup: true, milestone: key, trigger: key)
    }

    private func automaticRulesPass() -> Bool {
        guard isEnabled, !isEntitled, !isBusy, !negativeThisSession else { return false }
        rememberInstallDate()
        let install = UserDefaults.standard.double(forKey: installKey)
        if Date().timeIntervalSince1970 - install < 10 * 60 { return false }
        if shownThisSession { return false }
        let last = UserDefaults.standard.double(forKey: lastPopupKey)
        if last > 0 && Date().timeIntervalSince1970 - last < 24 * 60 * 60 { return false }
        if blockedAfterRating() { return false }
        return true
    }

    private func blockedAfterRating() -> Bool {
        let last = UserDefaults.standard.double(forKey: lastRatingKey)
        return last > 0 && Date().timeIntervalSince1970 - last < 48 * 60 * 60
    }

    private func requestRatingIfEligible() {
        guard ratingIsEligible() else { return }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        UserDefaults.standard.set(version, forKey: ratingVersionKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastRatingKey)
        shownThisSession = true
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastPopupKey)
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func ratingIsEligible() -> Bool {
        guard isEnabled, !isBusy, !paywallShownThisSession, !negativeThisSession else { return false }
        rememberInstallDate()
        let install = UserDefaults.standard.double(forKey: installKey)
        if Date().timeIntervalSince1970 - install < 7 * 24 * 60 * 60 { return false }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if UserDefaults.standard.string(forKey: ratingVersionKey) == version { return false }
        let last = UserDefaults.standard.double(forKey: lastRatingKey)
        if last > 0 && Date().timeIntervalSince1970 - last < 90 * 24 * 60 * 60 { return false }
        return true
    }

    private func presentCurrentPaywall(countsAsPopup: Bool, milestone: String? = nil, trigger: String, onClose: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            guard let top = OnboardingAuthManager.topViewController() else {
                self.releaseMilestone(milestone)
                return
            }
            guard NetworkManager.sharedInstance.isConnectedToInternet() else {
                self.releaseMilestone(milestone)
                return
            }
            let name = trigger
            let userStarted = !countsAsPopup && milestone == nil
            guard PaywallTriggerPresenter.show(trigger: name, from: top, onClose: onClose, onPresented: { shown in
                guard userStarted else { return }
                // Start the cooldown only once the sheet is really on screen, so a refused present can be retried.
                if shown {
                    self.userCooldown[name] = Date()
                } else {
                    OnboardingAuthManager.topViewController()?.view.makeToast("Please try again", duration: 2.0, position: .top)
                }
            }) else {
                self.releaseMilestone(milestone)
                return
            }
            if name == "chatLimit" || name == "chatCredits" {
                AIUsageLimiter.shared.markChatUpsellShown()
            }
            if let milestone = milestone {
                self.markShown(milestone)
                self.openingMilestones.remove(milestone)
            }
            if countsAsPopup {
                self.shownThisSession = true
                self.paywallShownThisSession = true
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: self.lastPopupKey)
            } else {
                self.paywallShownThisSession = true
            }
        }
    }

    private func rememberInstallDate() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: installKey) == nil else { return }
        let alreadyUsing = (defaults.string(forKey: "AppOpenFirst") ?? "0") == "1"
        let start = alreadyUsing ? Date().addingTimeInterval(-8 * 24 * 60 * 60) : Date()
        defaults.set(start.timeIntervalSince1970, forKey: installKey)
    }

    private var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: Date())
    }

    private func savedImagesToday() -> Int {
        guard UserDefaults.standard.string(forKey: imageDayKey) == today else { return 0 }
        return UserDefaults.standard.integer(forKey: imageCountKey)
    }

    private func interstitialsToday() -> Int {
        guard UserDefaults.standard.string(forKey: adDayKey) == today else { return 0 }
        return UserDefaults.standard.integer(forKey: adCountKey)
    }

    private func releaseMilestone(_ key: String?) {
        guard let key = key else { return }
        openingMilestones.remove(key)
        pendingMilestone = key
    }

    private func hasShown(_ key: String) -> Bool {
        let shown = UserDefaults.standard.stringArray(forKey: shownKey) ?? []
        return shown.contains(key)
    }

    private func markShown(_ key: String) {
        var shown = UserDefaults.standard.stringArray(forKey: shownKey) ?? []
        guard !shown.contains(key) else { return }
        shown.append(key)
        UserDefaults.standard.set(shown, forKey: shownKey)
    }
}
