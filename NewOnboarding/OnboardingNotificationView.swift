//
//  OnboardingNotificationView.swift
//  NKJV Bible
//

import SwiftUI
import UserNotifications

struct OnboardingNotificationView: View {
    @State private var navigateForward = false

    /// Dark navy/violet card (matches attached UI)
    private let cardBackground = Color(hex: "0B1B3A")
    private let screenBackground = Color(hex: "E8EEFF")

    var body: some View {
        GeometryReader { _ in
            ZStack {
                screenBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            OnboardingTheme.primaryBlue.opacity(0.95),
                                            OnboardingTheme.primaryBlue
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 42
                                    )
                                )
                                .frame(width: 84, height: 84)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                        }

                        Text("Keep God's Word Close")
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Text("Get your daily verse and gentle reminders to keep your Bible journey going.")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 8)

                        VStack(alignment: .leading, spacing: 12) {
                            check("Daily Verse")
                            check("Memory Challenge Reminders")
                            check("Reading Progress")
                            check("Streak Reminders")
                        }
                        .padding(.top, 8)

                        OnboardingPrimaryButton(title: "Keep Me Rooted") {
                            requestNotificationsThenContinue()
                        }
                        .padding(.top, 8)

                        NavigationLink(destination: Onboarding4()) {
                            Text("Maybe Later")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(cardBackground)
                            .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(screenBackground.ignoresSafeArea())
        }
        .background(screenBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: Onboarding4(),
                isActive: $navigateForward,
                label: { EmptyView() }
            )
            .hidden()
        )
    }

    private func check(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(OnboardingTheme.primaryBlue)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
    }

    private func requestNotificationsThenContinue() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    enableAllNotificationShifts()
                    UIApplication.shared.registerForRemoteNotifications()
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.onRegisterPushNotification()
                    }
                }
                navigateForward = true
            }
        }
    }

    private func enableAllNotificationShifts() {
        UserDefaults.standard.set("1", forKey: "NotifiStatue")
        UserDefaults.standard.setValue(4, forKey: "PerDay")
        UserDefaults.standard.setValue(true, forKey: "Shift1ON")
        UserDefaults.standard.setValue(true, forKey: "Shift2ON")
        UserDefaults.standard.setValue(true, forKey: "Shift3ON")
        UserDefaults.standard.setValue(true, forKey: "Shift4ON")

        if UserDefaults.standard.string(forKey: "Shift 1") == nil {
            UserDefaults.standard.set("08:00", forKey: "Shift 1")
        }
        if UserDefaults.standard.string(forKey: "Shift 2") == nil {
            UserDefaults.standard.set("16:00", forKey: "Shift 2")
        }
        if UserDefaults.standard.string(forKey: "Shift 3") == nil {
            UserDefaults.standard.set("20:00", forKey: "Shift 3")
        }
        if UserDefaults.standard.string(forKey: "Shift 4") == nil {
            UserDefaults.standard.set("14:00", forKey: "Shift 4")
        }
    }
}

#Preview {
    OnboardingNotificationView()
}
