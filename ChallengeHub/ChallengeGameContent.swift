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

    /// Value sent as `contentType` on POST /api/challenges.
    var apiContentType: String {
        switch self {
        case .quickQuiz: return "quiz"
        case .trueFalse: return "true_or_false"
        case .wordSearch: return "word_search"
        case .fillVerse: return "fill_verse"
        case .verseMatch: return "verse_match"
        }
    }

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
        var source = QuickQuizSource()
        if let config {
            return chapterQuickQuiz(config: config, fallback: ctx, source: &source)
        }
        return shuffledQuickQuiz(singleVerseQuickQuiz(from: ctx, source: &source))
    }

    /// Questions for one verse (used for both single-verse and chapter pools).
    private static func singleVerseQuickQuiz(from ctx: ChallengeVerseContext, source: inout QuickQuizSource) -> [QuickQuizQuestion] {
        let book = ctx.reference.components(separatedBy: " ").first ?? ctx.reference
        let words = Array(ctx.significantWords.prefix(8))
        let keyWord = words.first ?? "faith"
        // Prefer other words from the same verse as distractors (keeps language consistent).
        let verseDistractors = words
            .dropFirst()
            .map { $0.capitalized }
        let fallbackDistractors = ["Moses", "Aaron", "Joshua", "David", "Peter", "Paul", "John", "Abraham"]
        let distractors = verseDistractors.isEmpty ? fallbackDistractors : Array(verseDistractors) + fallbackDistractors

        var questions: [QuickQuizQuestion] = []

        questions.append(
            QuickQuizQuestion(
                prompt: "Which book does this verse come from?",
                options: uniqueOptions(
                    correct: book.isEmpty ? "Bible" : book,
                    pool: source.bookNames(excluding: book) + [book]
                ),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "What is this verse reference?",
                options: uniqueOptions(
                    correct: ctx.reference,
                    pool: source.referencePool(excluding: ctx.reference) + [ctx.reference]
                ),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "Which word appears in this verse?",
                options: uniqueOptions(correct: keyWord.capitalized, pool: distractors + [keyWord.capitalized]),
                correctIndex: 0
            )
        )

        questions.append(
            QuickQuizQuestion(
                prompt: "This verse encourages us to grow in God's Word. What should we do?",
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
            source.verseSnippet(bookId: 1, chapter: 1, verse: 1),
            source.verseSnippet(bookId: 19, chapter: 23, verse: 1),
            source.verseSnippet(bookId: 43, chapter: 3, verse: 16)
        ].filter { !$0.isEmpty }
        questions.append(
            QuickQuizQuestion(
                prompt: "Which line matches this verse?",
                options: uniqueOptions(
                    correct: snippet.isEmpty ? ctx.text : snippet + (ctx.text.count > 60 ? "…" : ""),
                    pool: [
                        snippet.isEmpty ? ctx.text : snippet + (ctx.text.count > 60 ? "…" : ""),
                    ] + wrongSnippets
                ),
                correctIndex: 0
            )
        )

        return Array(questions.prefix(5))
    }

    private static func shuffledQuickQuiz(_ questions: [QuickQuizQuestion]) -> [QuickQuizQuestion] {
        questions.map { q in
            let shuffled = q.options.shuffled()
            let idx = shuffled.firstIndex(of: q.options[q.correctIndex]) ?? 0
            return QuickQuizQuestion(prompt: q.prompt, options: shuffled, correctIndex: idx)
        }
    }

    static func trueFalse(from ctx: ChallengeVerseContext, config: ChallengeSessionConfig? = nil) -> [TrueFalseQuestion] {
        if let config {
            return chapterTrueFalse(config: config, fallback: ctx)
        }
        var questions: [TrueFalseQuestion] = []
        if let q = verseTextStatement(for: ctx, makeTrue: true, otherWords: []) {
            questions.append(q)
        }
        if let q = verseTextStatement(for: ctx, makeTrue: false, otherWords: ["mountain", "silver", "river", "garden", "morning", "kingdom"]) {
            questions.append(q)
        }
        questions.append(TrueFalseQuestion(statement: "Reading Scripture helps us grow in God's Word.", isTrue: true))
        questions.append(TrueFalseQuestion(statement: "Prayer is a way to talk with God.", isTrue: true))
        questions.append(TrueFalseQuestion(statement: "The Bible teaches us to ignore those in need.", isTrue: false))
        return questions
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
        var sourceWords = ctx.significantWords
        if let config {
            // Pull words from the chosen chapter, not only the first/daily verse.
            let chapterWords = config.chapterVerses(minWords: 1).flatMap { $0.significantWords }
            if !chapterWords.isEmpty {
                sourceWords = chapterWords
            }
        }
        var picked = sourceWords
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

    private static func chapterQuickQuiz(config: ChallengeSessionConfig, fallback: ChallengeVerseContext, source: inout QuickQuizSource) -> [QuickQuizQuestion] {
        let verses = config.chapterVerses()
        let pool = verses.isEmpty ? [fallback] : verses
        var questions: [QuickQuizQuestion] = []
        var skipped: [QuickQuizQuestion] = []
        var usedKeys = Set<String>()

        // Same prompt + same answer (e.g. "Which book…?" for every verse) counts as a repeat.
        func key(_ q: QuickQuizQuestion) -> String {
            let answer = q.options.indices.contains(q.correctIndex) ? q.options[q.correctIndex] : ""
            return (q.prompt + "|" + answer).lowercased()
        }

        for ctx in pool.shuffled() {
            // Build from the chosen chapter verse — do not use the daily-verse-only path.
            for question in shuffledQuickQuiz(singleVerseQuickQuiz(from: ctx, source: &source)).shuffled() {
                if usedKeys.insert(key(question)).inserted {
                    questions.append(question)
                } else {
                    skipped.append(question)
                }
            }
            if questions.count >= config.quickQuizCount * 3 { break }
        }
        questions.shuffle()
        if questions.count < config.quickQuizCount {
            questions.append(contentsOf: skipped.prefix(config.quickQuizCount - questions.count))
        }
        return Array(questions.prefix(config.quickQuizCount))
    }

    private static func chapterTrueFalse(config: ChallengeSessionConfig, fallback: ChallengeVerseContext) -> [TrueFalseQuestion] {
        let verses = config.chapterVerses(minWords: 4)
        let pool = verses.isEmpty ? [fallback] : verses
        let chapterWords = pool.flatMap { $0.significantWords }
        var questions: [TrueFalseQuestion] = []
        let shuffledPool = pool.shuffled()

        // One statement per verse first, so the same wording is not repeated within the set.
        // A second pass only fills the set when the chapter has fewer verses than requested.
        for pass in 0..<2 {
            for (index, ctx) in shuffledPool.enumerated() where questions.count < config.trueFalseCount {
                let wantTrue = (index + pass) % 2 == 0
                if let q = verseTextStatement(for: ctx, makeTrue: wantTrue, otherWords: chapterWords) {
                    questions.append(q)
                }
            }
        }
        return Array(questions.shuffled().prefix(config.trueFalseCount))
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

    /// "This verse reads: …" — either the real wording (true) or with one word swapped (false).
    private static func verseTextStatement(for ctx: ChallengeVerseContext, makeTrue: Bool, otherWords: [String]) -> TrueFalseQuestion? {
        let shown = shortVerse(ctx.text)
        guard !shown.isEmpty else { return nil }
        if makeTrue {
            return TrueFalseQuestion(statement: "This verse reads: \"\(shown)\"", isTrue: true)
        }

        var tokens = shown.components(separatedBy: " ")
        let cleanSet = Set(ctx.words.map { $0.lowercased() })
        let candidates = tokens.indices.filter {
            tokens[$0].trimmingCharacters(in: CharacterSet.alphanumerics.inverted).count >= 4
        }
        guard let target = candidates.randomElement() else { return nil }
        let original = tokens[target].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard var replacement = otherWords.shuffled().first(where: {
            $0.count >= 4 && !cleanSet.contains($0.lowercased())
        }) else { return nil }

        replacement = original.first?.isUppercase == true ? replacement.capitalized : replacement.lowercased()
        tokens[target] = tokens[target].replacingOccurrences(of: original, with: replacement)
        return TrueFalseQuestion(statement: "This verse reads: \"\(tokens.joined(separator: " "))\"", isTrue: false)
    }

    private static func shortVerse(_ text: String) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count <= 70 { return t }
        return String(t.prefix(67)) + "…"
    }

    /// Book names and chapter text for one Quick Quiz build. The Bible file is read once per book list and once per chapter, not once per question.
    private struct QuickQuizSource {
        private var bookNames: [String]?
        private var chapters: [String: [String]] = [:]

        mutating func bookNames(excluding: String? = nil) -> [String] {
            names().filter { name in
                guard let excluding = excluding else { return true }
                return name.caseInsensitiveCompare(excluding) != .orderedSame
            }
        }

        mutating func referencePool(excluding: String) -> [String] {
            let samples: [(Int, Int, Int)] = [
                (1, 1, 1),
                (19, 23, 1),
                (43, 3, 16),
                (50, 4, 13),
                (45, 8, 28)
            ]
            return samples.compactMap { reference(bookId: $0.0, chapter: $0.1, verse: $0.2) }
                .filter { $0.caseInsensitiveCompare(excluding) != .orderedSame }
        }

        mutating func verseSnippet(bookId: Int, chapter: Int, verse: Int) -> String {
            let books = names()
            let idx = bookId - 1
            guard idx >= 0, idx < books.count else { return "" }
            let selectedId = max(0, chapter - 1)
            let key = "\(books[idx].lowercased())|\(selectedId)"
            if chapters[key] == nil {
                chapters[key] = BibleContent.sharedInstance.AudioBibleList(
                    selecterBookName: books[idx],
                    selectedId: selectedId
                )
            }
            let verses = chapters[key] ?? []
            let vIdx = max(0, verse - 1)
            guard vIdx < verses.count else { return "" }
            let text = verses[vIdx].trimmingCharacters(in: .whitespacesAndNewlines)
            if text.count <= 60 { return text }
            return String(text.prefix(60)) + "…"
        }

        private mutating func names() -> [String] {
            if let bookNames { return bookNames }
            let loaded = BibleContent.sharedInstance.BookToPosition().map { $0.components(separatedBy: "-")[0] }
            bookNames = loaded
            return loaded
        }

        private mutating func reference(bookId: Int, chapter: Int, verse: Int) -> String? {
            let books = names()
            let idx = bookId - 1
            guard idx >= 0, idx < books.count else { return nil }
            return "\(books[idx]) \(chapter):\(verse)"
        }
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
