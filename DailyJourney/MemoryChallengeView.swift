//
//  MemoryChallengeView.swift
//  NKJV Bible
//

import SwiftUI

struct MemoryChallengeView: View {
    let verse: DailyVerseSnapshot
    @ObservedObject var store: DailyJourneyStore
    var onDone: () -> Void

    @State private var displayTokens: [String] = []
    @State private var blankIndices: [Int] = []
    @State private var correctWords: [String] = []
    @State private var wordBank: [String] = []
    @State private var filled: [Int: String] = [:]
    @State private var selectedBlank: Int?
    @State private var feedback: String?
    @State private var isCorrect = false
    @State private var isReviewMode = false

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(isReviewMode ? "Your Memory Challenge" : "Memory Challenge")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Text(verse.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1C46B2"))

                    Text(isReviewMode
                          ? "Here’s what you answered today. Resets tomorrow."
                          : "Fill in the blanks. Tap the correct words to complete the verse.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.black.opacity(0.55))

                    verseBoard
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)

                    if !isReviewMode {
                        Text("Word bank")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.black.opacity(0.45))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
                            ForEach(Array(wordBank.enumerated()), id: \.offset) { _, word in
                                Button(action: { selectWord(word) }) {
                                    Text(word)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "EEF1F7"))
                                        .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    if let feedback = feedback {
                        Text(feedback)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isCorrect || isReviewMode ? Color(hex: "1B7A3D") : Color(hex: "D70015"))
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                Button(action: checkAnswer) {
                    Text(isReviewMode || isCorrect ? "Done" : "Check Answer")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1C46B2"))
                        .cornerRadius(27)
                }

                if !isReviewMode {
                    HStack {
                        Button(action: clearAnswers) {
                            HStack(spacing: 6) {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Clear")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(filled.isEmpty ? Color.black.opacity(0.25) : Color(hex: "D70015"))
                        }
                        .disabled(filled.isEmpty)

                        Spacer()

                        Button(action: revealHint) {
                            Text("Need a hint?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "1C46B2"))
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: buildChallenge)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.08))
                Capsule()
                    .fill(Color(hex: "1C46B2"))
                    .frame(width: geo.size.width * (isReviewMode ? 1.0 : 0.5))
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var verseBoard: some View {
        MemoryVerseFlowView(
            tokens: displayTokens,
            blankIndices: blankIndices,
            filled: filled,
            selectedBlank: selectedBlank,
            isReviewMode: isReviewMode,
            onTapBlank: { index in
                if selectedBlank == index, filled[index] != nil {
                    filled[index] = nil
                    feedback = nil
                    isCorrect = false
                } else {
                    selectedBlank = index
                }
            }
        )
    }

    private func buildChallenge() {
        if store.memoryCompleted, let saved = store.savedMemory {
            displayTokens = saved.displayTokens
            blankIndices = saved.blankIndices
            wordBank = saved.wordBank
            filled = Dictionary(uniqueKeysWithValues: saved.filled.compactMap { key, value in
                guard let idx = Int(key) else { return nil }
                return (idx, value)
            })
            correctWords = blankIndices.compactMap { displayTokens.indices.contains($0) ? displayTokens[$0] : nil }
            selectedBlank = nil
            isCorrect = true
            isReviewMode = true
            feedback = "Completed for today"
            return
        }

        let cleaned = verse.text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let tokens = cleaned.components(separatedBy: " ").filter { !$0.isEmpty }
        displayTokens = tokens

        let candidates = tokens.enumerated().compactMap { idx, word -> (Int, String)? in
            let letters = word.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }
            guard letters.count >= 4 else { return nil }
            return (idx, word)
        }

        let picked = Array(candidates.shuffled().prefix(min(4, candidates.count)))
        blankIndices = picked.map { $0.0 }.sorted()
        correctWords = blankIndices.map { displayTokens[$0] }

        var bank = correctWords.map { stripPunctuation($0) }
        // Keep one chip per blank (do not collapse duplicates with Set).
        wordBank = bank.shuffled()

        selectedBlank = blankIndices.first
        filled = [:]
        feedback = nil
        isCorrect = false
        isReviewMode = false
    }

    private func selectWord(_ word: String) {
        guard !isReviewMode else { return }
        guard let target = selectedBlank ?? blankIndices.first(where: { filled[$0] == nil }) else { return }
        filled[target] = word
        selectedBlank = blankIndices.first(where: { filled[$0] == nil })
        feedback = nil
        isCorrect = false
    }

    private func checkAnswer() {
        if isReviewMode || isCorrect {
            onDone()
            return
        }
        guard blankIndices.allSatisfy({ filled[$0] != nil }) else {
            feedback = "Fill all the blanks first."
            isCorrect = false
            return
        }

        let ok = blankIndices.allSatisfy { idx in
            stripPunctuation(filled[idx] ?? "").caseInsensitiveCompare(stripPunctuation(displayTokens[idx])) == .orderedSame
        }

        if ok {
            isCorrect = true
            feedback = "Correct! Great memory."
            let mapped = Dictionary(uniqueKeysWithValues: filled.map { (String($0.key), $0.value) })
            let state = MemoryChallengeSavedState(
                displayTokens: displayTokens,
                blankIndices: blankIndices,
                wordBank: wordBank,
                filled: mapped
            )
            store.markMemoryCompleted(state: state)
            store.markVerseCompleted()
        } else {
            isCorrect = false
            feedback = "Not quite — try again."
        }
    }

    private func clearAnswers() {
        guard !isReviewMode else { return }
        filled = [:]
        selectedBlank = blankIndices.first
        feedback = nil
        isCorrect = false
    }

    private func revealHint() {
        guard !isReviewMode else { return }
        guard let idx = blankIndices.first(where: { filled[$0] == nil }) ?? blankIndices.first else { return }
        filled[idx] = stripPunctuation(displayTokens[idx])
        selectedBlank = blankIndices.first(where: { filled[$0] == nil })
    }

    private func stripPunctuation(_ value: String) -> String {
        value.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
}

/// Lays verse words out like normal reading text (wraps naturally).
private struct MemoryVerseFlowView: View {
    let tokens: [String]
    let blankIndices: [Int]
    let filled: [Int: String]
    let selectedBlank: Int?
    let isReviewMode: Bool
    let onTapBlank: (Int) -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            MemoryFlowLayout(spacing: 5, lineSpacing: 8) {
                wordViews
            }
        } else {
            // Older iOS: still prefer smaller adaptive chips over a wide 4-column grid.
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 36), spacing: 5, alignment: .leading)],
                alignment: .leading,
                spacing: 8
            ) {
                wordViews
            }
        }
    }

    @ViewBuilder
    private var wordViews: some View {
        ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
            if blankIndices.contains(index) {
                Button(action: {
                    if !isReviewMode { onTapBlank(index) }
                }) {
                    Text(filled[index] ?? "______")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(filled[index] == nil ? Color.black.opacity(0.35) : Color(hex: "1C46B2"))
                        .underline(color: selectedBlank == index ? Color(hex: "1C46B2") : Color.black.opacity(0.2))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isReviewMode)
            } else {
                Text(token + " ")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct MemoryFlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            maxX = max(maxX, x + size.width)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : maxX, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
