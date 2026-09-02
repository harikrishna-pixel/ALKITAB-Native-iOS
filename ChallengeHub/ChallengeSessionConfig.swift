//
//  ChallengeSessionConfig.swift
//  NKJV Bible
//

import Foundation

enum ChallengeDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var blankHint: String {
        switch self {
        case .easy: return "2 Blanks to fill"
        case .medium: return "4 Blanks to fill"
        case .hard: return "6 Blanks to fill"
        }
    }

    var blankCount: Int {
        switch self {
        case .easy: return 2
        case .medium: return 4
        case .hard: return 6
        }
    }
}

struct ChallengeSessionConfig {
    let bookName: String
    let chapter: Int
    let difficulty: ChallengeDifficulty

    let quickQuizCount: Int
    let fillQuestionCount: Int
    let trueFalseCount: Int
    let verseMatchCount: Int
    let wordSearchCount: Int

    static func markAsRead(book: String, chapter: Int, difficulty: ChallengeDifficulty) -> ChallengeSessionConfig {
        ChallengeSessionConfig(
            bookName: book,
            chapter: chapter,
            difficulty: difficulty,
            quickQuizCount: 10,
            fillQuestionCount: 10,
            trueFalseCount: 10,
            verseMatchCount: 5,
            wordSearchCount: 5
        )
    }

    func bibleChapterIndex() -> Int {
        chapter > 0 ? chapter - 1 : chapter
    }

    func displayChapterNumber() -> Int {
        chapter > 0 ? chapter : chapter + 1
    }

    func primaryVerse() -> ChallengeVerseContext {
        chapterVerses(minWords: 1).first
            ?? ChallengeVerseContext(reference: "\(bookName) \(displayChapterNumber()):1", text: "")
    }

    func chapterVerses(minWords: Int = 12) -> [ChallengeVerseContext] {
        let list = BibleContent.sharedInstance.AudioBibleList(
            selecterBookName: bookName,
            selectedId: max(0, bibleChapterIndex())
        )
        let chapterNumber = displayChapterNumber()
        return list.enumerated().compactMap { index, text in
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let wordCount = trimmed.components(separatedBy: " ").filter { !$0.isEmpty }.count
            if minWords > 0, wordCount < minWords { return nil }
            return ChallengeVerseContext(
                reference: "\(bookName) \(chapterNumber):\(index + 1)",
                text: trimmed
            )
        }
    }
}

extension ChallengeKind {
    func subtitle(config: ChallengeSessionConfig?) -> String {
        guard let config else { return subtitle }
        switch self {
        case .quickQuiz:
            return "\(config.quickQuizCount) Questions"
        case .fillVerse:
            return "\(config.fillQuestionCount) Questions · \(config.difficulty.blankHint)"
        case .verseMatch:
            return "\(config.verseMatchCount) Pairs"
        case .trueFalse:
            return "\(config.trueFalseCount) Questions"
        case .wordSearch:
            return "\(config.wordSearchCount) Words"
        }
    }
}
