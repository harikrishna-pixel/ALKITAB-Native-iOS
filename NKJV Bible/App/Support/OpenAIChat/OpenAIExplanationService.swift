//
//  OpenAIExplanationService.swift
//  NKJV Bible
//

import Foundation

/// Verse / chapter AI explanations using the same OpenAI proxy as AI Chat.
final class OpenAIExplanationService {

    static let shared = OpenAIExplanationService()

    func fetchExplanation(
        verseReference: String,
        verseText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, OpenAIChatError>) -> Void
    ) {
        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise explanation of the following verse.

        Translation: \(bibleVersion)
        Verse reference: \(verseReference)
        Verse text: \(verseText)

        Respond in \(language) only. Do not use markdown or asterisks. Do not add a title or heading — give the explanation directly.
        """
        OpenAIChatService.shared.send(input: prompt, completion: completion)
    }

    func fetchChapterSummary(
        chapterReference: String,
        chapterText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, OpenAIChatError>) -> Void
    ) {
        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise summary of the following chapter.

        Translation: \(bibleVersion)
        Chapter: \(chapterReference)
        Chapter text: \(chapterText)

        Respond in \(language) only. Do not use markdown or asterisks. Do not add a title or heading — give the summary directly.
        """
        OpenAIChatService.shared.send(input: prompt, completion: completion)
    }
}
