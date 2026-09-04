//
//  ChallengeGameContent.swift
//  NKJV Bible
//

import Foundation

enum ChallengeKind: String, CaseIterable, Identifiable {
    case fillVerse
    case quickQuiz
    case verseMatch
    case trueFalse
    case wordSearch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quickQuiz: return "Quick Quiz"
        case .fillVerse: return "Fill the Verse"
        case .verseMatch: return "Verse Match"
        case .trueFalse: return "True or False"
        case .wordSearch: return "Word Search"
        }
    }

    var subtitle: String {
        switch self {
        case .quickQuiz: return "5 Questions"
        case .fillVerse: return "Fill in the missing words"
        case .verseMatch: return "Match verse with reference"
        case .trueFalse: return "Test your knowledge"
        case .wordSearch: return "Find hidden Bible words"
        }
    }

    var icon: String {
        switch self {
        case .quickQuiz: return "brain.head.profile"
        case .fillVerse: return "square.and.pencil"
        case .verseMatch: return "arrow.left.arrow.right"
        case .trueFalse: return "bolt.fill"
        case .wordSearch: return "magnifyingglass"
        }
    }

    var iconTintHex: String {
        switch self {
        case .quickQuiz: return "E85D4C"
        case .fillVerse: return "34C759"
        case .verseMatch: return "7B61FF"
        case .trueFalse: return "1C46B2"
        case .wordSearch: return "1C46B2"
        }
    }

    var iconBgHex: String {
        switch self {
        case .quickQuiz: return "FDECE9"
        case .fillVerse: return "E8F8EE"
        case .verseMatch: return "EEE8FF"
        case .trueFalse: return "E8EEFF"
        case .wordSearch: return "E8EEFF"
        }
    }

    var isPremium: Bool {
        switch self {
        case .fillVerse: return false
        case .quickQuiz, .verseMatch, .trueFalse, .wordSearch: return true
        }
    }

    /// Setup-sheet instruction under Easy / Medium / Hard (display only).
    func difficultyInstruction(for difficulty: ChallengeDifficulty) -> String {
        switch self {
        case .fillVerse:
            return difficulty.blankHint
        case .quickQuiz:
            switch difficulty {
            case .easy: return "Shorter multiple-choice questions"
            case .medium: return "Standard multiple-choice questions"
            case .hard: return "Tougher multiple-choice questions"
            }
        case .verseMatch:
            switch difficulty {
            case .easy: return "Match verses with their references"
            case .medium: return "Match more verse and reference pairs"
            case .hard: return "Match the full set of verse pairs"
            }
        case .trueFalse:
            switch difficulty {
            case .easy: return "Simpler true or false statements"
            case .medium: return "Standard true or false statements"
            case .hard: return "Harder true or false statements"
            }
        case .wordSearch:
            switch difficulty {
            case .easy: return "Find fewer hidden Bible words"
            case .medium: return "Find the hidden Bible words"
            case .hard: return "Find more hidden Bible words"
            }
        }
    }
}

struct ChallengeVerseContext {
    let reference: String
    let text: String

    static func loadToday() -> ChallengeVerseContext {
        let snap = DailyVerseSnapshot.loadCurrent()
        return ChallengeVerseContext(reference: snap.reference, text: snap.text)
    }

    static func loadChapter(book: String, chapter: Int) -> ChallengeVerseContext {
        let chapterIndex = chapter > 0 ? chapter - 1 : chapter
        let displayChapter = chapter > 0 ? chapter : chapter + 1
        let list = BibleContent.sharedInstance.AudioBibleList(
            selecterBookName: book,
            selectedId: max(0, chapterIndex)
        )
        let text = list.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return ChallengeVerseContext(reference: "\(book) \(displayChapter):1", text: text)
    }

    var words: [String] {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 3 }
    }

    var significantWords: [String] {
        let stop: Set<String> = [
            "the", "and", "for", "that", "with", "from", "this", "have", "will",
            "shall", "unto", "they", "them", "their", "your", "you", "are", "was",
            "were", "been", "being", "not", "but", "his", "her", "him", "she", "who"
        ]
        return words.filter { !stop.contains($0.lowercased()) }
    }
}

struct QuickQuizQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
}

struct TrueFalseQuestion: Identifiable {
    let id = UUID()
    let statement: String
    let isTrue: Bool
}

struct VerseMatchPair: Identifiable {
    let id = UUID()
    let verse: String
    let reference: String
}

enum ChallengeGameFactory {

    static var hasPremiumAccess: Bool {
        // paymentInfo() == false means subscribed / ads off
        !PaymentHistory.sharedInstance.paymentInfo()
    }

    static func quickQuiz(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> [QuickQuizQuestion] {
        if let config {
            return chapterQuickQuiz(config: config, fallback: ctx)
        }
        let book = ctx.reference.components(separatedBy: " ").first ?? ctx.reference
        let words = Array(ctx.significantWords.prefix(8))
        let keyWord = words.first ?? "faith"
        let distractors = ["Moses", "Aaron", "Joshua", "David", "Peter", "Paul", "John", "Abraham"]

        var questions: [QuickQuizQuestion] = []

        questions.append(
            QuickQuizQuestion(
                prompt: "Which book does today's verse come from?",
                options: uniqueOptions(
                    correct: book.isEmpty ? "Bible" : book,
                    pool: localizedBookNames(excluding: book) + [book]
                ),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "What is today's verse reference?",
                options: uniqueOptions(
                    correct: ctx.reference,
                    pool: localizedReferencePool(excluding: ctx.reference) + [ctx.reference]
                ),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "Which word appears in today's verse?",
                options: uniqueOptions(correct: keyWord.capitalized, pool: distractors + [keyWord.capitalized]),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "Today's verse encourages us to grow in God's Word. What should we do?",
                options: [
                    "Read and reflect on Scripture",
                    "Ignore the verse",
                    "Skip reading today",
                    "Avoid prayer"
                ],
                correctIndex: 0
            )
        )

        let snippet = String(ctx.text.prefix(60))
        let wrongSnippets = [
            localizedVerseSnippet(bookId: 1, chapter: 1, verse: 1),
            localizedVerseSnippet(bookId: 19, chapter: 23, verse: 1),
            localizedVerseSnippet(bookId: 43, chapter: 3, verse: 16)
        ].filter { !$0.isEmpty }
        questions.append(
            QuickQuizQuestion(
                prompt: "Which line matches today's verse?",
                options: uniqueOptions(
                    correct: snippet.isEmpty ? ctx.text : snippet + (ctx.text.count > 60 ? "…" : ""),
                    pool: [
                        snippet.isEmpty ? ctx.text : snippet + (ctx.text.count > 60 ? "…" : ""),
                    ] + wrongSnippets
                ),
                correctIndex: 0
            )
        )

        return Array(questions.prefix(5)).map { q in
            let shuffled = q.options.shuffled()
            let idx = shuffled.firstIndex(of: q.options[q.correctIndex]) ?? 0
            return QuickQuizQuestion(prompt: q.prompt, options: shuffled, correctIndex: idx)
        }
    }

    static func trueFalse(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> [TrueFalseQuestion] {
        if let config {
            return chapterTrueFalse(config: config, fallback: ctx)
        }
        let book = ctx.reference.components(separatedBy: " ").first ?? ""
        return [
            TrueFalseQuestion(statement: "Today's verse is from \(ctx.reference).", isTrue: true),
            TrueFalseQuestion(statement: "Today's verse text is empty.", isTrue: ctx.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty),
            TrueFalseQuestion(statement: "This verse is from the book of \(book.isEmpty ? "Scripture" : book).", isTrue: true),
            TrueFalseQuestion(statement: "Today's verse is from Revelation 99:99.", isTrue: false),
            TrueFalseQuestion(statement: "Reading Scripture helps us grow in God's Word.", isTrue: true)
        ]
    }

    static func matchPairs(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> [VerseMatchPair] {
        if let config {
            return chapterMatchPairs(config: config, fallback: ctx)
        }
        let extras: [(String, String)] = [
            ("God is love.", "1 John 4:8"),
            ("I can do all things through Christ who strengthens me.", "Philippians 4:13"),
            ("The Lord is my shepherd.", "Psalm 23:1")
        ]
        var pairs = [VerseMatchPair(verse: shortVerse(ctx.text), reference: ctx.reference)]
        for e in extras where e.1 != ctx.reference {
            pairs.append(VerseMatchPair(verse: e.0, reference: e.1))
            if pairs.count == 3 { break }
        }
        return pairs
    }

    static func fillChallenge(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> (tokens: [String], blankIndices: [Int], bank: [String]) {
        let blankLimit: Int
        if let config {
            blankLimit = config.difficulty.blankCount
        } else {
            blankLimit = 2
        }
        let tokens = ctx.text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
        let candidates = tokens.enumerated().compactMap { idx, word -> Int? in
            let clean = word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            return clean.count >= 4 ? idx : nil
        }
        let blanks = Array(candidates.shuffled().prefix(min(blankLimit, candidates.count))).sorted()
        var bank = blanks.map { tokens[$0].trimmingCharacters(in: CharacterSet.alphanumerics.inverted) }

        // Distractors from the same verse/chapter language (not hardcoded English).
        let blankIndexSet = Set(blanks)
        var distractors: [String] = []
        func consider(_ raw: String) {
            let clean = raw.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            guard clean.count >= 4 else { return }
            let inBank = bank.contains { $0.caseInsensitiveCompare(clean) == .orderedSame }
            let inPool = distractors.contains { $0.caseInsensitiveCompare(clean) == .orderedSame }
            guard !inBank, !inPool else { return }
            distractors.append(clean)
        }
        for (idx, word) in tokens.enumerated() where !blankIndexSet.contains(idx) {
            consider(word)
        }
        if distractors.count < max(0, 6 - bank.count), let config {
            for verse in config.chapterVerses() {
                for word in verse.text
                    .replacingOccurrences(of: "\n", with: " ")
                    .components(separatedBy: " ")
                    .filter({ !$0.isEmpty }) {
                    consider(word)
                    if distractors.count >= 12 { break }
                }
                if distractors.count >= 12 { break }
            }
        }
        bank.append(contentsOf: distractors.shuffled().prefix(max(0, 6 - bank.count)))
        return (tokens, blanks, bank.shuffled())
    }

    static func wordSearchWords(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> [String] {
        let targetCount = config?.wordSearchCount ?? 5
        let defaults = ["FAITH", "GRACE", "LOVE", "PEACE", "HOPE"]
        var picked = ctx.significantWords
            .map { $0.uppercased().trimmingCharacters(in: CharacterSet.alphanumerics.inverted) }
            .filter { (4...8).contains($0.count) }
        picked = Array(Set(picked)).prefix(targetCount).map { $0 }
        if picked.count < targetCount {
            for d in defaults where !picked.contains(d) {
                picked.append(d)
                if picked.count == targetCount { break }
            }
        }
        return Array(picked.prefix(targetCount))
    }

    private static func chapterQuickQuiz(config: ChallengeSessionConfig, fallback: ChallengeVerseContext) -> [QuickQuizQuestion] {
        let verses = config.chapterVerses()
        let pool = verses.isEmpty ? [fallback] : verses
        var questions: [QuickQuizQuestion] = []
        var verseIndex = 0

        while questions.count < config.quickQuizCount {
            let ctx = pool[verseIndex % pool.count]
            let batch = quickQuiz(from: ctx)
            for question in batch where questions.count < config.quickQuizCount {
                questions.append(question)
            }
            verseIndex += 1
            if verseIndex > pool.count * 4 { break }
        }
        return Array(questions.prefix(config.quickQuizCount))
    }

    private static func chapterTrueFalse(config: ChallengeSessionConfig, fallback: ChallengeVerseContext) -> [TrueFalseQuestion] {
        let verses = config.chapterVerses(minWords: 4)
        let pool = verses.isEmpty ? [fallback] : verses
        var questions: [TrueFalseQuestion] = []

        for (index, ctx) in pool.enumerated() {
            let book = ctx.reference.components(separatedBy: " ").first ?? ""
            questions.append(TrueFalseQuestion(statement: "This verse is from \(ctx.reference).", isTrue: true))
            questions.append(TrueFalseQuestion(statement: "This verse is from Revelation 99:99.", isTrue: false))
            questions.append(TrueFalseQuestion(statement: "The verse \"\(shortVerse(ctx.text))\" is from \(book).", isTrue: true))
            questions.append(TrueFalseQuestion(statement: "Verse \(index + 1) in this chapter is empty.", isTrue: ctx.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
            if questions.count >= config.trueFalseCount { break }
        }

        if questions.count < config.trueFalseCount {
            questions.append(contentsOf: trueFalse(from: fallback).prefix(config.trueFalseCount - questions.count))
        }
        return Array(questions.prefix(config.trueFalseCount))
    }

    private static func chapterMatchPairs(config: ChallengeSessionConfig, fallback: ChallengeVerseContext) -> [VerseMatchPair] {
        let verses = config.chapterVerses(minWords: 4)
        var pairs = verses.map { VerseMatchPair(verse: shortVerse($0.text), reference: $0.reference) }
        if pairs.isEmpty {
            pairs = matchPairs(from: fallback)
        }
        while pairs.count < config.verseMatchCount {
            let extras: [(String, String)] = [
                ("God is love.", "1 John 4:8"),
                ("I can do all things through Christ who strengthens me.", "Philippians 4:13"),
                ("The Lord is my shepherd.", "Psalm 23:1"),
                ("For God so loved the world.", "John 3:16"),
                ("Be still, and know that I am God.", "Psalm 46:10")
            ]
            for extra in extras where !pairs.contains(where: { $0.reference == extra.1 }) {
                pairs.append(VerseMatchPair(verse: extra.0, reference: extra.1))
                if pairs.count == config.verseMatchCount { break }
            }
            break
        }
        return Array(pairs.prefix(config.verseMatchCount))
    }

    private static func shortVerse(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count <= 70 { return t }
        return String(t.prefix(67)) + "…"
    }

    private static func localizedBookNames(excluding: String? = nil) -> [String] {
        BibleContent.sharedInstance.BookToPosition()
            .map { $0.components(separatedBy: "-")[0] }
            .filter { name in
                guard let excluding = excluding else { return true }
                return name.caseInsensitiveCompare(excluding) != .orderedSame
            }
    }

    private static func localizedReference(bookId: Int, chapter: Int, verse: Int) -> String? {
        let books = BibleContent.sharedInstance.BookToPosition()
        let idx = bookId - 1
        guard idx >= 0, idx < books.count else { return nil }
        let name = books[idx].components(separatedBy: "-")[0]
        return "\(name) \(chapter):\(verse)"
    }

    private static func localizedReferencePool(excluding: String) -> [String] {
        let samples: [(Int, Int, Int)] = [
            (1, 1, 1),
            (19, 23, 1),
            (43, 3, 16),
            (50, 4, 13),
            (45, 8, 28)
        ]
        return samples.compactMap { localizedReference(bookId: $0.0, chapter: $0.1, verse: $0.2) }
            .filter { $0.caseInsensitiveCompare(excluding) != .orderedSame }
    }

    private static func localizedVerseSnippet(bookId: Int, chapter: Int, verse: Int) -> String {
        let books = BibleContent.sharedInstance.BookToPosition()
        let idx = bookId - 1
        guard idx >= 0, idx < books.count else { return "" }
        let name = books[idx].components(separatedBy: "-")[0]
        let verses = BibleContent.sharedInstance.AudioBibleList(
            selecterBookName: name,
            selectedId: max(0, chapter - 1)
        )
        let vIdx = max(0, verse - 1)
        guard vIdx < verses.count else { return "" }
        let text = verses[vIdx].trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count <= 60 { return text }
        return String(text.prefix(60)) + "…"
    }

    private static func uniqueOptions(correct: String, pool: [String]) -> [String] {
        var result = [correct]
        for item in pool where item.caseInsensitiveCompare(correct) != .orderedSame {
            if !result.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame }) {
                result.append(item)
            }
            if result.count == 4 { break }
        }
        while result.count < 4 {
            result.append("Option \(result.count + 1)")
        }
        return result
    }
}
