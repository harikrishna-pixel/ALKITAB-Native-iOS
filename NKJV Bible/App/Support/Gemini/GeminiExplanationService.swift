//
//  GeminiExplanationService.swift
//  NKJV Bible
//

import Foundation

enum GeminiExplanationError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case noData
    case emptyResponse
    case apiError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is not configured."
        case .invalidURL:
            return "Could not reach the explanation service."
        case .noData, .emptyResponse:
            return "No explanation was returned. Please try again."
        case .apiError(let message):
            return message
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

final class GeminiExplanationService {

    static let shared = GeminiExplanationService()

    private let modelName = "gemini-2.5-flash"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchExplanation(
        verseReference: String,
        verseText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, GeminiExplanationError>) -> Void
    ) {
        let apiKey = GeminiKeyProvider.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(.missingAPIKey))
            return
        }

        guard let encodedModel = modelName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(encodedModel):generateContent?key=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }

        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise explanation of the following verse.

        Translation: \(bibleVersion)
        Verse reference: \(verseReference)
        Verse text: \(verseText)

        Respond in \(language) only. Do not add a title or heading — give the explanation directly.
        """

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let message = Self.parseAPIErrorMessage(from: data) ?? "Request failed (\(http.statusCode))."
                DispatchQueue.main.async {
                    completion(.failure(.apiError(message)))
                }
                return
            }

            guard let text = Self.parseExplanationText(from: data)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.emptyResponse))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(text))
            }
        }.resume()
    }

    func fetchChapterSummary(
        chapterReference: String,
        chapterText: String,
        bibleVersion: String,
        responseLanguageCode: String,
        completion: @escaping (Result<String, GeminiExplanationError>) -> Void
    ) {
        let apiKey = GeminiKeyProvider.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(.missingAPIKey))
            return
        }

        guard let encodedModel = modelName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(encodedModel):generateContent?key=\(apiKey)") else {
            completion(.failure(.invalidURL))
            return
        }

        let language = responseLanguageCode.isEmpty ? "en" : responseLanguageCode
        let prompt = """
        You are a helpful Bible study assistant. Provide a clear, faithful, and concise summary of the following chapter.

        Translation: \(bibleVersion)
        Chapter: \(chapterReference)
        Chapter text: \(chapterText)

        Respond in \(language) only. Do not add a title or heading — give the summary directly.
        """

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let message = Self.parseAPIErrorMessage(from: data) ?? "Request failed (\(http.statusCode))."
                DispatchQueue.main.async {
                    completion(.failure(.apiError(message)))
                }
                return
            }

            guard let text = Self.parseExplanationText(from: data)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.emptyResponse))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(text))
            }
        }.resume()
    }

    private static func parseExplanationText(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            return nil
        }

        return parts.compactMap { $0["text"] as? String }.joined()
    }

    private static func parseAPIErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? [String: Any],
              let message = error["message"] as? String else {
            return nil
        }
        return message
    }
}
