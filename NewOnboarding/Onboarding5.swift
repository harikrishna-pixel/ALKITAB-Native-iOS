//
//  Onboarding5.swift
//  NKJV Bible
//

import SwiftUI
import UIKit
import SafariServices

struct Onboarding5: View {
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var todaysVerseDone = false
    @State private var memoryChallengeDone = false
    @State private var morningOn = false
    @State private var eveningOn = false
    @State private var notifyUnlocked = false
    @State private var navigateForward = false
    @State private var isSaving = false

    /// Index into `dayLabels` (Monday-first) for the day the user opens onboarding.
    private let todayIndex: Int = (Calendar.current.component(.weekday, from: Date()) + 5) % 7

    private var journeyItems: [(String, Bool)] {
        [
            ("Today's Verse", todaysVerseDone),
            ("Memory Challenge", memoryChallengeDone),
            ("Reflection", false)
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 0) {
                            OnboardingSerifTitle(
                                lines: ["Make It a", "Daily Habit"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 12)

                            OnboardingLede(
                                text: "Read. Remember. Reflect.\nChoose the reminders you want, or skip.",
                                onDark: true,
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            streakCard
                                .padding(.horizontal, 26)
                                .padding(.top, 18)

                            VStack(spacing: 0) {
                                ForEach(Array(journeyItems.enumerated()), id: \.offset) { index, item in
                                    journeyRow(title: item.0, done: item.1, showDivider: index > 0)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 10)

                            OnboardingToggleRow(
                                title: "Daily verse reminder",
                                detail: "7:00 AM",
                                isOn: morningBinding
                            )
                            .padding(.horizontal, 26)
                            OnboardingToggleRow(
                                title: "Evening nudge",
                                detail: "8:00 PM · only if today isn't finished",
                                isOn: eveningBinding,
                                showDivider: false
                            )
                            .padding(.horizontal, 26)

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryButton(title: "Get Notified", isEnabled: notifyUnlocked && !isSaving) {
                        isSaving = true
                        OnboardingNotificationScheduler.applyChosenReminders(morning: morningOn, evening: eveningOn) {
                            isSaving = false
                            navigateForward = true
                        }
                    }
                    .padding(.horizontal, 26)
                    OnboardingGhostButton(title: "Not Now") {
                        OnboardingNotificationScheduler.applyChosenReminders(morning: false, evening: false) {
                            navigateForward = true
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    .background(
                        NavigationLink(destination: OnboardingQuietTimeView(), isActive: $navigateForward) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            markOnboardingJourneyStepsCompleted()
            // Ticks appear one by one (first, then second).
            if !todaysVerseDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                        todaysVerseDone = true
                    }
                }
            }
            if !memoryChallengeDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                        memoryChallengeDone = true
                    }
                }
            }
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 4) {
                    Text("Day 1")
                    Image(systemName: "flame.fill")
                        .foregroundColor(OnboardingTheme.gold)
                }
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.white)
                Spacer()
                Text("This week")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(OnboardingTheme.dim)
            }

            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 7) {
                        Text(day)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(index == todayIndex ? .white : Color(hex: "7C93B8"))
                        Circle()
                            .fill(index == todayIndex ? OnboardingTheme.gold : Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(
                                        index == todayIndex ? OnboardingTheme.gold : Color.white.opacity(0.2),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 28, height: 28)
                            .shadow(color: index == todayIndex ? OnboardingTheme.gold.opacity(0.5) : .clear, radius: 9)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 18)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 19)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    /// The verse (Onboarding2) and memory challenge (Onboarding3) were just done in onboarding,
    /// so record them in Today's Journey for the streak.
    private func markOnboardingJourneyStepsCompleted() {
        let store = DailyJourneyStore.shared
        store.reload()
        store.markVerseCompleted()
        guard !store.memoryCompleted else { return }
        let tokens = OnboardingBibleVerse.tokens
        var filled: [String: String] = [:]
        for index in OnboardingBibleVerse.blankIndices where tokens.indices.contains(index) {
            filled[String(index)] = tokens[index]
        }
        store.markMemoryCompleted(state: MemoryChallengeSavedState(
            displayTokens: tokens,
            blankIndices: OnboardingBibleVerse.blankIndices,
            wordBank: OnboardingBibleVerse.options,
            filled: filled
        ))
    }

    private var morningBinding: Binding<Bool> {
        Binding(
            get: { morningOn },
            set: { newValue in
                morningOn = newValue
                if newValue { notifyUnlocked = true }
            }
        )
    }

    private var eveningBinding: Binding<Bool> {
        Binding(
            get: { eveningOn },
            set: { newValue in
                eveningOn = newValue
                if newValue { notifyUnlocked = true }
            }
        )
    }

    private func journeyRow(title: String, done: Bool, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 1)
            }
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "DCE7F8"))
                Spacer()
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(done ? OnboardingTheme.grow : Color(hex: "4C5F7E"))
                    .scaleEffect(done ? 1.0 : 0.85)
                    .opacity(done ? 1.0 : 0.9)
            }
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    Onboarding5()
}

struct OnboardingQuietTimeView: View {
    @State private var navigateForward = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            OnboardingEyebrow(text: "A month with God's Word")
                                .padding(.top, 16)
                            OnboardingSerifTitle(
                                lines: ["Picture Your", "Quiet Time"],
                                size: min(geometry.size.width * 0.08, 31),
                                onDark: false
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            OnboardingLede(text: "What daily reading can look like, without the noise.")
                                .padding(.horizontal, 32)
                                .padding(.top, 8)

                            HStack(alignment: .top, spacing: 10) {
                                quietColumn(
                                    image: "onboard_before",
                                    title: "BEFORE",
                                    lines: ["Ads between chapters", "Verses lost in a scroll", "Forgetting what you read"],
                                    highlighted: false
                                )
                                quietColumn(
                                    image: "onboard_after",
                                    title: "AFTER",
                                    lines: ["One quiet chapter a day", "Verses you can recall", "A streak you are proud of"],
                                    highlighted: true
                                )
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            VStack(spacing: 0) {
                                quietDay("onboard_day1", title: "Day 1", detail: "Your first verse, remembered")
                                quietDay("onboard_day7", title: "Day 7", detail: "A habit starts to form")
                                quietDay("onboard_day30", title: "Day 30", detail: "Verses you carry with you")
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 16)
                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryButton(title: "Start My 30 Days", onDark: false) {
                        navigateForward = true
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    .background(
                        NavigationLink(destination: OnboardingBridgeView(), isActive: $navigateForward) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func quietColumn(image: String, title: String, lines: [String], highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 92)
            Text(title)
                .font(.system(size: 10.5, weight: .heavy))
                .tracking(1.2)
                .foregroundColor(highlighted ? OnboardingTheme.primaryBlue : Color(hex: "6B7487"))
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(highlighted ? OnboardingTheme.paperInk : Color(hex: "6B7487"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(highlighted ? Color.white : Color(hex: "EEF1F6"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(highlighted ? OnboardingTheme.primaryBlue : Color(hex: "DCE3EE"), lineWidth: highlighted ? 1.5 : 1)
        )
    }

    private func quietDay(_ image: String, title: String, detail: String) -> some View {
        HStack(spacing: 13) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .frame(width: 42, height: 42)
                .background(Circle().fill(OnboardingTheme.growBg))
                .overlay(Circle().stroke(OnboardingTheme.growLine, lineWidth: 1.5))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(OnboardingTheme.paperInk)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(OnboardingTheme.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct OnboardingBridgeView: View {
    @State private var shown = 0
    @State private var ready = false
    @State private var navigateForward = false

    private var themeLine: String {
        let theme = UserDefaults.standard.string(forKey: OnboardingTheme.readThemeKey) ?? "light"
        if theme == "sepia" { return "Sepia theme saved" }
        if theme == "dark" { return "Dark theme saved" }
        return "Light theme saved"
    }

    private var reminderLine: String {
        UserDefaults.standard.string(forKey: OnboardingTheme.reminderSummaryKey) ?? "Reminders off · turn on any time"
    }

    private var rows: [(title: String, detail: String)] {
        [
            (themeLine, ""),
            ("First verse image", OnboardingBibleVerse.reference),
            ("First verse remembered", "Day 1 of your streak is ready"),
            (reminderLine, "")
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer(minLength: 12)
                    Text("✦")
                        .font(.system(size: 30))
                        .foregroundColor(OnboardingTheme.gold)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle().fill(OnboardingTheme.gold.opacity(0.18))
                        )
                    OnboardingSerifTitle(
                        lines: ready ? ["Your Pro Bible", "Is Ready"] : ["Setting Up", "Your Pro Bible"],
                        size: min(geometry.size.width * 0.08, 31)
                    )
                    .padding(.horizontal, 26)
                    .padding(.top, 12)
                    OnboardingLede(
                        text: ready ? "Unlock it once. Keep it for life." : "Putting your choices in place.",
                        onDark: true
                    )
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                            let on = index < shown
                            HStack(alignment: .center, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(on ? OnboardingTheme.grow : Color.clear)
                                    Circle()
                                        .stroke(on ? OnboardingTheme.grow : Color(hex: "4D6A9C"), lineWidth: 1.5)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 24, height: 24)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(row.title)
                                        .font(.system(size: 14.5, weight: .semibold))
                                        .foregroundColor(Color(hex: "DCE7F8"))
                                    if !row.detail.isEmpty {
                                        Text(row.detail)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(hex: "93A8C9"))
                                    }
                                }
                                Spacer()
                            }
                            .opacity(on ? 1 : 0.22)
                            .offset(y: on ? 0 : 6)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 22)
                    Spacer()

                    Button(action: { navigateForward = true }) {
                        Text(ready ? "Keep My Verse" : "Setting up…")
                            .font(.system(size: 16.5, weight: .bold))
                            .foregroundColor(OnboardingTheme.goldInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(RoundedRectangle(cornerRadius: 15).fill(ready ? OnboardingTheme.gold : Color(hex: "3F5578")))
                    }
                    .disabled(!ready)
                    .padding(.horizontal, 26)
                    .background(
                        NavigationLink(destination: OnboardingProPaywallView(), isActive: $navigateForward) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 28))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: playSetup)
    }

    private func playSetup() {
        shown = 0
        ready = false
        for index in 0..<rows.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(index) * 0.42) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    shown = index + 1
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(rows.count) * 0.42 + 0.25) {
            ready = true
        }
    }
}

struct OnboardingProPaywallView: View {
    @StateObject private var storeManager = StoreManager()
    @State private var showExit = false
    @State private var exitAlreadyShown = false
    private enum PurchaseWait { case lifetime, exit, restore }
    private enum LifetimePricePhase { case loading, ready, unavailable, retrying }
    @State private var purchaseWait: PurchaseWait?
    @State private var priceSheetWatcher = PriceSheetWatcher()
    @State private var didFinishPriceSetup = false
    @State private var isRetryingPrice = false

    private var lifetimePrice: String {
        let live = storeManager.price3.trimmingCharacters(in: .whitespacesAndNewlines)
        let cached = (UserDefaults.standard.string(forKey: "PriceTag3") ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let price = live.isEmpty ? cached : live
        return price.isEmpty ? "" : price.cleanPrice()
    }

    private var pricePhase: LifetimePricePhase {
        if !lifetimePrice.isEmpty { return .ready }
        let fetching = storeManager.isLoading1 || storeManager.isLoading2 || storeManager.isLoading3
        if isRetryingPrice { return fetching ? .retrying : .unavailable }
        if fetching { return .loading }
        if !didFinishPriceSetup && NetworkManager.sharedInstance.isConnectedToInternet() { return .loading }
        return .unavailable
    }

    private var exitPrice: String {
        let offer = storeManager.exitOfferPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        if !offer.isEmpty { return offer.cleanPrice() }
        return lifetimePrice.isEmpty ? "—" : lifetimePrice
    }

    private var showsStruckPrice: Bool {
        guard let full = priceAmount(lifetimePrice), let offer = priceAmount(exitPrice) else { return false }
        return full > offer
    }

    private var exitOfferLabel: String {
        guard showsStruckPrice, let full = priceAmount(lifetimePrice), let offer = priceAmount(exitPrice), full > 0 else {
            return "LIFETIME"
        }
        let percent = Int((((full - offer) / full) * 100).rounded())
        return percent > 0 ? "LIFETIME · \(percent)% OFF" : "LIFETIME"
    }

    private func priceAmount(_ text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: ",", with: "")
        let digits = cleaned.filter { $0.isNumber || $0 == "." }
        return Double(digits)
    }

    private func roundedRupee(_ text: String) -> String {
        guard let amount = priceAmount(text) else { return text }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let symbol = text.prefix { !$0.isNumber && $0 != "." && $0 != "," }
        let number = formatter.string(from: NSNumber(value: amount.rounded())) ?? "\(Int(amount.rounded()))"
        return "\(symbol)\(number)"
    }

    private func exitCheck(_ title: String) -> some View {
        HStack(spacing: 10) {
            Text("✓")
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(OnboardingTheme.grow)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "DCE7F8"))
        }
        .padding(.vertical, 7)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(hex: "F1F4FC"), Color(hex: "E6ECFA")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if !exitAlreadyShown {
                        Button(action: openExit) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "51607A"))
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Image("onboard_paywall_bible")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 86)
                            .padding(.top, 4)

                        Text("Grow Closer to God")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)

                        Text("Your Bible. Your quiet time. Yours for life.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "51607A"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)

                        Text("✓  You just remembered \(OnboardingBibleVerse.reference)")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(OnboardingTheme.grow)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(OnboardingTheme.growBg))
                            .overlay(Capsule().stroke(OnboardingTheme.growLine, lineWidth: 1))
                            .padding(.top, 12)

                        VStack(alignment: .leading, spacing: 11) {
                            benefit("nosign", "No Ads, Just Scripture")
                            benefit("headphones", "Read & Listen, Even Offline")
                            benefit("brain.head.profile", "Unlimited Verse Quizzes")
                            benefit("books.vertical", "Highlights, Notes & Verse Images")
                            benefit("flame.fill", "Streaks & Reading Reports")
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 8)

                        VStack(spacing: 8) {
                            Text("Lifetime Access")
                                .font(.system(size: 21, weight: .heavy))
                                .foregroundColor(.black)
                            lifetimePriceStatus
                                .frame(minHeight: 96)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 28)
                        .padding(.bottom, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(hex: "2844A8"), lineWidth: 2.5))
                        )
                        .overlay(
                            Text("Pay Once · Keep Forever")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color(hex: "A88A3E")))
                                .offset(y: -17),
                            alignment: .top
                        )
                        .padding(.top, 28)

                        Text("One-time purchase • No subscription • Yours forever")
                            .font(.system(size: 12.5))
                            .foregroundColor(Color(hex: "6B7487"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 22)
                }

                Button(action: lifetimeCTATapped) {
                    ZStack {
                        lifetimeCTALabel
                            .opacity(purchaseWait == .lifetime ? 0 : 1)
                        if purchaseWait == .lifetime {
                            SwiftUI.ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Capsule().fill(pricePhase == .loading || pricePhase == .retrying ? Color(hex: "C5D0E0") : Color(hex: "2844A8")))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(pricePhase == .loading || pricePhase == .retrying)
                .padding(.horizontal, 22)
                .padding(.top, 8)

                HStack(spacing: 18) {
                    legalButton("Terms of Use", url: TermsURL)
                    legalButton("Restore", url: nil)
                    legalButton("Privacy Policy", url: PrivacyURL)
                }
                .padding(.top, 10)
                .padding(.bottom, 16)
            }

            if showExit {
                exitOffer
            }

        }
        .navigationBarHidden(true)
        .onAppear(perform: setupStore)
        .onDisappear { priceSheetWatcher.stop() }
        .onChange(of: storeManager.showAlert) { isShown in
            if isShown { endPurchaseWait() }
        }
        .onChange(of: storeManager.price3) { value in
            if !value.isEmpty { isRetryingPrice = false }
        }
        .onChange(of: storeManager.isLoading3) { loading in
            if isRetryingPrice && !loading && lifetimePrice.isEmpty {
                isRetryingPrice = false
            }
        }
    }

    @ViewBuilder
    private var lifetimePriceStatus: some View {
        switch pricePhase {
        case .ready:
            VStack(spacing: 6) {
                Text(lifetimePrice)
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundColor(OnboardingTheme.primaryBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("Faith Without an Expiry Date")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "4B5563"))
            }
        case .loading:
            priceWaitStatus(title: "Getting your price...", subtitle: "Please wait a moment")
        case .retrying:
            priceWaitStatus(title: "Retrying...", subtitle: "Please wait a moment")
        case .unavailable:
            VStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(Color(hex: "607089"))
                Text("Price unavailable")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                Text("We couldn't load the purchase price.\nCheck your internet connection and try again.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8B95A7"))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func priceWaitStatus(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            SwiftUI.ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "8EA0BE")))
                .scaleEffect(1.15)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "1A1A1A"))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8B95A7"))
        }
    }

    @ViewBuilder
    private var lifetimeCTALabel: some View {
        switch pricePhase {
        case .loading, .retrying:
            Text("Loading price...")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
        case .unavailable:
            HStack(spacing: 8) {
                Text("Try Again")
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .bold))
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
        case .ready:
            Text("Grow With God Forever  →")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var exitOffer: some View {
        ZStack {
            OnboardingTheme.darkPageGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                Text("ONE-TIME OFFER")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.6)
                    .foregroundColor(OnboardingTheme.gold)
                OnboardingSerifTitle(lines: ["A Lower Price,", "Just This Once"], size: 31)
                    .padding(.top, 8)
                OnboardingLede(text: "Your Bible, ad-free and yours for life.", onDark: true)
                    .padding(.top, 8)
                VStack(spacing: 6) {
                    Text(exitOfferLabel)
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.6)
                        .foregroundColor(OnboardingTheme.gold)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if showsStruckPrice {
                            Text(roundedRupee(lifetimePrice))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "8AA0C2"))
                                .strikethrough(true, color: Color(hex: "8AA0C2"))
                                .lineLimit(1)
                        }
                        Text(roundedRupee(exitPrice))
                            .font(.system(size: 38, weight: .heavy))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Text("Pay once. No subscription. Yours forever.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "BFD2EC"))
                }
                .padding(22)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 18).fill(OnboardingTheme.gold.opacity(0.1)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(OnboardingTheme.gold, lineWidth: 1.5))
                .padding(.horizontal, 26)
                .padding(.top, 16)
                Text("This is a one-time offer. We will not show it again after you close this screen.")
                    .font(.system(size: 13))
                    .foregroundColor(OnboardingTheme.dim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 14)
                VStack(alignment: .leading, spacing: 0) {
                    exitCheck("No ads, ever")
                    exitCheck("Offline reading and audio")
                    exitCheck("Unlimited verse quizzes")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                .padding(.top, 8)
                Spacer()
                Button(action: buyExit) {
                    ZStack {
                        Text("Claim Lifetime for \(roundedRupee(exitPrice))")
                            .font(.system(size: 16.5, weight: .bold))
                            .foregroundColor(OnboardingTheme.goldInk)
                            .opacity(purchaseWait == .exit ? 0 : 1)
                        if purchaseWait == .exit {
                            SwiftUI.ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: OnboardingTheme.goldInk))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(RoundedRectangle(cornerRadius: 15).fill(OnboardingTheme.gold))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(purchaseWait != nil)
                .padding(.horizontal, 26)
                Button(action: { showExit = false }) {
                    Text("No thanks")
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundColor(Color(hex: "9DB4D8"))
                        .padding(.vertical, 12)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private func benefit(_ symbol: String, _ title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(OnboardingTheme.primaryBlue)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: Color.black.opacity(0.08), radius: 3, y: 1))
            Text(title)
                .font(.system(size: 15.5, weight: .medium))
                .foregroundColor(Color(hex: "111111"))
            Spacer()
        }
    }

    private func legalButton(_ title: String, url: String?) -> some View {
        Button(action: {
            if title == "Restore" {
                purchaseWait = .restore
                storeManager.restorePurchases(includeLegacyPaidDownload: true)
            } else if let url = url {
                openLegalPage(url)
            }
        }) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "51607A"))
                .frame(minHeight: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(title == "Restore" && purchaseWait != nil)
    }

    private func openLegalPage(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        guard let host = paywallHost() else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            host.view.makeToast("No internet connection", duration: 2.0, position: .top)
            return
        }
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .close
        host.present(safari, animated: true)
    }

    private func paywallHost() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first(where: { $0.isKeyWindow }) ?? scenes.flatMap { $0.windows }.first
        var controller = window?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        if let navigation = controller as? UINavigationController {
            return navigation.visibleViewController ?? navigation
        }
        return controller
    }

    private func openExit() {
        exitAlreadyShown = true
        showExit = true
    }

    private func lifetimeCTATapped() {
        switch pricePhase {
        case .ready:
            guard purchaseWait == nil else { return }
            buyLifetime()
        case .unavailable:
            retryLifetimePrice()
        case .loading, .retrying:
            break
        }
    }

    private func retryLifetimePrice() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else { return }
        isRetryingPrice = true
        storeManager.retryLifetimePrice()
        if !storeManager.isLoading3 {
            isRetryingPrice = false
        }
    }

    private func buyLifetime() {
        guard pricePhase == .ready else { return }
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            paywallHost()?.view.makeToast("Please check your internet connection and try again", duration: 2.0, position: .top)
            return
        }
        beginPurchase(SUBSCRIPTIONID_LifeTime, kind: .lifetime)
    }

    private func buyExit() {
        let id = SUBSCRIPTIONID_ExitOffer.isEmpty ? SUBSCRIPTIONID_LifeTime : SUBSCRIPTIONID_ExitOffer
        beginPurchase(id, kind: .exit)
    }

    /// Spinner stays inside the tapped button until Apple's price sheet is on screen.
    private func beginPurchase(_ productID: String, kind: PurchaseWait) {
        let before = PriceSheetWatcher.currentChrome()
        purchaseWait = kind
        storeManager.purchaseProduct(with: productID)
        guard purchaseWait != nil, !storeManager.showAlert else {
            endPurchaseWait()
            return
        }
        priceSheetWatcher.start(before: before) {
            purchaseWait = nil
        }
    }

    private func endPurchaseWait() {
        priceSheetWatcher.stop()
        purchaseWait = nil
    }

    private func setupStore() {
        storeManager.setupProducts()
        didFinishPriceSetup = true
        storeManager.onPurchaseSuccess = {
            endPurchaseWait()
            UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
            UIKitNavigationHelper.navigateToReaderViewController()
        }
        storeManager.onPurchaseFailure = { _ in
            endPurchaseWait()
        }
        storeManager.onRestoreSuccess = {
            endPurchaseWait()
            UserDefaults.standard.set(true, forKey: "PremiumPayViewed")
            UIKitNavigationHelper.navigateToReaderViewController()
        }
        storeManager.onRestoreFailed = {
            endPurchaseWait()
        }
    }
}

/// Notices when the App Store price sheet appears, then stops the paywall loader.
private final class PriceSheetWatcher {
    struct Chrome: Equatable {
        var windows: Set<ObjectIdentifier>
        var presented: Set<ObjectIdentifier>
    }

    private var timer: Timer?
    private var token: NSObjectProtocol?

    static func currentChrome() -> Chrome {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        var presented = Set<ObjectIdentifier>()
        for window in windows {
            var controller = window.rootViewController
            while let next = controller?.presentedViewController {
                presented.insert(ObjectIdentifier(next))
                controller = next
            }
        }
        return Chrome(windows: Set(windows.map { ObjectIdentifier($0) }), presented: presented)
    }

    func start(before: Chrome, onOpened: @escaping () -> Void) {
        stop()
        if Self.currentChrome() != before {
            onOpened()
            return
        }
        token = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeVisibleNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let window = note.object as? UIWindow else { return }
            guard !before.windows.contains(ObjectIdentifier(window)) else { return }
            self?.stop()
            onOpened()
        }
        var attempts = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
            attempts += 1
            guard let self = self else {
                timer.invalidate()
                return
            }
            if Self.currentChrome() != before {
                self.stop()
                onOpened()
            } else if attempts >= 40 {
                self.stop()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let token = token {
            NotificationCenter.default.removeObserver(token)
            self.token = nil
        }
    }
}

struct BeforeOnboarding5: View {
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var todaysVerseDone = false
    @State private var memoryChallengeDone = false

    private let todayIndex: Int = (Calendar.current.component(.weekday, from: Date()) + 5) % 7

    private var journeyItems: [(String, Bool)] {
        [
            ("Today's Verse", todaysVerseDone),
            ("Memory Challenge", memoryChallengeDone),
            ("Reflection", false)
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 0) {
                            OnboardingSerifTitle(
                                lines: ["Stay Rooted", "Every Day"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 12)

                            OnboardingLede(
                                text: "Read. Remember. Reflect.\nYour journey starts today.",
                                onDark: true,
                                alignment: .center
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            streakCard
                                .padding(.horizontal, 26)
                                .padding(.top, 18)

                            VStack(spacing: 0) {
                                ForEach(Array(journeyItems.enumerated()), id: \.offset) { index, item in
                                    journeyRow(title: item.0, done: item.1, showDivider: index > 0)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 10)

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryButton(title: "Build My Bible Habit") {
                        UIKitNavigationHelper.navigateToIAPView()
                    }
                    .padding(.horizontal, 26)

                    OnboardingPageDots(current: 4, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            markOnboardingJourneyStepsCompleted()
            if !todaysVerseDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                        todaysVerseDone = true
                    }
                }
            }
            if !memoryChallengeDone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                        memoryChallengeDone = true
                    }
                }
            }
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 4) {
                    Text("Day 1")
                    Image(systemName: "flame.fill")
                        .foregroundColor(OnboardingTheme.gold)
                }
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.white)
                Spacer()
                Text("This week")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(OnboardingTheme.dim)
            }

            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 7) {
                        Text(day)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(index == todayIndex ? .white : Color(hex: "7C93B8"))
                        Circle()
                            .fill(index == todayIndex ? OnboardingTheme.gold : Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(
                                        index == todayIndex ? OnboardingTheme.gold : Color.white.opacity(0.2),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 28, height: 28)
                            .shadow(color: index == todayIndex ? OnboardingTheme.gold.opacity(0.5) : .clear, radius: 9)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 18)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 19)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func markOnboardingJourneyStepsCompleted() {
        let store = DailyJourneyStore.shared
        store.reload()
        store.markVerseCompleted()
        guard !store.memoryCompleted else { return }
        let tokens = OnboardingBibleVerse.tokens
        var filled: [String: String] = [:]
        for index in OnboardingBibleVerse.blankIndices where tokens.indices.contains(index) {
            filled[String(index)] = tokens[index]
        }
        store.markMemoryCompleted(state: MemoryChallengeSavedState(
            displayTokens: tokens,
            blankIndices: OnboardingBibleVerse.blankIndices,
            wordBank: OnboardingBibleVerse.options,
            filled: filled
        ))
    }

    private func journeyRow(title: String, done: Bool, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(height: 1)
            }
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "DCE7F8"))
                Spacer()
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(done ? OnboardingTheme.grow : Color(hex: "4C5F7E"))
                    .scaleEffect(done ? 1.0 : 0.85)
                    .opacity(done ? 1.0 : 0.9)
            }
            .padding(.vertical, 14)
        }
    }
}
