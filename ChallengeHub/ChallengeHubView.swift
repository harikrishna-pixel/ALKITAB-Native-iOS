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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if showBackButton {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1B3A"))
                            .frame(width: 36, height: 36)
                    }
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }
                Spacer()
                Text("Challenge Hub")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "0B1B3A"))
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text("Choose a challenge to grow in God's Word.")
                .font(.system(size: 14))
                .foregroundColor(Color.black.opacity(0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(ChallengeKind.allCases) { kind in
                        challengeRow(kind)
                    }

                    Text("Premium challenges are unlimited with more variety and rewards.")
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black.opacity(0.45))
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "EEF2F8"))
                        .cornerRadius(14)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            verse = ChallengeVerseContext.loadToday()
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
                        .background(Color(hex: "0B1B3A"))
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
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
    let kind: ChallengeKind
    let verse: ChallengeVerseContext
    var onClose: () -> Void
    var onOpenLegacyQuiz: () -> Void

    var body: some View {
        Group {
            switch kind {
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
        .navigationBarHidden(true)
    }
}
