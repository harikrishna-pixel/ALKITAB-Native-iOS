//
//  StreakCompleteView.swift
//  NKJV Bible
//

import SwiftUI

struct StreakCompleteView: View {
    @ObservedObject var store: DailyJourneyStore
    var onDone: () -> Void

    @State private var showCalendar = false

    private var days: Int { max(store.streakCount, 1) }
    /// Fixed Sun → Sat week order (calendar date aligned).
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF6A00").opacity(0.16))
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "FF6A00").opacity(0.45), lineWidth: 1.5)
                            )
                        StreakFlameGif(animates: store.allStepsComplete)
                            .frame(width: 32, height: 32)
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .padding(.top, 28)

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
                            Button(action: { showCalendar = true }) {
                                Text("View Calendar >")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.65))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        HStack {
                            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                                let filled = isWeekdayFilled(at: index)
                                let isToday = isCurrentWeekday(at: index)
                                VStack(spacing: 8) {
                                    Text(day)
                                        .font(.system(size: 11, weight: isToday ? .bold : .medium))
                                        .foregroundColor(isToday ? .white : .white.opacity(0.7))
                                    ZStack {
                                        Circle()
                                            .fill(filled ? Color(hex: "34C759") : Color.white.opacity(0.12))
                                            .frame(width: 28, height: 28)
                                        // In-progress today: outer ring (before completion).
                                        if isToday && !filled {
                                            Circle()
                                                .stroke(Color(hex: "FF9F0A"), lineWidth: 2.5)
                                                .frame(width: 28, height: 28)
                                        }
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
                        }
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
        .onAppear {
            // Refresh day-scoped flags so a new day starts unchecked until activities are completed.
            store.reload()
        }
        .background(
            NavigationLink(
                destination: StreakCalendarView(store: store),
                isActive: $showCalendar,
                label: { EmptyView() }
            )
            .hidden()
        )
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

    /// Only mark days that were actually saved as completed streak days (never invent today's mark).
    private func isWeekdayFilled(at displayIndex: Int) -> Bool {
        guard let dayKey = store.dayKeyForWeekdayDisplayIndex(displayIndex) else { return false }
        return store.hasSavedStreak(on: dayKey)
    }

    /// Sun…Sat index for today (display only).
    private func isCurrentWeekday(at displayIndex: Int) -> Bool {
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        return displayIndex == todayIndex
    }
}

/// Same NKJV streak flame. Still image until today's streak is complete, then it burns.
private struct StreakFlameGif: UIViewRepresentable {
    var animates: Bool

    func makeUIView(context: Context) -> StreakFlameHost {
        let view = StreakFlameHost()
        view.setAnimating(animates)
        return view
    }

    func updateUIView(_ uiView: StreakFlameHost, context: Context) {
        uiView.setAnimating(animates)
    }
}

private final class StreakFlameHost: UIView {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        addSubview(imageView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private static let animatedFlame = UIImage.gifImageWithName("streak_flame")
    private static let stillFlame = animatedFlame?.images?.first ?? animatedFlame

    func setAnimating(_ animates: Bool) {
        imageView.image = animates ? Self.animatedFlame : Self.stillFlame
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 32, height: 32)
    }
}
