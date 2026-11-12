//
//  OpenAIExplanationService.swift
//  NKJV Bible
//

import Foundation

/// Verse / chapter AI explanations using the same OpenAI proxy as AI Chat.
final class OpenAIExplanationService {

    static let shared = OpenAIExplanationService()

    private let cacheLock = NSLock()
    private var memoryCache: [String: String] = [:]
    private let diskKey = "OpenAIExplanationCacheV1"
    private let maxDiskEntries = 40
    /// Keeps chapter prompts smaller so summaries return faster and UI stays responsive.
    private let chapterTextCap = 6_000

    @discardableResult
    func fetchExplanation(
        verseReference: String,
        verseText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, OpenAIChatError>) -> Void
    ) -> URLSessionTask? {
        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let cacheKey = makeKey(
            kind: "explain",
            reference: verseReference,
            bibleVersion: bibleVersion,
            language: language
        )
        if let cached = cachedText(for: cacheKey) {
            DispatchQueue.main.async { completion(.success(cached)) }
            return nil
        }

        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise explanation of the following verse.

        Translation: \(bibleVersion)
        Verse reference: \(verseReference)
        Verse text: \(verseText)

        Respond in \(language) only. Do not use markdown or asterisks. Do not add a title or heading — give the explanation directly.
        """
        return OpenAIChatService.shared.send(input: prompt) { [weak self] result in
            if case .success(let text) = result {
                self?.store(text, for: cacheKey)
            }
            completion(result)
        }
    }

    @discardableResult
    func fetchChapterSummary(
        chapterReference: String,
        chapterText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, OpenAIChatError>) -> Void
    ) -> URLSessionTask? {
        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let capped = Self.cappedChapterText(chapterText, maxChars: chapterTextCap)
        let cacheKey = makeKey(
            kind: "summary",
            reference: chapterReference,
            bibleVersion: bibleVersion,
            language: language
        )
        if let cached = cachedText(for: cacheKey) {
            DispatchQueue.main.async { completion(.success(cached)) }
            return nil
        }

        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise summary of the following chapter.

        Translation: \(bibleVersion)
        Chapter: \(chapterReference)
        Chapter text: \(capped)

        Respond in \(language) only. Do not use markdown or asterisks. Do not add a title or heading — give the summary directly.
        """
        return OpenAIChatService.shared.send(input: prompt) { [weak self] result in
            if case .success(let text) = result {
                self?.store(text, for: cacheKey)
            }
            completion(result)
        }
    }

    /// Builds a numbered chapter string without joining the whole book when it is huge.
    static func numberedChapterText(verses: [String], maxChars: Int = 6_000) -> String {
        var out = ""
        out.reserveCapacity(min(maxChars + 80, 8_192))
        for (index, verse) in verses.enumerated() {
            let line = "\(index + 1). \(verse)"
            let extra = out.isEmpty ? line.count : line.count + 1
            if out.utf16.count + extra > maxChars {
                if !out.isEmpty {
                    out += "\n\n[Chapter continues; summarize from the verses above.]"
                }
                break
            }
            if !out.isEmpty { out += "\n" }
            out += line
        }
        return out
    }

    static func cappedChapterText(_ text: String, maxChars: Int) -> String {
        if text.utf16.count <= maxChars { return text }
        let end = text.index(text.startIndex, offsetBy: maxChars, limitedBy: text.endIndex) ?? text.endIndex
        var slice = String(text[..<end])
        if let lastNL = slice.lastIndex(of: "\n") {
            slice = String(slice[..<lastNL])
        }
        return slice + "\n\n[Chapter continues; summarize from the verses above.]"
    }

    // MARK: - Cache

    private func makeKey(kind: String, reference: String, bibleVersion: String, language: String) -> String {
        "\(kind)|\(bibleVersion)|\(reference)|\(language)"
    }

    private func cachedText(for key: String) -> String? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let hit = memoryCache[key], !hit.isEmpty { return hit }
        guard var disk = UserDefaults.standard.dictionary(forKey: diskKey) as? [String: String],
              let hit = disk[key], !hit.isEmpty else { return nil }
        memoryCache[key] = hit
        disk.removeValue(forKey: key)
        disk[key] = hit
        UserDefaults.standard.set(disk, forKey: diskKey)
        return hit
    }

    private func store(_ text: String, for key: String) {
        guard !text.isEmpty else { return }
        cacheLock.lock()
        memoryCache[key] = text
        cacheLock.unlock()
        // Disk write off the main thread so summary open/close never freezes UI.
        DispatchQueue.global(qos: .utility).async { [diskKey, maxDiskEntries] in
            var disk = UserDefaults.standard.dictionary(forKey: diskKey) as? [String: String] ?? [:]
            disk[key] = text
            if disk.count > maxDiskEntries {
                let drop = disk.count - maxDiskEntries
                for k in disk.keys.prefix(drop) {
                    disk.removeValue(forKey: k)
                }
            }
            UserDefaults.standard.set(disk, forKey: diskKey)
        }
    }
}
