//
//  ChallengeVerseDeepPlayChrome.swift
//  NKJV Bible
//
//  VerseDeep-style play UI: progress, options, green Correct bar, Next/Finish.
//

import SwiftUI

struct ChallengeVerseDeepPlayQuestion: Identifiable {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
}

struct ChallengeVerseDeepPlayView: View {
    let title: String
    let questions: [ChallengeVerseDeepPlayQuestion]
    let shareSession: ChallengeShareSession
    var onDone: () -> Void
    var onPlayAgain: () -> Void
    var onShare: (() -> Void)? = nil

    @State private var index = 0
    @State private var selected: Int?
    @State private var revealed = false
    @State private var score = 0
    @State private var finished = false
    @State private var startedAt = Date()
    @State private var elapsed: TimeInterval = 0
    @State private var scoredIDs: Set<String> = []

    var body: some View {
        Group {
            if finished {
                ChallengeVerseDeepResultView(
                    correct: score,
                    total: questions.count,
                    elapsed: elapsed,
                    challengeTitle: title,
                    onPlayAgain: {
                        reset()
                        onPlayAgain()
                    },
                    onShare: { onShare?() ?? shareSession.presentShare() },
                    onDone: onDone
                )
            } else if questions.indices.contains(index) {
                playBody(questions[index])
            } else {
                Color.white.ignoresSafeArea()
            }
        }
    }

    private func playBody(_ q: ChallengeVerseDeepPlayQuestion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Button(action: onDone) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(width: 36, height: 36)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)

            Text("\(index + 1) of \(questions.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)

            progressBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(q.prompt)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .fixedSize(horizontal: false, vertical: true)

                    if usesWordGrid(q.options) {
                        wordGrid(q)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                                letterOption(option, index: i, correct: q.correctIndex)
                            }
                        }
                    }

                    if revealed {
                        feedbackCard(correct: selected == q.correctIndex)
                    }

                    HStack {
                        if index > 0 {
                            Button(action: { goPrevious() }) {
                                Text("‹  Previous")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(ChallengeVerseDeepTheme.blue)
                            }
                        }
                        Spacer(minLength: 0)
                        if revealed {
                            Button(action: { advance(from: q) }) {
                                Text(index + 1 >= questions.count ? "Finish" : "Next  ›")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .background(ChallengeVerseDeepTheme.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, Self.statusBarHeight)
        .ignoresSafeArea(edges: .top)
        .background(Color.white.ignoresSafeArea())
    }

    /// Last question uses the shorter line from the play mock. Earlier questions include the challenge name.
    private var correctDetail: String {
        if index + 1 >= questions.count { return "Great job!" }
        return "Well done! \(title)"
    }

    /// One status-bar inset only. The hosting controller was stacking extra top space above the title.
    private static var statusBarHeight: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.top ?? 54
    }

    /// Fixed-height bar. A free GeometryReader in the stack was stretching and opening the gap under the title.
    private var progressBar: some View {
        Capsule()
            .fill(Color(hex: "E8EEFF"))
            .frame(height: 8)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    Capsule()
                        .fill(ChallengeVerseDeepTheme.blue)
                        .frame(width: max(8, geo.size.width * CGFloat(index + 1) / CGFloat(max(questions.count, 1))))
                }
            }
            .clipShape(Capsule())
    }

    private func usesWordGrid(_ options: [String]) -> Bool {
        options.count <= 4 && options.allSatisfy { option in
            option.split(separator: " ").count <= 2 && option.count <= 18
        }
    }

    private func wordGrid(_ q: ChallengeVerseDeepPlayQuestion) -> some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                wordChip(option, index: i, correct: q.correctIndex)
            }
        }
    }

    private func wordChip(_ title: String, index i: Int, correct: Int) -> some View {
        let isSelected = selected == i
        let showCorrect = revealed && i == correct
        let showWrong = revealed && isSelected && i != correct
        return Button(action: { choose(i, questionID: questions[index].id, correct: correct) }) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Spacer()
                if showCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ChallengeVerseDeepTheme.green)
                }
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(showCorrect ? ChallengeVerseDeepTheme.greenBg : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        showCorrect ? ChallengeVerseDeepTheme.green :
                            (showWrong ? Color(hex: "D70015") : Color.black.opacity(0.08)),
                        lineWidth: showCorrect || showWrong ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(revealed)
    }

    private func feedbackCard(correct: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(correct ? ChallengeVerseDeepTheme.green : Color(hex: "D70015"))
            VStack(alignment: .leading, spacing: 2) {
                Text(correct ? "Correct!" : "Not quite")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(correct ? Color(hex: "1B7F3A") : Color(hex: "D70015"))
                Text(correct ? correctDetail : "Review the highlighted answer.")
                    .font(.system(size: 14))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep.opacity(0.7))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(correct ? ChallengeVerseDeepTheme.greenBg : Color(hex: "FDECEC"))
        )
    }

    private func letterOption(_ title: String, index i: Int, correct: Int) -> some View {
        let isSelected = selected == i
        let showCorrect = revealed && i == correct
        let showWrong = revealed && isSelected && i != correct
        let letters = ["A", "B", "C", "D", "E", "F"]
        let letter = i < letters.count ? letters[i] : "\(i + 1)"

        return Button(action: {
            choose(i, questionID: questions.indices.contains(index) ? questions[index].id : "", correct: correct)
        }) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(showCorrect || isSelected ? ChallengeVerseDeepTheme.blue : ChallengeVerseDeepTheme.muted)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.black.opacity(0.05)))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ChallengeVerseDeepTheme.green)
                } else if showWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "D70015"))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(showCorrect ? ChallengeVerseDeepTheme.greenBg : (showWrong ? Color(hex: "FDECEC") : Color.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        showCorrect ? ChallengeVerseDeepTheme.green :
                            (showWrong ? Color(hex: "D70015") :
                                (isSelected ? ChallengeVerseDeepTheme.blue : ChallengeVerseDeepTheme.cardBorder)),
                        lineWidth: isSelected || revealed ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(revealed)
    }

    private func choose(_ option: Int, questionID: String, correct: Int) {
        guard !revealed else { return }
        selected = option
        revealed = true
        if option == correct, scoredIDs.insert(questionID).inserted {
            score += 1
        }
    }

    private func advance(from q: ChallengeVerseDeepPlayQuestion) {
        if index + 1 >= questions.count {
            elapsed = Date().timeIntervalSince(startedAt)
            finished = true
        } else {
            index += 1
            selected = nil
            revealed = false
        }
    }

    private func goPrevious() {
        guard index > 0 else { return }
        index -= 1
        selected = nil
        revealed = false
    }

    private func reset() {
        index = 0
        selected = nil
        revealed = false
        score = 0
        finished = false
        startedAt = Date()
        elapsed = 0
        scoredIDs = []
    }
}

enum ChallengeVerseDeepQuestionBuilder {
    static func build(
        kind: ChallengeKind,
        verse: ChallengeVerseContext,
        config: ChallengeSessionConfig
    ) -> [ChallengeVerseDeepPlayQuestion] {
        switch kind {
        case .quickQuiz:
            return ChallengeGameFactory.quickQuiz(from: verse, config: config).enumerated().map { i, q in
                ChallengeVerseDeepPlayQuestion(
                    id: "q\(i + 1)",
                    prompt: q.prompt,
                    options: q.options,
                    correctIndex: q.correctIndex
                )
            }
        case .trueFalse:
            return ChallengeGameFactory.trueFalse(from: verse, config: config).enumerated().map { i, q in
                ChallengeVerseDeepPlayQuestion(
                    id: "q\(i + 1)",
                    prompt: q.statement,
                    options: ["True", "False"],
                    correctIndex: q.isTrue ? 0 : 1
                )
            }
        case .verseMatch:
            let pairs = ChallengeGameFactory.matchPairs(from: verse, config: config)
            let refs = pairs.map { $0.reference }
            return pairs.enumerated().map { i, pair in
                var opts = Array(Set(refs)).shuffled()
                if !opts.contains(pair.reference) { opts.insert(pair.reference, at: 0) }
                opts = Array(opts.prefix(4))
                if let idx = opts.firstIndex(of: pair.reference) {
                    return ChallengeVerseDeepPlayQuestion(
                        id: "q\(i + 1)",
                        prompt: "Which reference matches this verse?\n\"\(pair.verse)\"",
                        options: opts,
                        correctIndex: idx
                    )
                }
                return ChallengeVerseDeepPlayQuestion(
                    id: "q\(i + 1)",
                    prompt: "Which reference matches this verse?\n\"\(pair.verse)\"",
                    options: [pair.reference] + opts.filter { $0 != pair.reference }.prefix(3),
                    correctIndex: 0
                )
            }
        case .fillVerse:
            return fillQuestions(verse: verse, config: config)
        case .wordSearch:
            let words = ChallengeGameFactory.wordSearchWords(from: verse, config: config)
            let pool = words.isEmpty ? ["FAITH", "GRACE", "LOVE", "PEACE"] : words
            let distractors = ["FAITH", "GRACE", "LOVE", "PEACE", "MERCY", "TRUTH", "LIGHT", "HOPE"]
            return pool.prefix(config.wordSearchCount).enumerated().map { i, word in
                var opts = Array(Set([word] + distractors.filter { $0 != word }.prefix(3))).shuffled()
                if !opts.contains(word) { opts.insert(word, at: 0) }
                let correct = opts.firstIndex(of: word) ?? 0
                return ChallengeVerseDeepPlayQuestion(
                    id: "q\(i + 1)",
                    prompt: "Which word is found in \(verse.reference)?",
                    options: Array(opts.prefix(4)),
                    correctIndex: correct
                )
            }
        }
    }

    private static func fillQuestions(verse: ChallengeVerseContext, config: ChallengeSessionConfig) -> [ChallengeVerseDeepPlayQuestion] {
        var out: [ChallengeVerseDeepPlayQuestion] = []
        let rounds = Array(config.chapterVerses().shuffled().prefix(config.fillQuestionCount))
        let source = rounds.isEmpty ? [verse] : rounds
        for (ri, ctx) in source.enumerated() {
            let data = ChallengeGameFactory.fillChallenge(from: ctx, config: config)
            for (bi, blankIdx) in data.blankIndices.enumerated() {
                guard blankIdx < data.tokens.count else { continue }
                let correct = data.tokens[blankIdx].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                guard !correct.isEmpty else { continue }
                var opts = Array(Set([correct] + data.bank.filter { $0.caseInsensitiveCompare(correct) != .orderedSame }.prefix(3)))
                opts.shuffle()
                if let idx = opts.firstIndex(where: { $0.caseInsensitiveCompare(correct) == .orderedSame }) {
                    let blanked = data.tokens.enumerated().map { i, t in
                        data.blankIndices.contains(i) && i == blankIdx ? "______" : t
                    }.joined(separator: " ")
                    out.append(ChallengeVerseDeepPlayQuestion(
                        id: "q\(out.count + 1)",
                        prompt: blanked,
                        options: opts,
                        correctIndex: idx
                    ))
                }
                if out.count >= config.fillQuestionCount { return out }
            }
            if out.isEmpty {
                out.append(ChallengeVerseDeepPlayQuestion(
                    id: "q\(ri + 1)",
                    prompt: "Which reference is this verse from?",
                    options: [ctx.reference, "Psalm 23:1", "John 3:16", "Genesis 1:1"],
                    correctIndex: 0
                ))
            }
            if out.count >= config.fillQuestionCount { break }
        }
        return Array(out.prefix(config.fillQuestionCount))
    }

    static func apiPayload(from questions: [ChallengeVerseDeepPlayQuestion]) -> [ChallengeQuestionPayload] {
        let ids = ["a", "b", "c", "d", "e", "f"]
        return questions.enumerated().map { index, q in
            let options = q.options.enumerated().compactMap { i, text -> ChallengeOptionPayload? in
                guard i < ids.count else { return nil }
                return ChallengeOptionPayload(id: ids[i], text: text)
            }
            let correct = (q.correctIndex >= 0 && q.correctIndex < ids.count) ? ids[q.correctIndex] : "a"
            return ChallengeQuestionPayload(
                questionId: q.id.isEmpty ? "q\(index + 1)" : q.id,
                question: q.prompt,
                options: options,
                correctAnswer: correct,
                explanation: nil
            )
        }
    }
}
