//
//  BibleSubscriptionView.swift
//  NKJV Bible
//
//  Created by Marberx Technologies on 12/11/25.
import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct BibleSubscriptionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager = StoreManager()
    @StateObject private var planSelection = PaywallPlanSelection()
    @State private var showLoader = false
    @State private var shouldNavigateToReader = false
    @State private var showCloseButton = true
    @State private var showExitOffer = false
    @State private var exitOfferTimeRemaining = 600 // 10 minutes in seconds
    @State private var exitOfferTimerTask: Task<Void, Never>?
    @State private var didSkipMissingPrices = false
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
        .onChange(of: storeManager.showAlert) { showing in
            if showing {
                showLoader = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Apple purchase sheet is on screen — hide the paywall loader.
            if showLoader {
                showLoader = false
            }
        }
        .onChange(of: storeManager.isLoading2) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.isLoading3) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.isLoading) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.hasProductLoadError) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.price2) { _ in skipPaywallIfMissingPrices() }
        .onChange(of: storeManager.price3) { _ in skipPaywallIfMissingPrices() }
        .onDisappear {
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
        }
    }
    
    private var paywallRoot: some View {
        ZStack {
            Color(hex: "061228").ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            
            GeometryReader { geo in
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
                        onPurchase: { handlePurchaseAction() },
                        onRestore: {
                            showLoader = true
                            storeManager.restorePurchases()
                        }
                    )
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(edges: .top)
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
        return p.isEmpty ? "—" : "\(p.cleanPrice()) / month"
    }
    
    private var yearlyPriceDisplay: String {
        let p = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        return p.isEmpty ? "—" : "\(p.cleanPrice()) / year"
    }
    
    private var lifetimePriceDisplay: String {
        let p = storeManager.price3.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag3") ?? "") : storeManager.price3
        return p.isEmpty ? "—" : p.cleanPrice()
    }
    
    private var yearlyPerMonthLine: String {
        let p = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        let stripped = p.strippedtext.replacingOccurrences(of: ",", with: "")
        guard let value = Double(stripped), value > 0 else { return "" }
        let monthly = value / 12.0
        let symbol = p.cleanPrice().prefix { !$0.isNumber && $0 != "." && $0 != "," }
        return String(format: "%@%.2f / month", String(symbol), monthly)
    }
    
    private var yearlySaveLine: String {
        let monthly = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
        let yearly = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
        let m = Double(monthly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        let y = Double(yearly.strippedtext.replacingOccurrences(of: ",", with: "")) ?? 0
        guard m > 0, y > 0, (m * 12) > y else { return "" }
        let save = Int(((m * 12) - y).rounded())
        let symbol = yearly.cleanPrice().prefix { !$0.isNumber && $0 != "." && $0 != "," }
        return "Save \(symbol)\(save)"
    }
    
    // MARK: - Setup StoreManager
    private func setupStoreManager() {
        storeManager.setupProducts()
        
        storeManager.onPurchaseSuccess = { [self] in
            showLoader = false
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
            showExitOffer = false
            clearExitOfferData() // Clear exit offer data on successful purchase
            
            // On iPad, give more time for StoreKit purchase sheet to dismiss
            // StoreKit purchase sheet is system-managed and needs time to dismiss
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            let delay = isIPad ? 2.0 : 0.8
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Double-check that we're on main thread and dismiss any SwiftUI sheets first
                DispatchQueue.main.async {
                    // Additional small delay to ensure purchase sheet is fully dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + (isIPad ? 0.5 : 0.2)) {
                        shouldNavigateToReader = true
                    }
                }
            }
        }
        
        storeManager.onPurchaseFailure = { [self] error in
            showLoader = false
        }
        
        storeManager.onRestoreSuccess = { [self] in
            showLoader = false
        }
        
        storeManager.onRestoreFailed = { [self] in
            showLoader = false
        }
    }

    /// Onboarding only: if Yearly + Lifetime prices never arrive, skip blank paywall.
    private func skipPaywallIfMissingPrices() {
        guard isPresentedFromOnboarding, !didSkipMissingPrices else { return }

        let yearly = storeManager.price2.isEmpty
            ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "")
            : storeManager.price2
        let lifetime = storeManager.price3.isEmpty
            ? (UserDefaults.standard.string(forKey: "PriceTag3") ?? "")
            : storeManager.price3
        guard yearly.isEmpty && lifetime.isEmpty else { return }

        let stillLoading = storeManager.isLoading || storeManager.isLoading2 || storeManager.isLoading3
        guard !stillLoading else { return }

        let offline = !NetworkManager.sharedInstance.isConnectedToInternet()
        guard offline || storeManager.hasProductLoadError else { return }

        didSkipMissingPrices = true
        print("⏭️ [BibleSubscriptionView] Skipping onboarding paywall — no Yearly/Lifetime prices available")
        handleCloseAction()
    }
    
    // MARK: - Handle Purchase Action
    private func handlePurchaseAction() {
        showLoader = true
        
        if planSelection.plan == .monthly {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_Six_month)
        } else if planSelection.plan == .yearly {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_OneYear)
        } else if planSelection.plan == .lifetime {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_LifeTime)
        }
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
    let onPurchase: () -> Void
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
            if isPad { Spacer(minLength: 8) }
        }
        .frame(maxWidth: isPad ? 720 : .infinity)
        .frame(maxWidth: .infinity, minHeight: geoSize.height, alignment: isPad ? .center : .top)
        .padding(.horizontal, isPad ? 48 : 0)
        .background(glowBackground, alignment: .top)
    }

    private var closeSpacer: some View {
        Color.clear
            .frame(height: 34)
            .padding(.horizontal, isPad ? 28 : 18)
            .padding(.top, topSafeInset + 8)
    }

    private var titleBlock: some View {
        VStack(spacing: isPad ? 4 : 2) {
            Text("Go Deeper").foregroundColor(.white)
            Text("in God's Word").foregroundColor(Color(hex: "F0C75E"))
        }
        .font(.system(size: isPad ? 36 : (isSmallDevice ? 26 : 30), weight: .bold, design: .serif))
        .multilineTextAlignment(.center)
        .shadow(color: Color.black.opacity(0.35), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 24)
        .padding(.top, isPad ? 8 : 28)
    }

    private var subtitleBlock: some View {
        VStack(spacing: 2) {
            Text("Powerful study tools to help you")
            Text("read, understand and grow.")
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
            Spacer(minLength: 20)
        } else {
            Color.clear.frame(height: isSmallDevice ? 72 : 88)
        }
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: isPad ? 12 : 8),
            GridItem(.flexible(), spacing: isPad ? 12 : 8),
            GridItem(.flexible(), spacing: isPad ? 12 : 8)
        ], spacing: isPad ? 12 : 8) {
            PaywallFeatureTile(systemIcon: "doc.text.magnifyingglass", iconColor: Color(hex: "4DA3FF"), title: "Unlimited AI Explanations")
            PaywallFeatureTile(systemIcon: "doc.plaintext", iconColor: Color(hex: "4CD964"), title: "Unlimited Chapter Summaries")
            PaywallFeatureTile(systemIcon: "bubble.left.and.bubble.right.fill", iconColor: Color(hex: "B07CFF"), title: "Ask Bible AI")
            PaywallFeatureTile(systemIcon: "gamecontroller.fill", iconColor: Color(hex: "FF9F0A"), title: "Unlimited Quiz Generation")
            PaywallFeatureTile(systemIcon: "nosign", iconColor: Color(hex: "FF453A"), title: "Ad-Free Reading")
            PaywallFeatureTile(systemIcon: "book.fill", iconColor: Color(hex: "64D2FF"), title: "Clean Reading Experience")
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

    private var trustRow: some View {
        HStack(spacing: 20) {
            Label("Cancel anytime", systemImage: "checkmark.shield.fill")
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
            .disabled(storeManager.isLoading)
        }
        .font(.system(size: isPad ? 13 : 12, weight: .medium))
        .foregroundColor(Color.white.opacity(0.7))
        .padding(.horizontal, 16)
        .padding(.bottom, isPad ? max(bottomInset, 16) + 8 : 24)
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
                .lineLimit(2)
                .minimumScaleFactor(0.75)
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

    private var ctaTitle: String {
        switch planSelection.plan {
        case .lifetime:
            return "Continue"
        case .monthly, .yearly:
            return "Start 3-Day Free Trial"
        }
    }

    private var ctaSubtitle: String {
        switch planSelection.plan {
        case .lifetime:
            return "One-time purchase • Lifetime access"
        case .yearly:
            let yearly = storeManager.price2.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag2") ?? "") : storeManager.price2
            return "Then \(yearly.isEmpty ? "—" : yearly.cleanPrice())/year. Auto-renews unless cancelled."
        case .monthly:
            let monthly = storeManager.price1.isEmpty ? (UserDefaults.standard.string(forKey: "PriceTag1") ?? "") : storeManager.price1
            return "Then \(monthly.isEmpty ? "—" : monthly.cleanPrice())/month. Auto-renews unless cancelled."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
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
                    planSelection: planSelection
                )
                PaywallPlanCardView(
                    style: .lifetime,
                    title: "Lifetime Study",
                    priceLine: lifetimePriceDisplay,
                    secondaryLine: "One-time payment",
                    tertiaryLine: "Ad-free reading only AI features use credits",
                    isLoading: storeManager.isLoading3,
                    planSelection: planSelection
                )
            }
            .padding(.horizontal, isPad ? 8 : 12)
            .padding(.top, isPad ? 4 : 2)
            .padding(.bottom, isPad ? 8 : 10)

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
            .disabled(storeManager.isLoading)

            Text(ctaSubtitle)
                .font(.system(size: isPad ? 13 : 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, isPad ? 10 : 8)
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
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                    }

                    if !tertiaryLine.isEmpty {
                        Text(tertiaryLine)
                            .font(.system(size: isPad ? 11 : 9, weight: .medium))
                            .foregroundColor(Color(hex: "6B6B6B"))
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
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
            if style == .yearly {
                Text("Best Value")
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

    /// Prefer live price; fall back to last cached StoreKit price for offline UI.
    private var displayPriceText: String {
        if !price.isEmpty { return price.cleanPrice() }
        if let cached = UserDefaults.standard.string(forKey: "PriceTag2"), !cached.isEmpty {
            return cached.cleanPrice()
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
            // Then original = discounted * 100 / (100 - discount)
            let originalValue = Int((numericValue / (100 - discount)) * 100)
            
            // Extract currency symbol by removing all digits, commas, dots, and spaces
            let symbol = price.replacingOccurrences(of: "[0-9,.]", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
            
            print("💰 [YearlyPlanCard] Price calculation: price=\(price), discount=\(discount)%, numeric=\(numericValue), original=\(originalValue)")
            print("💰 [YearlyPlanCard] Extracted symbol: '\(symbol)'")
            print("💰 [YearlyPlanCard] Strikeout price result: '\(symbol)\(originalValue)'")
            
            return "\(symbol)\(originalValue)"
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
                                Text(strikeoutPrice.cleanPrice())
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

    /// Prefer live price; fall back to last cached StoreKit price for offline UI.
    private var displayPriceText: String {
        if !price.isEmpty { return price.cleanPrice() }
        if let cached = UserDefaults.standard.string(forKey: "PriceTag3"), !cached.isEmpty {
            return cached.cleanPrice()
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
                        Text("\(discountedPrice.cleanPrice()) / year")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        if !originalPrice.isEmpty {
                            Text(originalPrice.cleanPrice())
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

#Preview {
    if #available(iOS 15.0, *) {
        BibleSubscriptionView()
    }
}
