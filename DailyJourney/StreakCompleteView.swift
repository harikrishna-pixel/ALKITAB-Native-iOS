//
//  StreakCompleteView.swift
//  NKJV Bible
//

import SwiftUI

struct StreakCompleteView: View {
    @ObservedObject var store: DailyJourneyStore
    var onDone: () -> Void

    private var days: Int { max(store.streakCount, 1) }
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF9F0A").opacity(0.14))
                            .frame(width: 84, height: 84)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color(hex: "FF9F0A"))
                    }
                    .padding(.top, 12)

                    Text("Keep Your Streak")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)

                    Text("Read. Remember. Reflect. Watch your Scripture journey grow.")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black.opacity(0.5))
                        .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("\(days) Day Streak 🔥")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("View Calendar >")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                        }

                        HStack {
                            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                                let filled = isWeekdayFilled(at: index)
                                VStack(spacing: 8) {
                                    Text(day)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    ZStack {
                                        Circle()
                                            .fill(filled ? Color(hex: "34C759") : Color.white.opacity(0.12))
                                            .frame(width: 28, height: 28)
                                        if filled {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        Divider().background(Color.white.opacity(0.15))

                        VStack(alignment: .leading, spacing: 12) {
                            streakRow(icon: "book.fill", title: "Today's Verse", done: store.verseCompleted)
                            streakRow(icon: "brain.head.profile", title: "Memory Challenge", done: store.memoryCompleted)
                            streakRow(icon: "pencil", title: "Reflection", done: store.reflectionCompleted)
                            streakRow(icon: "flame.fill", title: "Streak Complete", done: store.allStepsComplete)
                        }

                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Text("\(days)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Days")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.65))
                            }
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "0B1B3A"))
                    )
                    .padding(.horizontal, 4)

                    if store.allStepsComplete {
                        HStack(spacing: 10) {
                            Text("🎉")
                            Text("Today's Journey Complete! You showed up for God's Word today.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "1B7A3D"))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "E8F8EE"))
                        .cornerRadius(16)
                    }
                }
                .padding(20)
            }

            Button(action: onDone) {
                Text("Back to Home")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(27)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func streakRow(icon: String, title: String, done: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(done ? Color(hex: "34C759") : Color.white.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: done ? "checkmark" : icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(done ? .white : .white.opacity(0.75))
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
    }

    /// Prefer locally saved streak days; fall back to count-from-today for older data.
    private func isWeekdayFilled(at displayIndex: Int) -> Bool {
        if let dayKey = store.dayKeyForWeekdayDisplayIndex(displayIndex),
           store.hasSavedStreak(on: dayKey) {
            return true
        }

        let calendar = Calendar.current
        let today = Date()
        let streakLength = min(days, 7)
        guard streakLength > 0 else { return false }

        for offset in 0..<streakLength {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear),
               weekdayDisplayIndex(for: date) == displayIndex {
                return true
            }
        }
        return false
    }

    /// Week row is Mon…Sun → 0…6
    private func weekdayDisplayIndex(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date) // 1=Sun … 7=Sat
        return weekday == 1 ? 6 : weekday - 2
    }
}
