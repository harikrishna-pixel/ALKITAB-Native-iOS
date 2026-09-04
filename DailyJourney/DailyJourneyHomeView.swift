//
//  DailyJourneyHomeView.swift
//  NKJV Bible
//

import SwiftUI

struct DailyJourneyHomeView: View {
    @ObservedObject var store: DailyJourneyStore
    @State private var verse: DailyVerseSnapshot
    @State private var continueReading: ContinueReadingSnapshot
    @State private var prayerCount: Int = 0
    @State private var showMemory = false
    @State private var showReflection = false
    @State private var showStreak = false
    @State private var showCalendar = false
    @State private var didAutoPresentStreak = false
    @State private var isVerseImageSaved = false

    var onContinueReading: () -> Void
    var onOpenPrayerWall: () -> Void
    var onShareVerse: (DailyVerseSnapshot) -> Void
    var onBookmarkVerse: (DailyVerseSnapshot, @escaping (Bool) -> Void) -> Void
    var onOpenVerseFullscreen: (DailyVerseSnapshot, @escaping (DailyVerseSnapshot) -> Void) -> Void
    var onOpenMemoryChallenge: (DailyVerseSnapshot) -> Void
    var onOpenReflection: (DailyVerseSnapshot) -> Void
    var onPresentStreakComplete: () -> Void

    init(
        store: DailyJourneyStore = .shared,
        onContinueReading: @escaping () -> Void,
        onOpenPrayerWall: @escaping () -> Void,
        onShareVerse: @escaping (DailyVerseSnapshot) -> Void = { _ in },
        onBookmarkVerse: @escaping (DailyVerseSnapshot, @escaping (Bool) -> Void) -> Void = { _, completion in completion(false) },
        onOpenVerseFullscreen: @escaping (DailyVerseSnapshot, @escaping (DailyVerseSnapshot) -> Void) -> Void = { _, _ in },
        onOpenMemoryChallenge: @escaping (DailyVerseSnapshot) -> Void = { _ in },
        onOpenReflection: @escaping (DailyVerseSnapshot) -> Void = { _ in },
        onPresentStreakComplete: @escaping () -> Void = {}
    ) {
        self.store = store
        self.onContinueReading = onContinueReading
        self.onOpenPrayerWall = onOpenPrayerWall
        self.onShareVerse = onShareVerse
        self.onBookmarkVerse = onBookmarkVerse
        self.onOpenVerseFullscreen = onOpenVerseFullscreen
        self.onOpenMemoryChallenge = onOpenMemoryChallenge
        self.onOpenReflection = onOpenReflection
        self.onPresentStreakComplete = onPresentStreakComplete
        _verse = State(initialValue: DailyVerseSnapshot.loadCurrent())
        _continueReading = State(initialValue: ContinueReadingSnapshot.loadCurrent())
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var userDisplayName: String {
        let saved = UserDefaults.standard.string(forKey: "OnboardingUserName")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !saved.isEmpty { return saved }
        let email = UserDefaults.standard.string(forKey: "OnboardingUserEmail") ?? ""
        if let at = email.firstIndex(of: "@") {
            return String(email[..<at])
        }
        return ""
    }

    private var greetingTitle: String {
        let name = userDisplayName
        return name.isEmpty ? "\(greeting) 👋" : "\(greeting), \(name) 👋"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header

                if store.allStepsComplete {
                    streakSummaryCard
                }

                todaysVerseCard

                journeySection

                // Prayer section — hidden (logic unchanged)
                // prayerWallCard

                continueReadingCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .sheet(isPresented: $showMemory) {
            NavigationView {
                MemoryChallengeView(verse: verse, store: store) {
                    showMemory = false
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showReflection) {
            NavigationView {
                ReflectionView(verse: verse, store: store) {
                    showReflection = false
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showStreak) {
            NavigationView {
                StreakCompleteView(store: store) {
                    showStreak = false
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showCalendar) {
            NavigationView {
                StreakCalendarView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showCalendar = false }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            store.reload()
            var loaded = DailyVerseSnapshot.loadCurrent()
            loaded.imageName = HomeVerseImage
            verse = loaded
            continueReading = ContinueReadingSnapshot.loadCurrent()
            isVerseImageSaved = false
            loadPrayerCount()
            UserDefaults.standard.set("1", forKey: "AppOpenFirst")
            if store.allStepsComplete {
                didAutoPresentStreak = true
            }
        }
        .onChange(of: store.allStepsComplete) { complete in
            if complete && !didAutoPresentStreak {
                didAutoPresentStreak = true
                showMemory = false
                showReflection = false
                onPresentStreakComplete()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                Text("Ready for today's Scripture journey?")
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.5))
            }
            Spacer()
            Button(action: { showStreak = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "FF9F0A"))
                    Text("\(max(store.streakCount, 0))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var streakSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: { showStreak = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(hex: "FF9F0A"))
                        Text("\(max(store.streakCount, 1)) Day Streak")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 8)

                Button(action: { showCalendar = true }) {
                    Text("View Calendar >")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .buttonStyle(PlainButtonStyle())
            }

            HStack(alignment: .bottom, spacing: 12) {
                Text("Keep going! You’re building a beautiful habit.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { showStreak = true }) {
                    VStack(spacing: 2) {
                        Text("\(max(store.streakCount, 1))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("Days")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "0B1B3A"))
        )
    }

    private var todaysVerseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("TODAY'S VERSE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.45))
                Spacer(minLength: 8)

                DailyJourneyVerseActionsBar(
                    isSaved: isVerseImageSaved,
                    onShare: { onShareVerse(verse) },
                    onBookmark: {
                        onBookmarkVerse(verse) { success in
                            if success {
                                isVerseImageSaved = true
                            }
                        }
                    }
                )
                .frame(width: 82, height: 36)
                .fixedSize()
                .zIndex(20)
            }
            .zIndex(20)

            // Not a Button — avoids whole-card blink; only the image cycles wallpaper.
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let image = UIImage(named: verse.imageName) {
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
                .frame(height: 200)
                .clipped()
                .id(verse.imageName)

                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.65)]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(verse.reference)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(verse.text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .cornerRadius(18)
            .contentShape(Rectangle())
            .onTapGesture {
                store.markVerseCompleted()
                openVerseFullscreen()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        guard abs(dx) > abs(dy), abs(dx) > 40 else { return }
                        if dx < 0 {
                            verse.cycleWallpaper()
                        } else {
                            verse.cycleWallpaper(backward: true)
                        }
                        isVerseImageSaved = false
                        store.markVerseCompleted()
                    }
            )

            HStack {
                Spacer()
                ForEach(1..<9, id: \.self) { i in
                    Circle()
                        .fill(verse.imageName == "S\(i).jpg" ? Color(hex: "1C46B2") : Color.black.opacity(0.15))
                        .frame(width: 7, height: 7)
                }
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S JOURNEY")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.55))
                Spacer()
                Text(store.journeyProgressLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.4))
            }

            VStack(spacing: 0) {
                journeyRow(
                    title: "Today's Verse",
                    subtitle: verse.reference.isEmpty ? "Read today's Scripture" : verse.reference,
                    icon: "book.fill",
                    done: store.verseCompleted,
                    action: {
                        store.markVerseCompleted()
                        openVerseFullscreen()
                    }
                )
                Divider().padding(.leading, 52)
                journeyRow(
                    title: "Memory Challenge",
                    subtitle: store.memoryCompleted ? "Completed for today" : "How much can you remember?",
                    icon: "brain.head.profile",
                    done: store.memoryCompleted,
                    action: { onOpenMemoryChallenge(verse) }
                )
                Divider().padding(.leading, 52)
                journeyRow(
                    title: "Reflection",
                    subtitle: store.reflectionCompleted ? "Completed for today" : "What spoke to you?",
                    icon: "pencil",
                    done: store.reflectionCompleted,
                    action: { onOpenReflection(verse) }
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)

            if store.allStepsComplete {
                HStack(spacing: 10) {
                    Text("🎉")
                    Text("Today's Journey Complete! You showed up for God's Word today.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "1B7A3D"))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "E8F8EE"))
                .cornerRadius(14)
            }
        }
    }

    private func journeyRow(
        title: String,
        subtitle: String,
        icon: String,
        done: Bool,
        iconTint: Color = Color(hex: "1C46B2"),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(done ? Color(hex: "34C759") : Color(hex: "EEF1F7"))
                        .frame(width: 36, height: 36)
                    Image(systemName: done ? "checkmark" : icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(done ? .white : iconTint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer()

                if !done {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.25))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var prayerWallCard: some View {
        Button(action: onOpenPrayerWall) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prayer Wall")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    Text(prayerCount > 0 ? "\(formattedCount(prayerCount)) people praying today" : "Join others in prayer today")
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.5))
                }
                Spacer()
                HStack(spacing: -10) {
                    ForEach(0..<3, id: \.self) { i in
                        ZStack {
                            Circle()
                                .fill(avatarColor(i))
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Text(prayerCount > 3 ? "+\(max(prayerCount - 3, 0))" : "+")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "1C46B2"))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "E8EEFF"))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var continueReadingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONTINUE READING")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.black.opacity(0.45))

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(continueReading.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Text(continueReading.snippet)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.5))
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                Button(action: onContinueReading) {
                    HStack(spacing: 4) {
                        Text(continueReading.buttonTitle)
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(20)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        }
        .padding(.top, 4)
    }

    private func loadPrayerCount() {
        PrayerWallService.shared.fetchPrayers { result in
            DispatchQueue.main.async {
                if case .success(let items) = result {
                    prayerCount = items.count
                }
            }
        }
    }

    private func formattedCount(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func avatarColor(_ index: Int) -> Color {
        let colors = [Color(hex: "7AA2FF"), Color(hex: "F5A623"), Color(hex: "34C759")]
        return colors[index % colors.count]
    }

    private func openVerseFullscreen() {
        onOpenVerseFullscreen(verse) { updated in
            verse = updated
            isVerseImageSaved = false
        }
    }
}
