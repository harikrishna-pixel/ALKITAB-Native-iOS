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

        // Map daily verse → existing Shift 1 at 7:00 AM only (matches UI; avoids 4 blasts).
        defaults.set(dailyVerse || journey || memory || prayer ? "1" : "0", forKey: "NotifiStatue")
        defaults.set(dailyVerse, forKey: "Shift1ON")
        defaults.set(false, forKey: "Shift2ON")
        defaults.set(false, forKey: "Shift3ON")
        defaults.set(false, forKey: "Shift4ON")
        defaults.set("07:00", forKey: "Shift 1")
        defaults.set(1, forKey: "PerDay")

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    completion?()
                    return
                }
                UIApplication.shared.registerForRemoteNotifications()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    // Schedules Shift 1 verse locals when enabled (also clears pending first).
                    // Journey / memory / prayer are attached at end of onLoadNotificationContent.
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
}
