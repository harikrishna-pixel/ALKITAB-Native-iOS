//
//  StreakCalendarView.swift
//  NKJV Bible
//

import SwiftUI

struct StreakCalendarView: View {
    @ObservedObject var store: DailyJourneyStore
    @State private var displayedMonth: Date = Date()

    /// Fixed Sun → Sat week order (calendar date aligned).
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    private let calendar = Calendar.current

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: displayedMonth)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                streakHeader

                VStack(spacing: 18) {
                    monthHeader

                    HStack {
                        ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                            Text(symbol)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.4))
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                        ForEach(monthDayItems) { item in
                            if let day = item.day {
                                dayCell(day: day, isStreakDay: item.isStreakDay, isToday: item.isToday)
                            } else {
                                Color.clear
                                    .frame(height: 36)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .navigationTitle("Streak Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var streakHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(hex: "FF9F0A"))
                    Text("\(max(store.streakCount, 1)) Day Streak")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Track your daily Scripture journey")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            VStack(spacing: 2) {
                Text("\(max(store.streakCount, 1))")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                Text("Days")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "0B1B3A"))
        )
    }

    private var monthHeader: some View {
        HStack {
            Button(action: { shiftMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "1C46B2"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "EEF1F7"))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text(monthTitle)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Button(action: { shiftMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "1C46B2"))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "EEF1F7"))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func dayCell(day: Int, isStreakDay: Bool, isToday: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isStreakDay ? Color(hex: "34C759") : Color(hex: "F3F5FA"))
                .frame(width: 36, height: 36)

            if isStreakDay {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(day)")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? Color(hex: "1C46B2") : Color.black.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
    }

    private func shiftMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = next
    }

    private var monthDayItems: [CalendarDayItem] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmpty = weekdayDisplayIndex(forWeekday: firstWeekday)

        var items: [CalendarDayItem] = Array(repeating: CalendarDayItem(day: nil, isStreakDay: false, isToday: false), count: leadingEmpty)

        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) else { continue }
            let dayKey = formattedDayKey(date)
            items.append(
                CalendarDayItem(
                    day: day,
                    isStreakDay: store.hasSavedStreak(on: dayKey),
                    isToday: calendar.isDateInToday(date)
                )
            )
        }

        return items
    }

    /// Week row is Sun…Sat → 0…6
    private func weekdayDisplayIndex(forWeekday weekday: Int) -> Int {
        weekday - 1
    }

    private func formattedDayKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

private struct CalendarDayItem: Identifiable {
    let id = UUID()
    let day: Int?
    let isStreakDay: Bool
    let isToday: Bool
}
