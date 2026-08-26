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
    
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showLoader = false
    @State private var shouldNavigateToReader = false
    @State private var showCloseButton = false
    @State private var showExitOffer = false
    @State private var exitOfferTimeRemaining = 600 // 10 minutes in seconds
    @State private var exitOfferTimerTask: Task<Void, Never>?
    // FIXED: Parameters for navigation behavior
    var isPresentedFromOnboarding: Bool = true
    var dismissHandler: (() -> Void)?  // ADDED: For UIKit dismiss
    var onDismissToReader: (() -> Void)?
    
    private let screenHeight = UIScreen.main.bounds.height
    private var isSmallDevice: Bool {
        screenHeight < 700
    }
    
    // MARK: - UserDefaults Keys for Exit Offer
    private let exitOfferStartTimeKey = "ExitOfferStartTime"
    private let exitOfferTimeRemainingKey = "ExitOfferTimeRemaining"
    private let exitOfferExpiredKey = "ExitOfferExpired"
    private let exitOfferFirstInstallShownKey = "ExitOfferFirstInstallShown"
    private let exitOfferTimerDuration = 600 // 10 minutes in seconds
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FFFFFF"), Color(hex: "E8EEFF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Header with Close Button
                    
                    ZStack{
                        Image("bible_with_sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                          
                            .edgesIgnoringSafeArea(.top)
                        // MARK: - Close Button (Commented out - may be used later)
                        
                        if showCloseButton {
                                     HStack {
                                         Spacer()
                                         Button(action: {
                                             // Try to sync exit offer price from shared instance if local is empty
                                             if storeManager.exitOfferPrice.isEmpty && StoreManager.shared.isExitOfferProductLoaded {
                                                 storeManager.exitOfferPrice = StoreManager.shared.exitOfferPrice
                                                 storeManager.exitOfferOriginalPrice = StoreManager.shared.exitOfferOriginalPrice
                                                 storeManager.isExitOfferProductLoaded = true
                                                 print("🔄 [BibleSubscriptionView] Synced exit offer price from shared instance")
                                             }
                                             
                                             // Check if we should show exit offer
                                             if shouldShowExitOffer() {
                                                 // Ensure start time is saved (timer may have started in background)
                                                 if UserDefaults.standard.object(forKey: exitOfferStartTimeKey) == nil {
                                                     saveExitOfferStartTime()
                                                 }
                                                 // Get current remaining time (timer continues running)
                                                 exitOfferTimeRemaining = getRemainingTime()
                                                 
                                                 // Only show exit offer if time hasn't expired
                                                 if exitOfferTimeRemaining > 0 {
                                                     withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                         showExitOffer = true
                                                     }
                                                     handleCloseAction()
//                                                     startExitOfferTimer()
                                                 } else {
                                                     // Time expired, just close
                                                     clearExitOfferData()
                                                     handleCloseAction()
                                                 }
                                             } else {
                                                 // Exit offer not available, just close (no error shown)
                                                 print("🔒 [BibleSubscriptionView] Exit offer not available, closing IAP")
                                                 handleCloseAction()
                                             }
                                         }) {
                                             Image(systemName: "xmark")
                                                 .font(.system(size: 14, weight: .semibold))
                                                 .foregroundColor(Color(hex: "333333"))
                                                 .frame(width: 32, height: 32)
                                                 .background(Color.black.opacity(0.08))
                                                 .clipShape(Circle())
                                         }
                                         .padding(.trailing, 20)
                                     }
                                     .transition(.opacity)
                                 }
                        
                        
                    }
                
                    
                    // MARK: - Title
                    Text("Let God's Word Guide Every Day")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                    
                    // MARK: - Features List
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(iconName: "no_ads_icon", text: "Focus on God's voice - no ads, no noise")
                        FeatureRow(iconName: "daily_verses_icon", text: "Daily Verses that uplift and guide you")
                        FeatureRow(iconName: "bible_library_icon", text: "Your Personal Bible Library")
                        FeatureRow(iconName: "quiz_icon", text: "Challenge Your Faith with Bible Quizzes")
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)
                    
                    // MARK: - Divider
                    HStack(spacing: 10) {
                        Rectangle()
                            .fill(Color(red: 0.7, green: 0.7, blue: 0.7))
                            .frame(height: 1)
                        
                        Text("Choose Your Faith Plan")
                            .font(.system(size: 15))
                            .italic()
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            .fixedSize()
                        
                        Rectangle()
                            .fill(Color(red: 0.7, green: 0.7, blue: 0.7))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    
                    // MARK: - Subscription Plans
                    VStack(spacing: 12) {
                        YearlyPlanCard(
                            price: storeManager.price2,
                            originalPrice: storeManager.originalPrice2,
                            isSelected: selectedPlan == .yearly,
                            isLoading: storeManager.isLoading2,
                            isSmallDevice: isSmallDevice,
                            showOffer: offer_enabled == "1",
                            action: {
                                selectedPlan = .yearly
                            }
                        )
                        
                        LifetimePlanCard(
                            price: storeManager.price3,
                            originalPrice: storeManager.originalPrice3,
                            isSelected: selectedPlan == .lifetime,
                            isLoading: storeManager.isLoading3,
                            isSmallDevice: isSmallDevice,
                            showOffer: offer_enabled == "1",
                            action: {
                                selectedPlan = .lifetime
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    // MARK: - Fine Print
                    Text(selectedPlan == .lifetime ? "One-time purchase • Lifetime access" : "No hidden charges • Renew manually • Cancel anytime")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .padding(.bottom, 10)
                    
                    // MARK: - CTA Button
                    Button(action: {
                        handlePurchaseAction()
                    }) {
                        HStack(spacing: 8) {
//                            Text(selectedPlan == .yearly ? "Start My Free Trial" : "Get Lifetime Access")
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1C46B2"))
                        .cornerRadius(27)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .disabled(storeManager.isLoading)
                    
                    // MARK: - Continue with Free Version Button
                    Button(action: {
                        // Try to sync exit offer price from shared instance if local is empty
                        if storeManager.exitOfferPrice.isEmpty && StoreManager.shared.isExitOfferProductLoaded {
                            storeManager.exitOfferPrice = StoreManager.shared.exitOfferPrice
                            storeManager.exitOfferOriginalPrice = StoreManager.shared.exitOfferOriginalPrice
                            storeManager.isExitOfferProductLoaded = true
                            print("🔄 [BibleSubscriptionView] Synced exit offer price from shared instance")
                        }
                        
                        // Check if we should show exit offer
                        if shouldShowExitOffer() {
                            // Ensure start time is saved (timer may have started in background)
                            if UserDefaults.standard.object(forKey: exitOfferStartTimeKey) == nil {
                                saveExitOfferStartTime()
                            }
                            // Get current remaining time (timer continues running)
                            exitOfferTimeRemaining = getRemainingTime()
                            
                            // Only show exit offer if time hasn't expired
                            if exitOfferTimeRemaining > 0 {
//                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                                    showExitOffer = true
//                                }
//                                startExitOfferTimer()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    handleCloseAction()
                                }
                                
                            } else {
                                // Time expired, just close
                                clearExitOfferData()
                                handleCloseAction()
                            }
                        } else {
                            // Exit offer not available, just close (no error shown)
                            print("🔒 [BibleSubscriptionView] Exit offer not available, closing IAP")
                            handleCloseAction()
                        }
                    }) {
                        Text("Continue Free Version")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.5))
                            //.underline()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // MARK: - Footer Links
                    HStack(spacing: 0) {
                        Button("Terms of Use") {
                            storeManager.openTerms()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        
                        Spacer()
                        
                        Button("Restore") {
                            showLoader = true
                            storeManager.restorePurchases()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .disabled(storeManager.isLoading)
                        
                        Spacer()
                        
                        Button("Privacy Policy") {
                            storeManager.openPrivacy()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
                }
            }
            
            // MARK: - Loader Overlay
            if showLoader || storeManager.isLoading {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Text("Processing...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            
            // MARK: - Exit Offer Modal
            // Only show exit offer if prices are available (shouldShowExitOffer already checks this)
            if showExitOffer && !storeManager.exitOfferPrice.isEmpty && !storeManager.exitOfferOriginalPrice.isEmpty {
//                handleCloseAction()
//                ExitOfferView(
//                    originalPrice: storeManager.exitOfferOriginalPrice,
//                    discountedPrice: storeManager.exitOfferPrice,
//                    discountText: storeManager.exitOfferDiscountText,
//                    planText: storeManager.exitOfferPlanText,
//                    timeRemaining: exitOfferTimeRemaining,
//                    hasError: false, // We only show if prices are available
//                    onPurchase: {
//                        print("💳 [BibleSubscriptionView] Exit offer CTA tapped")
//                        print("   → Exit offer product ID: '\(SUBSCRIPTIONID_ExitOffer)'")
//                        print("   → Exit offer product loaded: \(storeManager.isExitOfferProductLoaded)")
//                        print("   → Exit offer price: '\(storeManager.exitOfferPrice)'")
//                        
//                        // FIXED: Verify product is actually available before attempting purchase
//                        // Sync from shared instance if needed
//                        storeManager.syncExitOfferProductIfNeeded()
//                        
//                        // Check if product is available after syncing
//                        if !storeManager.isExitOfferProductAvailable {
//                            print("   ❌ Exit offer product is still not available after sync, cannot purchase")
//                            storeManager.showAlert(title: "Product Not Ready", message: "Please wait a moment and try again.")
//                            return
//                        }
//                        
//                        print("   ✅ Exit offer product verified, proceeding with purchase")
//                        showLoader = true
//                        storeManager.purchaseProduct(with: SUBSCRIPTIONID_ExitOffer)
//                    },
//                    onDismiss: {
//                        // Timer continues in background - start time is already saved
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                            showExitOffer = false
//                        }
//                        exitOfferTimerTask?.cancel()
//                        exitOfferTimerTask = nil
//                        handleCloseAction()
//                    }
//                )
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .zIndex(1000)
            }
            
        }
        .navigationBarHidden(true)
        
        .onAppear {
              // Delay showing close button
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                  withAnimation(.easeInOut(duration: 0.2)) {
                      showCloseButton = true
                  }
              }
              
              setupStoreManager()
              
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
        .onDisappear {
            exitOfferTimerTask?.cancel()
            exitOfferTimerTask = nil
        }
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
    
    // MARK: - Handle Purchase Action
    private func handlePurchaseAction() {
        showLoader = true
        
        if selectedPlan == .yearly {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_OneYear)
        } else if selectedPlan == .lifetime {
            storeManager.purchaseProduct(with: SUBSCRIPTIONID_LifeTime)
        }
    }
    
    // MARK: - Handle Close Action
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

// Supporting views remain the same...
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
                    
                    if isLoading {
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
                            
                            // Current discounted price
                            Text(price.cleanPrice())
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
                
                if isLoading {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        .scaleEffect(1.2)
                } else {
                    VStack(spacing: 2) {
                       
                        Text(price.cleanPrice())
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




enum SubscriptionPlan {
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
