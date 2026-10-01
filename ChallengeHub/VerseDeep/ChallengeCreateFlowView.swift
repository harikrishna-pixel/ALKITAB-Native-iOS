//
//  ChallengeCreateFlowView.swift
//  NKJV Bible
//
//  VerseDeep create → generate → play → share flow.
//

import SwiftUI
import UIKit

private enum ChallengeCreateStep: Equatable {
    case paywall
    case pickType
    case pickCount
    case generating
    case created
    case playing
    case invite
    case shared
}

struct ChallengeCreateFlowView: View {
    var showBackButton: Bool = true
    var sessionConfig: ChallengeSessionConfig? = nil
    var verseContext: ChallengeVerseContext? = nil
    /// Presents the existing subscription screen, then calls `done`.
    var onUnlock: (@escaping () -> Void) -> Void = { done in done() }
    var onBack: () -> Void
    var onMyChallenges: () -> Void

    @StateObject private var shareSession = ChallengeShareSession()
    @State private var step: ChallengeCreateStep = .paywall
    @State private var selectedKind: ChallengeKind = .fillVerse
    @State private var questionCount: Int = 3
    @State private var questions: [ChallengeVerseDeepPlayQuestion] = []
    @State private var playID = UUID()
    @State private var verse: ChallengeVerseContext = ChallengeVerseContext.loadToday()
    @State private var activeConfig: ChallengeSessionConfig?

    var body: some View {
        Group {
            switch step {
            case .paywall:
                ChallengeCreatorPaywallView(
                    onClose: onBack,
                    onNotNow: { step = .pickType },
                    onUnlock: {
                        onUnlock { step = .pickType }
                    }
                )
            case .pickType:
                ChallengeCreateTypePickerView(
                    verseReference: verse.reference,
                    onBack: showBackButton ? onBack : nil,
                    onSelect: { kind in
                        selectedKind = kind
                        step = .pickCount
                    }
                )
            case .pickCount:
                ChallengeQuestionCountView(
                    kind: selectedKind,
                    verseReference: verse.reference,
                    selectedCount: $questionCount,
                    onBack: { step = .pickType },
                    onGenerate: {
                        guard selectedKind.isPremium else {
                            startGenerate()
                            return
                        }
                        AIUsageLimiter.shared.requestAccess(.quiz) {
                            startGenerate()
                        }
                    }
                )
            case .generating:
                ChallengeGeneratingView(verseReference: verse.reference)
            case .created:
                ChallengeCreatedSuccessView(
                    title: shareSession.challengeTitle.isEmpty ? "\(verse.reference) Challenge" : shareSession.challengeTitle,
                    detail: "\(questionCount) Questions · \(selectedKind.title)",
                    onPlay: { step = .playing },
                    onShare: { step = .invite },
                    onInvite: { step = .invite },
                    onMyChallenges: onMyChallenges,
                    onDone: onBack
                )
            case .playing:
                if selectedKind == .verseMatch {
                    ChallengeVerseMatchView(
                        verse: verse,
                        sessionConfig: activeConfig,
                        onClose: { step = .created }
                    )
                    .id(playID)
                } else if selectedKind == .wordSearch {
                    ChallengeWordSearchView(
                        verse: verse,
                        sessionConfig: activeConfig,
                        onClose: { step = .created }
                    )
                    .id(playID)
                } else {
                    ChallengeVerseDeepPlayView(
                        title: shareSession.challengeTitle.isEmpty ? selectedKind.title : shareSession.challengeTitle,
                        questions: questions,
                        shareSession: shareSession,
                        onDone: { step = .created },
                        onPlayAgain: { playID = UUID() },
                        onShare: { step = .invite }
                    )
                    .id(playID)
                }
            case .invite:
                ChallengeInviteFriendsView(
                    shareUrl: shareSession.shareUrl ?? "",
                    challengeTitle: shareSession.challengeTitle,
                    onBack: { step = .created },
                    onShared: { step = .shared }
                )
            case .shared:
                ChallengeSharedConfirmationView(
                    onMyChallenges: onMyChallenges,
                    onCreateAnother: {
                        shareSession.resetCreatedChallenge()
                        questions = []
                        step = .pickType
                    }
                )
            }
        }
        .onAppear {
            reloadVerse()
        }
    }

    private func reloadVerse() {
        if let verseContext {
            verse = verseContext
            activeConfig = sessionConfig
        } else if let sessionConfig {
            verse = sessionConfig.primaryVerse()
            activeConfig = sessionConfig
        } else {
            verse = ChallengeVerseContext.loadToday()
            activeConfig = nil
        }
    }

    private func startGenerate() {
        let config: ChallengeSessionConfig
        if let base = sessionConfig {
            config = base.withQuestionCount(questionCount)
        } else {
            let parts = verse.reference.split(separator: " ")
            let book = parts.dropLast().joined(separator: " ").isEmpty
                ? (parts.first.map(String.init) ?? "Genesis")
                : parts.dropLast().joined(separator: " ")
            // reference like "Genesis 1:1" → chapter 1
            let chapterPart = parts.last.map(String.init) ?? "1:1"
            let chapterNum = Int(chapterPart.split(separator: ":").first.map(String.init) ?? "1") ?? 1
            config = ChallengeSessionConfig.verseDeep(
                book: book.isEmpty ? "Genesis" : book,
                chapter: chapterNum,
                questionCount: questionCount
            )
        }
        activeConfig = config
        let payload: [ChallengeQuestionPayload]
        if selectedKind == .verseMatch {
            let pairs = ChallengeGameFactory.matchPairs(from: verse, config: config)
            questions = []
            payload = ChallengeHubShareMapper.fromMatchPairs(pairs)
        } else if selectedKind == .wordSearch {
            let words = ChallengeGameFactory.wordSearchWords(from: verse, config: config)
            questions = []
            payload = ChallengeHubShareMapper.fromWordSearch(words: words, verse: verse)
        } else {
            let built = ChallengeVerseDeepQuestionBuilder.build(
                kind: selectedKind,
                verse: verse,
                config: config
            )
            questions = built
            payload = ChallengeVerseDeepQuestionBuilder.apiPayload(from: built)
        }
        step = .generating
        shareSession.create(kind: selectedKind, verse: verse, questions: payload) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                AIUsageLimiter.shared.commit(.quiz)
                switch result {
                case .success:
                    step = .created
                case .failure(let error):
                    // Still allow local play even if API fails
                    OnboardingAuthManager.topViewController()?.view.makeToast(
                        error.localizedDescription,
                        duration: 2.0,
                        position: .bottom
                    )
                    step = .created
                }
            }
        }
    }

}

private struct ChallengeCreatorPaywallView: View {
    var onClose: () -> Void
    var onNotNow: () -> Void
    var onUnlock: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "071433").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(ChallengeVerseDeepTheme.gold)
                        Text("VerseDeep")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(ChallengeVerseDeepTheme.gold.opacity(0.18))
                        .frame(width: 88, height: 88)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 36))
                        .foregroundColor(ChallengeVerseDeepTheme.gold)
                }

                Text("Create Your Own\nChallenge")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 18)

                Text("Turn any Scripture into a fun challenge that helps you (and your friends) read, remember and grow in God's Word.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 28)
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 16) {
                    paywallRow(icon: "text.badge.plus", title: "Create from any verse or multiple verses")
                    paywallRow(icon: "square.grid.2x2", title: "Choose your challenge style")
                    paywallRow(icon: "square.and.arrow.up", title: "Save and share with friends")
                    paywallRow(icon: "star.fill", title: "Part of VerseDeep Premium")
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                Spacer(minLength: 16)

                Button(action: onUnlock) {
                    Text("Unlock Challenge Creator")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ChallengeVerseDeepTheme.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)

                Button(action: onNotNow) {
                    Text("Not Now")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 16)
                }
                .padding(.bottom, 8)
            }
        }
    }

    private func paywallRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ChallengeVerseDeepTheme.gold)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
    }
}
