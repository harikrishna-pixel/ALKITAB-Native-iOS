//
//  ChallengeQuickQuizView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeQuickQuizView: View {
    let verse: ChallengeVerseContext
    var sessionConfig: ChallengeSessionConfig? = nil
    var onClose: () -> Void
    var onOpenLegacyQuiz: () -> Void

    @State private var questions: [QuickQuizQuestion] = []
    @State private var index = 0
    @State private var selected: Int?
    @State private var revealed = false
    @State private var score = 0
    @State private var finished = false
    @State private var lives = 3
    @State private var hiddenOptions: Set<Int> = []
    @State private var usedFifty = false
    @State private var usedHint = false
    @State private var walletTick = 0
    @State private var toast: String?

    var body: some View {
        Group {
            if finished {
                ChallengeOldStyleResult(
                    scoreText: "You scored \(score) / \(questions.count)",
                    onDone: onClose
                )
            } else if questions.indices.contains(index) {
                let q = questions[index]
                ChallengeOldStyleShell(
                    screenTitle: ChallengeKind.quickQuiz.title,
                    onBack: onClose,
                    lives: lives,
                    questionNumber: index + 1,
                    questionTotal: questions.count,
                    caption: "Choose the correct answer.",
                    primaryTitle: revealed
                        ? (index + 1 >= questions.count ? "Finish" : "Next")
                        : "Check Answer",
                    primaryEnabled: selected != nil,
                    onPrimary: { primaryAction(for: q) },
                    fiftyFiftyEnabled: !usedFifty && !revealed && selected == nil,
                    hintEnabled: !usedHint && !revealed,
                    skipEnabled: !revealed,
                    onLifeline: { handleLifeline($0, question: q) },
                    walletTick: walletTick
                ) {
                    VStack(alignment: .leading, spacing: 14) {
                        ChallengeQuizContentHeader(
                            reference: verse.reference,
                            instruction: "Choose the correct answer."
                        )

                        Text(q.prompt)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "0B1B3A"))

                        ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                            if !hiddenOptions.contains(i) {
                                optionRow(option, index: i, correct: q.correctIndex)
                            }
                        }

                        if let toast = toast {
                            Text(toast)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "D70015"))
                        }
                    }
                }
            } else {
                Color(hex: "F2F3F7").ignoresSafeArea()
            }
        }
        .onAppear {
            questions = ChallengeGameFactory.quickQuiz(from: verse, config: sessionConfig)
        }
    }

    private func optionRow(_ option: String, index i: Int, correct: Int) -> some View {
        let isSelected = selected == i
        let showCorrect = revealed && i == correct
        let showWrong = revealed && isSelected && i != correct
        return ChallengeQuizOptionRow(
            title: option,
            isSelected: isSelected,
            showCorrect: showCorrect,
            showWrong: showWrong,
            isDisabled: revealed,
            onTap: {
                guard !revealed else { return }
                selected = i
                toast = nil
            }
        )
    }

    private func primaryAction(for q: QuickQuizQuestion) {
        if revealed {
            advance()
            return
        }
        guard let selected = selected else { return }
        revealed = true
        if selected == q.correctIndex {
            score += 1
        } else {
            lives = max(0, lives - 1)
            if lives == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    finished = true
                }
            }
        }
    }

    private func advance() {
        if index + 1 >= questions.count || lives == 0 {
            finished = true
        } else {
            index += 1
            selected = nil
            revealed = false
            hiddenOptions = []
            usedFifty = false
            usedHint = false
            toast = nil
        }
    }

    private func handleLifeline(_ kind: ChallengeLifelineKind, question q: QuickQuizQuestion) {
        switch kind {
        case .fiftyFifty:
            guard ChallengeWallet.spend(ChallengeWallet.fiftyFiftyCost) else {
                ChallengeWallet.presentInsufficientCreditsAlert(for: "50/50")
                return
            }
            walletTick += 1
            usedFifty = true
            let wrong = q.options.indices.filter { $0 != q.correctIndex }.shuffled().prefix(2)
            hiddenOptions = Set(wrong)
            if let selected = selected, hiddenOptions.contains(selected) {
                self.selected = nil
            }
            toast = nil
        case .hint:
            guard ChallengeWallet.spend(ChallengeWallet.hintCost) else {
                ChallengeWallet.presentInsufficientCreditsAlert(for: "Hint")
                return
            }
            walletTick += 1
            usedHint = true
            selected = q.correctIndex
            toast = nil
        case .skip:
            guard ChallengeWallet.spend(ChallengeWallet.skipCost) else {
                ChallengeWallet.presentInsufficientCreditsAlert(for: "Skip")
                return
            }
            walletTick += 1
            advance()
        }
    }
}
