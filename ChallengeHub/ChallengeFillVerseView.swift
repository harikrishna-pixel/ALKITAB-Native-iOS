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

    var body: some View {
        VStack(spacing: 0) {
            header("Fill the Verse")

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    verseBoard
                        .padding(16)
                        .background(Color(hex: "F7F8FC"))
                        .cornerRadius(14)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(Array(bank.enumerated()), id: \.offset) { _, word in
                            let wrongChip = isWrongBankWord(word)
                            Button(action: { pick(word) }) {
                                Text(word)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(wrongChip ? Color(hex: "D70015") : Color(hex: "0B1B3A"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(wrongChip ? Color(hex: "FDECEC") : Color.white)
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

                    if let feedback = feedback {
                        Text(feedback)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(correct ? Color(hex: "1B7A3D") : Color(hex: "D70015"))
                    }
                }
                .padding(20)
            }

            Button(action: check) {
                Text(correct ? "Done" : "Check Answer")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(27)
            }
            .padding(.horizontal, 20)

            Button(action: hint) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                    Text("Need a hint?")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "1C46B2"))
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .disabled(correct)
        }
        .background(Color.white.ignoresSafeArea())
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
    }

    private func pick(_ word: String) {
        let target: Int?
        if let selectedBlank {
            target = selectedBlank
        } else if let empty = blanks.first(where: { filled[$0] == nil }) {
            target = empty
        } else {
            // All blanks filled (e.g. after a wrong check) — replace the first blank immediately.
            target = blanks.first
        }
        guard let target else { return }
        filled[target] = word
        selectedBlank = blanks.first(where: { filled[$0] == nil }) ?? target
        feedback = nil
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
            selectedBlank = blanks.first
        }
    }

    private func hint() {
        guard let idx = blanks.first(where: { filled[$0] == nil }) ?? blanks.first else { return }
        filled[idx] = tokens[idx].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        selectedBlank = blanks.first(where: { filled[$0] == nil })
    }

    private func header(_ title: String) -> some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B3A"))
            }
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "0B1B3A"))
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
