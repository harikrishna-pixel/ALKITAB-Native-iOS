                                                                                                                                                        //
//  StreakCalendarView.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct StreakCalendarView: View {
    @ObservedObject var store: DailyJourneyStore
    @State private var displayedMonth: Date = Date()
    @State private var reviewRecord: DailyJourneyDayRecord?

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
                                dayCell(day: day, dayKey: item.dayKey, isStreakDay: item.isStreakDay, isToday: item.isToday)
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
        .background(
            NavigationLink(
                destination: CompletedStreakFlowView(record: reviewRecord ?? DailyJourneyDayRecord()),
                isActive: Binding(
                    get: { reviewRecord != nil },
                    set: { if !$0 { reviewRecord = nil } }
                ),
                label: { EmptyView() }
            )
            .hidden()
        )
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

    private func dayCell(day: Int, dayKey: String?, isStreakDay: Bool, isToday: Bool) -> some View {
        let cell = ZStack {
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

        return Group {
            if isStreakDay, let dayKey = dayKey {
                Button(action: { openCompletedDay(dayKey) }) {
                    cell
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cell
            }
        }
    }

    private func openCompletedDay(_ dayKey: String) {
        guard let record = store.dayRecord(for: dayKey) else { return }
        reviewRecord = record
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

        var items: [CalendarDayItem] = Array(repeating: CalendarDayItem(day: nil, dayKey: nil, isStreakDay: false, isToday: false), count: leadingEmpty)

        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) else { continue }
            let dayKey = formattedDayKey(date)
            items.append(
                CalendarDayItem(
                    day: day,
                    dayKey: dayKey,
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
    let dayKey: String?
    let isStreakDay: Bool
    let isToday: Bool
}

/// Read-only Today's Verse → Memory Challenge → Reflection for a completed streak day.
private struct CompletedStreakFlowView: View {
    let record: DailyJourneyDayRecord
    @Environment(\.presentationMode) private var presentationMode
    @State private var step = 0

    private var verse: DailyVerseSnapshot {
        DailyVerseSnapshot(
            reference: record.verseReference,
            text: record.verseText,
            imageName: record.verseImageName.isEmpty ? HomeVerseImage : record.verseImageName
        )
    }

    var body: some View {
        Group {
            if step == 0 {
                CompletedStreakVerseView(
                    record: record,
                    onBack: { presentationMode.wrappedValue.dismiss() },
                    onContinue: { step = 1 }
                )
            } else if step == 1 {
                MemoryChallengeView(
                    verse: verse,
                    store: .shared,
                    isLockedReview: true,
                    lockedReview: record.memory,
                    onDone: { presentationMode.wrappedValue.dismiss() },
                    onProceed: { step = 2 }
                )
            } else {
                ReflectionView(
                    verse: verse,
                    store: .shared,
                    isLockedReview: true,
                    lockedText: record.reflectionText,
                    lockedOption: record.reflectionOptionIndex,
                    onDone: { presentationMode.wrappedValue.dismiss() }
                )
            }
        }
        .navigationBarHidden(step == 0)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { step = max(step - 1, 0) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
}

private struct CompletedStreakVerseView: View {
    let record: DailyJourneyDayRecord
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if let image = UIImage(named: record.verseImageName), !record.verseImageName.isEmpty {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1C46B2"), Color(hex: "0B1B3A")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()

                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.42), Color.black.opacity(0.38), Color.black.opacity(0.55)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                VStack(spacing: 0) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.40))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 8)

                    Spacer()

                    VStack(alignment: .center, spacing: 16) {
                        Text(record.verseReference.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Rectangle()
                            .fill(Color.white.opacity(0.85))
                            .frame(width: 28, height: 1.5)
                        Text(record.verseText.isEmpty ? "This day's verse wasn't saved." : record.verseText)
                            .font(.system(size: 22, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)

                    Spacer()

                    Button(action: onContinue) {
                        Text("Memory Challenge")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "1C46B2"))
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 28)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
}
