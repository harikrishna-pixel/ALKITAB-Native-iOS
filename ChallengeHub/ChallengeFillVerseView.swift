//
//  ChallengeFillVerseView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeFillVerseView: View {
    let verse: ChallengeVerseContext
    var onClose: () -> Void

    @State private var tokens: [String] = []
    @State private var blanks: [Int] = []
    @State private var bank: [String] = []
    @State private var filled: [Int: String] = [:]
    @State private var selectedBlank: Int?
    @State private var feedback: String?
    @State private var correct = false
    @State private var lives = 3
    @State private var usedFifty = false
    @State private var usedHint = false
    @State private var walletTick = 0
    @State private var toast: String?
    @State private var hiddenBank: Set<String> = []

    var body: some View {
        ChallengeOldStyleShell(
            onBack: onClose,
            lives: lives,
            questionNumber: 1,
            questionTotal: 1,
            caption: "Drag the correct words to fill the blanks.",
            primaryTitle: correct ? "Done" : "Check Answer",
            primaryEnabled: true,
            onPrimary: check,
            fiftyFiftyEnabled: !usedFifty && !correct,
            hintEnabled: !usedHint && !correct,
            skipEnabled: !correct,
            onLifeline: handleLifeline,
            walletTick: walletTick
        ) {
            VStack(alignment: .leading, spacing: 16) {
                verseBoard

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(bank.enumerated()), id: \.offset) { _, word in
                        if !hiddenBank.contains(word) {
                            let wrongChip = isWrongBankWord(word)
                            Button(action: { pick(word) }) {
                                Text(word)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(wrongChip ? Color(hex: "D70015") : Color(hex: "0B1B3A"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(wrongChip ? Color(hex: "FDECEC") : Color(hex: "F7F8FC"))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(wrongChip ? Color(hex: "D70015") : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(correct)
                        }
                    }
                }

                if let feedback = feedback {
                    Text(feedback)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(correct ? Color(hex: "1B7A3D") : Color(hex: "D70015"))
                }
                if let toast = toast {
                    Text(toast)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "D70015"))
                }
            }
        }
        .onAppear(perform: build)
    }

    private var verseBoard: some View {
        let columns = [GridItem(.adaptive(minimum: 70), spacing: 8, alignment: .leading)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                if blanks.contains(index) {
                    let wrong = isWrongFill(index)
                    Button(action: { selectedBlank = index }) {
                        Text(filled[index] ?? "______")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(wrong ? Color(hex: "D70015") : Color(hex: "1C46B2"))
                            .underline()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(correct)
                } else {
                    Text(token)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "0B1B3A"))
                }
            }
        }
    }

    private var showingWrongState: Bool {
        !correct && (feedback?.hasPrefix("Not quite") == true)
    }

    private func isWrongFill(_ index: Int) -> Bool {
        guard showingWrongState, let filledWord = filled[index] else { return false }
        let a = filledWord.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let b = tokens[index].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        return a.caseInsensitiveCompare(b) != .orderedSame
    }

    private func isWrongBankWord(_ word: String) -> Bool {
        guard showingWrongState else { return false }
        return blanks.contains { idx in
            guard isWrongFill(idx), let filledWord = filled[idx] else { return false }
            return filledWord.caseInsensitiveCompare(word) == .orderedSame
        }
    }

    private func build() {
        let data = ChallengeGameFactory.fillChallenge(from: verse)
        tokens = data.tokens
        blanks = data.blankIndices
        bank = data.bank
        selectedBlank = blanks.first
        filled = [:]
        feedback = nil
        correct = false
        hiddenBank = []
        usedFifty = false
        usedHint = false
        toast = nil
    }

    private func pick(_ word: String) {
        let target: Int?
        if let selectedBlank {
            target = selectedBlank
        } else if let empty = blanks.first(where: { filled[$0] == nil }) {
            target = empty
        } else {
            target = blanks.first
        }
        guard let target else { return }
        filled[target] = word
        selectedBlank = blanks.first(where: { filled[$0] == nil }) ?? target
        feedback = nil
        toast = nil
    }

    private func check() {
        if correct {
            onClose()
            return
        }
        guard blanks.allSatisfy({ filled[$0] != nil }) else {
            feedback = "Fill all the blanks first."
            return
        }
        let ok = blanks.allSatisfy { idx in
            let a = (filled[idx] ?? "").trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            let b = tokens[idx].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            return a.caseInsensitiveCompare(b) == .orderedSame
        }
        correct = ok
        feedback = ok ? "Correct! Great job." : "Not quite — try again."
        if !ok {
            lives = max(0, lives - 1)
            selectedBlank = blanks.first
            if lives == 0 {
                feedback = "Out of lives. Try again tomorrow."
            }
        }
    }

    private func handleLifeline(_ kind: ChallengeLifelineKind) {
        switch kind {
        case .fiftyFifty:
            guard ChallengeWallet.spend(ChallengeWallet.fiftyFiftyCost) else {
                toast = "Not enough coins for 50/50."
                return
            }
            walletTick += 1
            usedFifty = true
            let correctWords = Set(blanks.map {
                tokens[$0].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            })
            let distractors = bank.filter { word in
                !correctWords.contains(where: { $0.caseInsensitiveCompare(word) == .orderedSame })
            }
            hiddenBank = Set(distractors.prefix(max(distractors.count / 2, 1)))
            toast = nil
        case .hint:
            guard ChallengeWallet.spend(ChallengeWallet.hintCost) else {
                toast = "Not enough coins for Hint."
                return
            }
            walletTick += 1
            usedHint = true
            guard let idx = blanks.first(where: { filled[$0] == nil }) ?? blanks.first else { return }
            filled[idx] = tokens[idx].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            selectedBlank = blanks.first(where: { filled[$0] == nil })
            toast = nil
        case .skip:
            guard ChallengeWallet.spend(ChallengeWallet.skipCost) else {
                toast = "Not enough coins for Skip."
                return
            }
            walletTick += 1
            onClose()
        }
    }
}
