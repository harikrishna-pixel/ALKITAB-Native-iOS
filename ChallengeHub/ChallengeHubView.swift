//
//  ChallengeHubView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeHubView: View {
    var showBackButton: Bool = true
    var onBack: () -> Void
    var onOpenPremiumPaywall: () -> Void
    var onOpenLegacyQuiz: () -> Void
    var onOpenChallenge: (ChallengeKind, ChallengeVerseContext) -> Void

    @State private var verse = ChallengeVerseContext.loadToday()
    @State private var walletTick = 0

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(
                title: "Bible Quiz",
                showBackButton: showBackButton,
                onBack: onBack,
                walletTick: walletTick
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        ChallengeQuizContentHeader(
                            reference: verse.reference,
                            instruction: "Choose a challenge to grow in God's Word."
                        )

                        Text(verse.text)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "0B1B3A"))
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)

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
            verse = ChallengeVerseContext.loadToday()
            walletTick += 1
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
                    Text(kind.subtitle)
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
        // Premium paywall gate temporarily disabled — open all challenges.
        // if kind.isPremium && !ChallengeGameFactory.hasPremiumAccess {
        //     onOpenPremiumPaywall()
        //     return
        // }
        onOpenChallenge(kind, verse)
    }
}

struct ChallengeGameScreen: View {
    let verse: ChallengeVerseContext
    var onClose: () -> Void
    var onOpenLegacyQuiz: () -> Void

    @State private var activeKind: ChallengeKind
    @State private var showKindPicker = false

    init(
        kind: ChallengeKind,
        verse: ChallengeVerseContext,
        onClose: @escaping () -> Void,
        onOpenLegacyQuiz: @escaping () -> Void
    ) {
        _activeKind = State(initialValue: kind)
        self.verse = verse
        self.onClose = onClose
        self.onOpenLegacyQuiz = onOpenLegacyQuiz
    }

    var body: some View {
        Group {
            switch activeKind {
            case .quickQuiz:
                ChallengeQuickQuizView(verse: verse, onClose: onClose, onOpenLegacyQuiz: onOpenLegacyQuiz)
            case .fillVerse:
                ChallengeFillVerseView(verse: verse, onClose: onClose)
            case .verseMatch:
                ChallengeVerseMatchView(verse: verse, onClose: onClose)
            case .trueFalse:
                ChallengeTrueFalseView(verse: verse, onClose: onClose)
            case .wordSearch:
                ChallengeWordSearchView(verse: verse, onClose: onClose)
            }
        }
        .id(activeKind)
        .environment(\.challengeSwitchAction, { showKindPicker = true })
        .sheet(isPresented: $showKindPicker) {
            ChallengeKindPickerSheet(
                current: activeKind,
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
                                    Text(kind.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.black.opacity(0.45))
                                }

                                Spacer()

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
