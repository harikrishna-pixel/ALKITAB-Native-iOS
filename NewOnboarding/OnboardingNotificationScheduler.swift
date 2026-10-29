//
//  OnboardingNotificationScheduler.swift
//  NKJV Bible
//
//  Applies "Keep God's Word Close" toggles and schedules local notifications.
//

import Foundation
import UIKit
import UserNotifications

enum OnboardingNotificationScheduler {

    enum PrefKey {
        static let dailyVerse = "OnboardingNotif.dailyVerse"
        static let journey = "OnboardingNotif.journey"
        static let memory = "OnboardingNotif.memory"
        static let prayer = "OnboardingNotif.prayer"
        static let configured = "OnboardingNotif.configured"
        static let settingsTimesApplied = "OnboardingNotif.settingsTimesApplied"
    }

    private enum RequestID {
        static let journey = "onboarding.journey.reminder"
        static let memory = "onboarding.memory.reminder"
        static let prayer = "onboarding.prayer.reminder"
    }

    static var dailyVerseEnabled: Bool { UserDefaults.standard.bool(forKey: PrefKey.dailyVerse) }
    static var journeyEnabled: Bool { UserDefaults.standard.bool(forKey: PrefKey.journey) }
    static var memoryEnabled: Bool { UserDefaults.standard.bool(forKey: PrefKey.memory) }
    static var prayerEnabled: Bool { UserDefaults.standard.bool(forKey: PrefKey.prayer) }

    /// Persist toggles from the onboarding screen, then schedule.
    static func applyFromOnboarding(
        dailyVerse: Bool,
        journey: Bool,
        memory: Bool,
        prayer: Bool,
        completion: (() -> Void)? = nil
    ) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: PrefKey.configured)
        defaults.set(dailyVerse, forKey: PrefKey.dailyVerse)
        defaults.set(journey, forKey: PrefKey.journey)
        defaults.set(memory, forKey: PrefKey.memory)
        defaults.set(prayer, forKey: PrefKey.prayer)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    completion?()
                    return
                }
                // Permission allowed in onboarding → every Settings time stays on.
                enableAllSettingsTimes()
                defaults.set("07:00", forKey: "Shift 1")
                defaults.set(true, forKey: PrefKey.settingsTimesApplied)
                UIApplication.shared.registerForRemoteNotifications()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    // Schedules each Settings time (also clears pending first).
                    // Journey / memory / prayer are attached at end of onLoadNotificationContent.
                    appDelegate.onRegisterPushNotification()
                }
                completion?()
            }
        }
    }

    /// Morning, Evening, Night, and Quiz Time all on. Does not overwrite a time the user already set.
    static func enableAllSettingsTimes() {
        let defaults = UserDefaults.standard
        defaults.set("1", forKey: "NotifiStatue")
        defaults.set(true, forKey: "Shift1ON")
        defaults.set(true, forKey: "Shift2ON")
        defaults.set(true, forKey: "Shift3ON")
        defaults.set(true, forKey: "Shift4ON")
        defaults.set(4, forKey: "PerDay")
        if defaults.string(forKey: "Shift 1") == nil { defaults.set("07:00", forKey: "Shift 1") }
        if defaults.string(forKey: "Shift 2") == nil { defaults.set("16:00", forKey: "Shift 2") }
        if defaults.string(forKey: "Shift 3") == nil { defaults.set("20:00", forKey: "Shift 3") }
        if defaults.string(forKey: "Shift 4") == nil { defaults.set("14:00", forKey: "Shift 4") }
    }

    /// Onboarding already allowed notifications, but Settings was saved before every time was turned on.
    static func enableAllSettingsTimesIfAuthorized(completion: (() -> Void)? = nil) {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: PrefKey.configured) else {
            completion?()
            return
        }
        guard !defaults.bool(forKey: PrefKey.settingsTimesApplied) else {
            completion?()
            return
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let allowed: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                allowed = true
            default:
                allowed = false
            }
            DispatchQueue.main.async {
                guard allowed else {
                    completion?()
                    return
                }
                enableAllSettingsTimes()
                defaults.set(true, forKey: PrefKey.settingsTimesApplied)
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.onRegisterPushNotification()
                }
                completion?()
            }
        }
    }

    /// Re-evaluate journey / memory / prayer (call on become-active and when journey steps complete).
    static func refreshConditionalReminders() {
        guard UserDefaults.standard.bool(forKey: PrefKey.configured) else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            RequestID.journey, RequestID.memory, RequestID.prayer
        ])

        DailyJourneyStore.shared.reload()

        if journeyEnabled {
            scheduleNextFire(
                id: RequestID.journey,
                hour: 20,
                minute: 0,
                title: "Journey reminder",
                body: "Finish today’s Journey when you have a moment.",
                skipIf: { DailyJourneyStore.shared.allStepsComplete }
            )
        }

        if memoryEnabled {
            scheduleNextFire(
                id: RequestID.memory,
                hour: 10,
                minute: 0,
                title: "Memory challenge",
                body: "A short memory challenge is waiting in Daily Journey.",
                skipIf: { DailyJourneyStore.shared.memoryCompleted }
            )
        }

        if prayerEnabled {
            scheduleNextFire(
                id: RequestID.prayer,
                hour: 12,
                minute: 0,
                title: "Prayer Wall",
                body: "See how others are praying — and share yours.",
                skipIf: { false }
            )
        }
    }

    /// Schedules the next matching local time. If `skipIf` is true for today, uses tomorrow.
    private static func scheduleNextFire(
        id: String,
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        skipIf: () -> Bool
    ) {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard var fireDate = Calendar.current.date(from: components) else { return }
        let now = Date()
        if fireDate <= now || skipIf() {
            fireDate = Calendar.current.date(byAdding: .day, value: 1, to: fireDate) ?? fireDate
        }

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    /// Daily verse 7:00 AM is Morning. Evening nudge 8:00 PM is Night.
    /// A reminder left off only turns that Settings switch off. Permission is asked when one is on.
    static func applyChosenReminders(morning: Bool, evening: Bool, completion: (() -> Void)? = nil) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: PrefKey.configured)
        defaults.set(morning, forKey: PrefKey.dailyVerse)
        defaults.set(evening, forKey: PrefKey.journey)
        defaults.set(false, forKey: PrefKey.memory)
        defaults.set(false, forKey: PrefKey.prayer)
        let summary: String
        if morning && evening {
            summary = "Reminders: Daily verse · 7:00 AM + Evening nudge · 8:00 PM"
        } else if morning {
            summary = "Reminders: Daily verse · 7:00 AM"
        } else if evening {
            summary = "Reminders: Evening nudge · 8:00 PM"
        } else {
            summary = "Reminders off · turn on any time"
        }
        defaults.set(summary, forKey: OnboardingTheme.reminderSummaryKey)
        defaults.set(morning, forKey: "Shift1ON")
        defaults.set(evening, forKey: "Shift3ON")
        if morning { defaults.set("07:00", forKey: "Shift 1") }
        if evening { defaults.set("20:00", forKey: "Shift 3") }
        let enabledCount = ["Shift1ON", "Shift2ON", "Shift3ON", "Shift4ON"].filter { defaults.bool(forKey: $0) }.count
        defaults.set(enabledCount, forKey: "PerDay")
        defaults.set(enabledCount > 0 ? "1" : "0", forKey: "NotifiStatue")
        guard morning || evening else {
            completion?()
            return
        }
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            if granted {
                                Self.scheduleChosenReminders()
                            }
                            completion?()
                        }
                    }
                case .denied:
                    Self.showNotificationPermissionAlert(completion: completion)
                default:
                    Self.scheduleChosenReminders()
                    completion?()
                }
            }
        }
    }

    private static func scheduleChosenReminders() {
        UIApplication.shared.registerForRemoteNotifications()
        (UIApplication.shared.delegate as? AppDelegate)?.onRegisterPushNotification(clearSwitchesIfDenied: false)
    }

    private static func showNotificationPermissionAlert(completion: (() -> Void)?) {
        let alert = UIAlertController(
            title: "Alert!",
            message: "Turn on Notifications to Stay Connected.\nTap on Settings -> Bible app  -> Notifications",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            completion?()
        })
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            completion?()
            return
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        top.present(alert, animated: true)
    }
}
