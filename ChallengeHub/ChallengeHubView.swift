//
//  ChallengeHubView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeHubView: View {
    var showBackButton: Bool = true
    var sessionConfig: ChallengeSessionConfig? = nil
    var onBack: () -> Void
    var onOpenPremiumPaywall: () -> Void
    var onOpenLegacyQuiz: () -> Void
    var onOpenChallenge: (ChallengeKind, ChallengeVerseContext, ChallengeSessionConfig?) -> Void

    @State private var verse = ChallengeVerseContext.loadToday()
    @State private var walletTick = 0
    @State private var pendingKind: ChallengeKind?

    init(
        showBackButton: Bool = true,
        sessionConfig: ChallengeSessionConfig? = nil,
        onBack: @escaping () -> Void,
        onOpenPremiumPaywall: @escaping () -> Void,
        onOpenLegacyQuiz: @escaping () -> Void,
        onOpenChallenge: @escaping (ChallengeKind, ChallengeVerseContext, ChallengeSessionConfig?) -> Void
    ) {
        self.showBackButton = showBackButton
        self.sessionConfig = sessionConfig
        self.onBack = onBack
        self.onOpenPremiumPaywall = onOpenPremiumPaywall
        self.onOpenLegacyQuiz = onOpenLegacyQuiz
        self.onOpenChallenge = onOpenChallenge
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(
                title: "Challenge Hub",
                showBackButton: showBackButton,
                onBack: onBack,
                walletTick: walletTick
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(ChallengeKind.allCases) { kind in
                        challengeRow(kind)
                    }

                    Text("Premium challenges are unlimited with more variety and rewards.")
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black.opacity(0.45))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
        .onAppear {
            reloadVerse()
            walletTick += 1
        }
        .sheet(item: $pendingKind) { kind in
            ChallengeStartSheet(
                kind: kind,
                onCancel: { pendingKind = nil },
                onStart: { config in
                    let startVerse = config.primaryVerse()
                    onOpenChallenge(kind, startVerse, config)
                    pendingKind = nil
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            walletTick += 1
        }
    }

    private func challengeRow(_ kind: ChallengeKind) -> some View {
        Button(action: { open(kind) }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: kind.iconBgHex))
                        .frame(width: 48, height: 48)
                    Image(systemName: kind.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: kind.iconTintHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "0B1B3A"))
                    Text(kind.subtitle(config: sessionConfig))
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.45))
                }

                Spacer()

                if kind.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                        Text("Premium")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "C9A227"))
                } else {
                    Text("Free")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ChallengeQuizTheme.accent)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.2))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func open(_ kind: ChallengeKind) {
        if let sessionConfig {
            onOpenChallenge(kind, verse, sessionConfig)
            return
        }
        pendingKind = kind
    }

    private func reloadVerse() {
        if let sessionConfig {
            verse = sessionConfig.primaryVerse()
            return
        }
        verse = ChallengeVerseContext.loadToday()
    }
}

struct ChallengeGameScreen: View {
    let verse: ChallengeVerseContext
    var sessionConfig: ChallengeSessionConfig? = nil
    var onClose: () -> Void
    var onOpenLegacyQuiz: () -> Void

    @State private var activeKind: ChallengeKind
    @State private var showKindPicker = false

    init(
        kind: ChallengeKind,
        verse: ChallengeVerseContext,
        sessionConfig: ChallengeSessionConfig? = nil,
        onClose: @escaping () -> Void,
        onOpenLegacyQuiz: @escaping () -> Void
    ) {
        _activeKind = State(initialValue: kind)
        self.verse = verse
        self.sessionConfig = sessionConfig
        self.onClose = onClose
        self.onOpenLegacyQuiz = onOpenLegacyQuiz
    }

    var body: some View {
        Group {
            switch activeKind {
            case .quickQuiz:
                ChallengeQuickQuizView(verse: verse, sessionConfig: sessionConfig, onClose: onClose, onOpenLegacyQuiz: onOpenLegacyQuiz)
            case .fillVerse:
                ChallengeFillVerseView(verse: verse, sessionConfig: sessionConfig, onClose: onClose)
            case .verseMatch:
                ChallengeVerseMatchView(verse: verse, sessionConfig: sessionConfig, onClose: onClose)
            case .trueFalse:
                ChallengeTrueFalseView(verse: verse, sessionConfig: sessionConfig, onClose: onClose)
            case .wordSearch:
                ChallengeWordSearchView(verse: verse, sessionConfig: sessionConfig, onClose: onClose)
            }
        }
        .id(activeKind)
        .environment(\.challengeSwitchAction, { showKindPicker = true })
        .sheet(isPresented: $showKindPicker) {
            ChallengeKindPickerSheet(
                current: activeKind,
                sessionConfig: sessionConfig,
                onSelect: { kind in
                    activeKind = kind
                    showKindPicker = false
                },
                onDismiss: { showKindPicker = false }
            )
        }
        .navigationBarHidden(true)
    }
}

/// In-game challenge picker — same options as Challenge Hub list (UI only).
struct ChallengeKindPickerSheet: View {
    let current: ChallengeKind
    var sessionConfig: ChallengeSessionConfig? = nil
    var onSelect: (ChallengeKind) -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(title: "Change Challenge", showBackButton: false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Text("Switch to another challenge without leaving.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.black.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)

                    ForEach(ChallengeKind.allCases) { kind in
                        Button(action: { onSelect(kind) }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: kind.iconBgHex))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: kind.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: kind.iconTintHex))
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(kind.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "0B1B3A"))
                                    Text(kind.subtitle(config: sessionConfig))
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.black.opacity(0.45))
                                }

                                Spacer()

                                if kind.isPremium {
                                    HStack(spacing: 4) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 11))
                                        Text("Premium")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "C9A227"))
                                } else {
                                    Text("Free")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(ChallengeQuizTheme.accent)
                                        .clipShape(Capsule())
                                }

                                if kind == current {
                                    Text("Current")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(ChallengeQuizTheme.accent)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(ChallengeQuizTheme.accent.opacity(0.12))
                                        .clipShape(Capsule())
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color.black.opacity(0.25))
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: onDismiss) {
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ChallengeQuizTheme.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
    }
}

struct ChallengeStartSheet: View {
    let kind: ChallengeKind
    var onCancel: () -> Void
    var onStart: (ChallengeSessionConfig) -> Void

    @State private var bookName: String
    @State private var chapterName: String
    @State private var chapterCount: Int
    @State private var difficulty: ChallengeDifficulty?
    @State private var showBookPicker = false
    @State private var showChapterPicker = false

    private let themeColor = Color(UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)

    init(
        kind: ChallengeKind,
        onCancel: @escaping () -> Void,
        onStart: @escaping (ChallengeSessionConfig) -> Void
    ) {
        self.kind = kind
        self.onCancel = onCancel
        self.onStart = onStart

        let book = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        let chapter = UserDefaults.standard.string(forKey: "BookChapter") ?? "0"
        _bookName = State(initialValue: book)
        _chapterName = State(initialValue: chapter)
        _chapterCount = State(initialValue: BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: book))
    }

    private var chapterDisplayName: String {
        if chapterName == "Chapter" { return "Chapter" }
        guard let value = Int(chapterName) else { return chapterName }
        return value > 0 ? "\(value)" : "\(value + 1)"
    }

    private var canStart: Bool {
        difficulty != nil && chapterName != "Chapter" && Int(chapterName) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(title: "Start Challenge", showBackButton: false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(kind.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "0B1B3A"))
                        Text("Select book, chapter, and difficulty to begin.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.55))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)

                    ChallengeHubPickerCard(title: "Book", value: bookName) {
                        showBookPicker = true
                    }

                    ChallengeHubPickerCard(title: "Chapter", value: chapterDisplayName) {
                        guard !bookName.isEmpty else { return }
                        showChapterPicker = true
                    }

                    Text("Difficulty")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "0B1B3A"))

                    HStack(spacing: 10) {
                        ForEach(ChallengeDifficulty.allCases) { level in
                            difficultyButton(level)
                        }
                    }

                    if let difficulty {
                        Text(kind.difficultyInstruction(for: difficulty))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeColor)
                    }

                    Button(action: startTapped) {
                        Text("Start \(kind.title)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canStart ? themeColor : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!canStart)

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ChallengeQuizTheme.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
        .sheet(isPresented: $showBookPicker) {
            ChallengeQuizPickerSheet(title: "Select Book", onClose: { showBookPicker = false }) {
                ChallengeBookListPicker { selection in
                    bookName = selection.bookName
                    chapterCount = selection.chapterCount
                    chapterName = "Chapter"
                    showBookPicker = false
                }
            }
        }
        .sheet(isPresented: $showChapterPicker) {
            ChallengeQuizPickerSheet(title: "Select Chapter", onClose: { showChapterPicker = false }) {
                ChallengeChapterListPicker(chapterCount: chapterCount) { chapter in
                    chapterName = chapter
                    showChapterPicker = false
                }
            }
        }
    }

    private func difficultyButton(_ level: ChallengeDifficulty) -> some View {
        let selected = difficulty == level
        return Button(action: { difficulty = level }) {
            Text(level.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(selected ? .white : Color(hex: "0B1B3A"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selected ? themeColor : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.08), lineWidth: selected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func startTapped() {
        guard let difficulty, let chapter = Int(chapterName) else { return }
        let config = ChallengeSessionConfig.markAsRead(book: bookName, chapter: chapter, difficulty: difficulty)
        onStart(config)
    }
}
