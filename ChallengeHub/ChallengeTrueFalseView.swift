//
//  ChallengeTrueFalseView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeTrueFalseView: View {
    let verse: ChallengeVerseContext
    var sessionConfig: ChallengeSessionConfig? = nil
    var onClose: () -> Void

    @State private var questions: [TrueFalseQuestion] = []
    @State private var index = 0
    @State private var selected: Bool?
    @State private var revealed = false
    @State private var score = 0
    @State private var finished = false
    @State private var lives = 3
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
                    screenTitle: ChallengeKind.trueFalse.title,
                    onBack: onClose,
                    lives: lives,
                    questionNumber: index + 1,
                    questionTotal: questions.count,
                    caption: "Choose True or False.",
                    primaryTitle: revealed
                        ? (index + 1 >= questions.count ? "Finish" : "Next")
                        : "Check Answer",
                    primaryEnabled: selected != nil,
                    onPrimary: { primaryAction(for: q) },
                    fiftyFiftyEnabled: false,
                    hintEnabled: !usedHint && !revealed,
                    skipEnabled: !revealed,
                    onLifeline: { handleLifeline($0, question: q) },
                    walletTick: walletTick
                ) {
                    VStack(alignment: .leading, spacing: 14) {
                        ChallengeQuizContentHeader(
                            reference: verse.reference,
                            instruction: "Choose True or False."
                        )

                        Text(q.statement)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "0B1B3A"))
                            .fixedSize(horizontal: false, vertical: true)

                        tfButton(title: "True", value: true, correct: q.isTrue)
                        tfButton(title: "False", value: false, correct: !q.isTrue)

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
            questions = ChallengeGameFactory.trueFalse(from: verse, config: sessionConfig)
        }
    }

    private func tfButton(title: String, value: Bool, correct: Bool) -> some View {
        let isSelected = selected == value
        let showCorrect = revealed && correct
        let showWrong = revealed && isSelected && !correct
        return ChallengeQuizOptionRow(
            title: title,
            isSelected: isSelected,
            showCorrect: showCorrect,
            showWrong: showWrong,
            isDisabled: revealed,
            onTap: {
                guard !revealed else { return }
                selected = value
                toast = nil
            }
        )
    }

    private func primaryAction(for q: TrueFalseQuestion) {
        if revealed {
            advance()
            return
        }
        guard let selected = selected else { return }
        revealed = true
        if selected == q.isTrue {
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
            usedHint = false
            toast = nil
        }
    }

    private func handleLifeline(_ kind: ChallengeLifelineKind, question q: TrueFalseQuestion) {
        switch kind {
        case .fiftyFifty:
            toast = "50/50 is not available for True or False."
        case .hint:
            guard ChallengeWallet.spend(ChallengeWallet.hintCost) else {
                ChallengeWallet.presentInsufficientCreditsAlert(for: "Hint")
                return
            }
            walletTick += 1
            usedHint = true
            selected = q.isTrue
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
