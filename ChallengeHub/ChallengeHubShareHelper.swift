//
//  ChallengeHubShareHelper.swift
//  NKJV Bible
//
//  Creates a remote challenge when a Challenge Hub game starts,
//  and opens SharedViewController with the returned shareUrl.
//

import Foundation
import UIKit
import Combine

final class ChallengeShareSession: ObservableObject {

    @Published var shareUrl: String?
    @Published var isCreating = false
    @Published var createdChallengeId: String?
    @Published var createError: String?

    private(set) var challengeTitle: String = ""
    private var lastPayload: [ChallengeQuestionPayload] = []
    private var lastKind: ChallengeKind?

    /// Creates (or reuses) a remote challenge. Always reports completion.
    func create(
        kind: ChallengeKind,
        verse: ChallengeVerseContext,
        questions: [ChallengeQuestionPayload],
        completion: ((Result<ChallengeSummary, CreatorChallengeError>) -> Void)? = nil
    ) {
        guard !questions.isEmpty else {
            completion?(.failure(.apiError("No questions to create.")))
            return
        }
        if let existing = shareUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !existing.isEmpty,
           let id = createdChallengeId {
            completion?(.success(ChallengeSummary(
                id: id,
                title: challengeTitle,
                description: nil,
                totalQuestions: questions.count,
                status: "active",
                shareUrl: existing
            )))
            return
        }
        guard !isCreating else { return }

        isCreating = true
        createError = nil
        lastPayload = questions
        lastKind = kind
        let title = "\(verse.reference) Challenge"
        let description = "\(kind.title) · Challenge from \(APPNAME)"
        challengeTitle = title

        print("[CreatorChallenge] Creating \(kind.title) with \(questions.count) questions for \(verse.reference)")

        CreatorChallengeService.shared.createChallenge(
            title: title,
            description: description,
            contentType: kind.apiContentType,
            questions: questions
        ) { [weak self] result in
            guard let self = self else { return }
            self.isCreating = false
            switch result {
            case .success(let challenge):
                print("[CreatorChallenge] Created id=\(challenge.id) shareUrl=\(challenge.shareUrl ?? "")")
                self.shareUrl = challenge.shareUrl
                self.createdChallengeId = challenge.id
                completion?(.success(challenge))
            case .failure(let error):
                print("[CreatorChallenge] Create failed: \(error.localizedDescription)")
                self.createError = error.localizedDescription
                completion?(.failure(error))
            }
        }
    }

    func createIfNeeded(
        kind: ChallengeKind,
        verse: ChallengeVerseContext,
        questions: [ChallengeQuestionPayload]
    ) {
        create(kind: kind, verse: verse, questions: questions, completion: nil)
    }

    func resetCreatedChallenge() {
        shareUrl = nil
        createdChallengeId = nil
        createError = nil
        challengeTitle = ""
        isCreating = false
    }

    func presentShare(retryCreate: (() -> Void)? = nil) {
        let url = shareUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !url.isEmpty else {
            if isCreating {
                toast("Preparing share link…")
            } else {
                retryCreate?()
                toast("Preparing share link…")
            }
            return
        }

        DispatchQueue.main.async {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
            vc.VerseStr = "Can you beat my score on this Bible challenge?"
            vc.Bookname = self.challengeTitle
            vc.challengeShareUrl = url
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            top.present(vc, animated: true, completion: nil)
        }
    }

    private func toast(_ message: String) {
        DispatchQueue.main.async {
            OnboardingAuthManager.topViewController()?.view.makeToast(message, duration: 2.0, position: .bottom)
        }
    }
}

// MARK: - Map local games → API question payloads

enum ChallengeHubShareMapper {

    private static let optionIds = ["a", "b", "c", "d", "e", "f"]

    static func fromQuickQuiz(_ questions: [QuickQuizQuestion]) -> [ChallengeQuestionPayload] {
        CreatorChallengeService.shared.mapQuickQuizQuestions(questions)
    }

    static func fromTrueFalse(_ questions: [TrueFalseQuestion]) -> [ChallengeQuestionPayload] {
        questions.enumerated().map { index, q in
            ChallengeQuestionPayload(
                questionId: "q\(index + 1)",
                question: q.statement,
                options: [
                    ChallengeOptionPayload(id: "a", text: "True"),
                    ChallengeOptionPayload(id: "b", text: "False")
                ],
                correctAnswer: q.isTrue ? "a" : "b",
                explanation: nil
            )
        }
    }

    static func fromMatchPairs(_ pairs: [VerseMatchPair]) -> [ChallengeQuestionPayload] {
        let allRefs = pairs.map { $0.reference }
        return pairs.enumerated().map { index, pair in
            let options = uniqueOptions(correct: pair.reference, pool: allRefs)
            return ChallengeQuestionPayload(
                questionId: "q\(index + 1)",
                question: "Which reference matches this verse?\n\"\(pair.verse)\"",
                options: labeledOptions(options),
                correctAnswer: optionId(for: pair.reference, in: options),
                explanation: nil
            )
        }
    }

    static func fromFillRounds(_ rounds: [ChallengeVerseContext], sessionConfig: ChallengeSessionConfig?) -> [ChallengeQuestionPayload] {
        var payloads: [ChallengeQuestionPayload] = []
        for (roundIndex, ctx) in rounds.enumerated() {
            let data = ChallengeGameFactory.fillChallenge(from: ctx, config: sessionConfig)
            for (blankOffset, blankIdx) in data.blankIndices.enumerated() {
                guard blankIdx < data.tokens.count else { continue }
                let correct = data.tokens[blankIdx]
                    .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                guard !correct.isEmpty else { continue }
                let options = uniqueOptions(correct: correct, pool: data.bank + [correct])
                payloads.append(
                    ChallengeQuestionPayload(
                        questionId: "q\(payloads.count + 1)",
                        question: "Fill the blank (\(ctx.reference)) — word \(blankOffset + 1): which word belongs here?",
                        options: labeledOptions(options),
                        correctAnswer: optionId(for: correct, in: options),
                        explanation: nil
                    )
                )
            }
            if payloads.isEmpty {
                // Fallback so create still works even if no blanks
                payloads.append(
                    ChallengeQuestionPayload(
                        questionId: "q\(roundIndex + 1)",
                        question: "Which reference is this fill-in verse from?",
                        options: labeledOptions([ctx.reference, "Psalm 23:1", "John 3:16", "Genesis 1:1"]),
                        correctAnswer: "a",
                        explanation: nil
                    )
                )
            }
        }
        return payloads
    }

    static func fromWordSearch(words: [String], verse: ChallengeVerseContext) -> [ChallengeQuestionPayload] {
        let pool = words.isEmpty
            ? ["FAITH", "GRACE", "LOVE", "PEACE", "HOPE"]
            : words
        let distractors = ["FAITH", "GRACE", "LOVE", "PEACE", "HOPE", "MERCY", "TRUTH", "LIGHT"]
        return pool.enumerated().map { index, word in
            let options = uniqueOptions(correct: word, pool: distractors + pool)
            return ChallengeQuestionPayload(
                questionId: "q\(index + 1)",
                question: "Which word is hidden in the Word Search for \(verse.reference)?",
                options: labeledOptions(options),
                correctAnswer: optionId(for: word, in: options),
                explanation: nil
            )
        }
    }

    // MARK: - Option helpers

    private static func uniqueOptions(correct: String, pool: [String]) -> [String] {
        var result: [String] = [correct]
        for item in pool.shuffled() {
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let exists = result.contains { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
            if !exists {
                result.append(trimmed)
            }
            if result.count >= 4 { break }
        }
        while result.count < 2 {
            result.append("Option \(result.count + 1)")
        }
        return result.shuffled()
    }

    private static func labeledOptions(_ texts: [String]) -> [ChallengeOptionPayload] {
        texts.enumerated().compactMap { index, text in
            guard index < optionIds.count else { return nil }
            return ChallengeOptionPayload(id: optionIds[index], text: text)
        }
    }

    private static func optionId(for text: String, in options: [String]) -> String {
        if let idx = options.firstIndex(where: { $0.caseInsensitiveCompare(text) == .orderedSame }),
           idx < optionIds.count {
            return optionIds[idx]
        }
        return "a"
    }
}
