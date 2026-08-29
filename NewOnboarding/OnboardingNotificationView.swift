//
//  OnboardingNotificationView.swift
//  NKJV Bible
//

import SwiftUI
import UserNotifications

struct OnboardingNotificationView: View {
    @State private var navigateForward = false
    @State private var dailyVerseOn = true
    @State private var journeyReminderOn = true
    @State private var memoryChallengeOn = false
    @State private var prayerWallOn = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.darkPageGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer(minLength: geometry.size.height * 0.08)

                            OnboardingSerifTitle(
                                lines: ["Keep God's", "Word Close"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .leading
                            )
                            .padding(.horizontal, 26)

                            OnboardingLede(
                                text: "Two gentle reminders a day. Nothing more, unless you ask.",
                                onDark: true,
                                alignment: .leading
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 10)

                            VStack(spacing: 0) {
                                OnboardingToggleRow(
                                    title: "Your daily verse",
                                    detail: "7:00 AM",
                                    isOn: $dailyVerseOn
                                )
                                OnboardingToggleRow(
                                    title: "Journey reminder",
                                    detail: "8:00 PM · only if today isn't finished",
                                    isOn: $journeyReminderOn
                                )
                                OnboardingToggleRow(
                                    title: "Memory challenge",
                                    detail: "Off by default",
                                    isOn: $memoryChallengeOn
                                )
                                OnboardingToggleRow(
                                    title: "Prayer Wall activity",
                                    detail: "Off by default",
                                    isOn: $prayerWallOn,
                                    showDivider: false
                                )
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 8)

                            Spacer(minLength: 20)
                        }
                    }

                    OnboardingPrimaryButton(title: "Keep Me Rooted") {
                        requestNotificationsThenContinue()
                    }
                    .padding(.horizontal, 26)

                    OnboardingGhostButton(title: "Maybe Later") {
                        navigateForward = true
                    }
                    .padding(.horizontal, 26)

                    Spacer(minLength: max(geometry.safeAreaInsets.bottom, 34))
                }
            }
            .background(
                NavigationLink(
                    destination: Onboarding4(),
                    isActive: $navigateForward,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
        .navigationBarHidden(true)
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
