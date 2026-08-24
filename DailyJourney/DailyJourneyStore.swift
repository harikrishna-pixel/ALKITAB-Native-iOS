//
//  DailyJourneyStore.swift
//  NKJV Bible
//

import Foundation
import Combine

/// Day-scoped progress for Today's Journey (local only).
final class DailyJourneyStore: ObservableObject {

    static let shared = DailyJourneyStore()

    @Published private(set) var verseCompleted: Bool = false
    @Published private(set) var memoryCompleted: Bool = false
    @Published private(set) var reflectionCompleted: Bool = false
    @Published private(set) var streakCount: Int = 0
    /// Local calendar days (yyyy-MM-dd) when a full journey streak was earned.
    @Published private(set) var streakDates: [String] = []
    @Published var reflectionText: String = ""
    @Published var reflectionOptionIndex: Int? = nil
    @Published private(set) var savedMemory: MemoryChallengeSavedState? = nil

    private let verseKey = "DailyJourney.verseCompletedDate"
    private let memoryKey = "DailyJourney.memoryCompletedDate"
    private let reflectionKey = "DailyJourney.reflectionCompletedDate"
    private let streakCountKey = "DailyJourney.streakCount"
    private let streakLastDateKey = "DailyJourney.streakLastDate"
    private let streakDatesKey = "DailyJourney.streakDates"
    private let reflectionTextKey = "DailyJourney.reflectionText"
    private let reflectionTextDateKey = "DailyJourney.reflectionTextDate"
    private let reflectionOptionKey = "DailyJourney.reflectionOptionIndex"
    private let reflectionOptionDateKey = "DailyJourney.reflectionOptionDate"
    private let memoryStateKey = "DailyJourney.memoryState"
    private let memoryStateDateKey = "DailyJourney.memoryStateDate"

    private init() {
        reload()
    }

    var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    var completedCount: Int {
        [verseCompleted, memoryCompleted, reflectionCompleted, allStepsComplete].filter { $0 }.count
    }

    /// Journey list shows 4 items; streak row counts as complete when the other 3 are done.
    var allStepsComplete: Bool {
        verseCompleted && memoryCompleted && reflectionCompleted
    }

    var journeyProgressLabel: String {
        let done = [verseCompleted, memoryCompleted, reflectionCompleted].filter { $0 }.count
        let streakDone = allStepsComplete ? 1 : 0
        return "\(done + streakDone) of 4 complete"
    }

    func reload() {
        let today = todayKey
        let defaults = UserDefaults.standard
        verseCompleted = defaults.string(forKey: verseKey) == today
        memoryCompleted = defaults.string(forKey: memoryKey) == today
        reflectionCompleted = defaults.string(forKey: reflectionKey) == today

        var count = max(defaults.integer(forKey: streakCountKey), 0)
        var dates = defaults.stringArray(forKey: streakDatesKey) ?? []
        let last = defaults.string(forKey: streakLastDateKey)
        let yesterday = dateString(daysAgo: 1)

        // If the last saved streak day is older than yesterday, the streak is broken.
        if let last = last, last != today, last != yesterday, count > 0 {
            count = 0
            defaults.set(0, forKey: streakCountKey)
        }

        streakCount = count
        streakDates = dates.sorted()

        if defaults.string(forKey: reflectionTextDateKey) == today {
            reflectionText = defaults.string(forKey: reflectionTextKey) ?? ""
        } else {
            reflectionText = ""
        }

        if defaults.string(forKey: reflectionOptionDateKey) == today,
           defaults.object(forKey: reflectionOptionKey) != nil {
            reflectionOptionIndex = defaults.integer(forKey: reflectionOptionKey)
        } else {
            reflectionOptionIndex = nil
        }

        if defaults.string(forKey: memoryStateDateKey) == today,
           let data = defaults.data(forKey: memoryStateKey),
           let decoded = try? JSONDecoder().decode(MemoryChallengeSavedState.self, from: data) {
            savedMemory = decoded
        } else {
            savedMemory = nil
        }
    }

    /// Whether a full journey streak was saved for this calendar day.
    func hasSavedStreak(on dayKey: String) -> Bool {
        streakDates.contains(dayKey)
    }

    /// yyyy-MM-dd for a Mon…Sun display index (0…6) in the current week.
    func dayKeyForWeekdayDisplayIndex(_ displayIndex: Int) -> String? {
        let calendar = Calendar.current
        let today = Date()
        let todayIndex = weekdayDisplayIndex(for: today)
        let delta = displayIndex - todayIndex
        guard let date = calendar.date(byAdding: .day, value: delta, to: today) else { return nil }
        return formattedDayKey(date)
    }

    func markVerseCompleted() {
        guard !verseCompleted else { return }
        UserDefaults.standard.set(todayKey, forKey: verseKey)
        verseCompleted = true
        updateStreakIfNeeded()
    }

    func markMemoryCompleted(state: MemoryChallengeSavedState) {
        let defaults = UserDefaults.standard
        defaults.set(todayKey, forKey: memoryKey)
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: memoryStateKey)
            defaults.set(todayKey, forKey: memoryStateDateKey)
        }
        savedMemory = state
        memoryCompleted = true
        updateStreakIfNeeded()
    }

    func markReflectionCompleted(text: String, optionIndex: Int? = nil) {
        let defaults = UserDefaults.standard
        defaults.set(todayKey, forKey: reflectionKey)
        defaults.set(text, forKey: reflectionTextKey)
        defaults.set(todayKey, forKey: reflectionTextDateKey)
        if let optionIndex = optionIndex {
            defaults.set(optionIndex, forKey: reflectionOptionKey)
            defaults.set(todayKey, forKey: reflectionOptionDateKey)
            reflectionOptionIndex = optionIndex
        }
        reflectionText = text
        reflectionCompleted = true
        updateStreakIfNeeded()
    }

    private func updateStreakIfNeeded() {
        guard allStepsComplete else { return }
        let defaults = UserDefaults.standard
        let today = todayKey
        let last = defaults.string(forKey: streakLastDateKey)

        if last == today {
            // Still ensure today's date is recorded locally
            persistStreakDates(adding: today, defaults: defaults)
            return
        }

        if let last = last, let yesterday = dateString(daysAgo: 1), last == yesterday {
            streakCount = max(streakCount, 0) + 1
        } else {
            streakCount = 1
        }

        defaults.set(streakCount, forKey: streakCountKey)
        defaults.set(today, forKey: streakLastDateKey)
        persistStreakDates(adding: today, defaults: defaults)
        defaults.synchronize()
        objectWillChange.send()
    }

    private func persistStreakDates(adding today: String, defaults: UserDefaults) {
        var dates = defaults.stringArray(forKey: streakDatesKey) ?? streakDates
        // Backfill from count for older installs that only had streakCount.
        if dates.isEmpty, streakCount > 0 {
            for offset in 0..<min(streakCount, 90) {
                if let key = dateString(daysAgo: offset) {
                    dates.append(key)
                }
            }
        }
        if !dates.contains(today) {
            dates.append(today)
        }
        dates = Array(Set(dates)).sorted()
        if dates.count > 120 {
            dates = Array(dates.suffix(120))
        }
        defaults.set(dates, forKey: streakDatesKey)
        streakDates = dates
    }

    private func dateString(daysAgo: Int) -> String? {
        guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }
        return formattedDayKey(date)
    }

    private func formattedDayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    private func weekdayDisplayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date) // 1=Sun … 7=Sat
        return weekday == 1 ? 6 : weekday - 2
    }
}

struct MemoryChallengeSavedState: Codable {
    let displayTokens: [String]
    let blankIndices: [Int]
    let wordBank: [String]
    /// Blank token index → filled word
    let filled: [String: String]
}

struct DailyVerseSnapshot {
    let reference: String
    let text: String
    var imageName: String

    static func loadCurrent() -> DailyVerseSnapshot {
        NotificationList_data.sharedInstance.UpdateDailyVerse()
        let parts = DailyVerseLanguageConversion.sharedInstance.DailyVerseLAst().components(separatedBy: "_")
        let reference = parts.count >= 1 ? parts[0] : ""
        let text = parts.count >= 3 ? parts[2] : (parts.count >= 2 ? parts[1] : "")
        return DailyVerseSnapshot(
            reference: reference,
            text: text,
            imageName: HomeVerseImage
        )
    }

    /// Cycles wallpaper the same way as HomeController wallpaper list (S1…S8).
    mutating func cycleWallpaper(backward: Bool = false) {
        var index = 1
        let digits = imageName
            .replacingOccurrences(of: "S", with: "")
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".JPG", with: "")
        if let value = Int(digits) {
            index = value
        }
        let next: Int
        if backward {
            next = index <= 1 ? 8 : index - 1
        } else {
            next = index >= 8 ? 1 : index + 1
        }
        let name = "S\(next).jpg"
        imageName = name
        HomeVerseImage = name
    }
}

struct ContinueReadingSnapshot {
    let title: String
    let snippet: String
    let buttonTitle: String

    static func loadCurrent() -> ContinueReadingSnapshot {
        let book = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        let chapter = UserDefaults.standard.integer(forKey: "BookChapter")
        let chapterIndex = max(chapter - 1, 0)
        let verses = BibleContent.sharedInstance.AudioBibleList(selecterBookName: book, selectedId: chapterIndex)
        let snippet = verses.first ?? ""
        let isFirst = (UserDefaults.standard.string(forKey: "AppOpenFirst") ?? "0") == "0"
        return ContinueReadingSnapshot(
            title: "\(book) \(max(chapter, 1)) • Verse 1",
            snippet: snippet,
            buttonTitle: isFirst ? "Read" : "Continue"
        )
    }
}
