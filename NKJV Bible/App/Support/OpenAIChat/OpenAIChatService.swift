//
//  OpenAIChatService.swift
//  NKJV Bible
//

import Foundation

enum OpenAIChatError: LocalizedError {
    case invalidURL
    case noData
    case emptyResponse
    case apiError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not reach the AI chat service."
        case .noData, .emptyResponse:
            return "No reply was returned. Please try again."
        case .apiError(let message):
            return message
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

final class OpenAIChatService {

    static let shared = OpenAIChatService()

    private let endpoint = "https://openai-api-gamma.vercel.app/api/chat"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(input: String, completion: @escaping (Result<String, OpenAIChatError>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["input": input])

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

            guard let text = Self.parseOutputText(from: data)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                DispatchQueue.main.async {
                    completion(.failure(.emptyResponse))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(Self.stripMarkdownMarkers(from: text)))
            }
        }.resume()
    }

    private static func parseOutputText(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let text = json["output_text"] as? String, !text.isEmpty {
            return text
        }

        guard let output = json["output"] as? [[String: Any]] else {
            return nil
        }

        var parts: [String] = []
        for item in output {
            if let content = item["content"] as? [[String: Any]] {
                for block in content {
                    if let text = block["text"] as? String {
                        parts.append(text)
                    }
                }
            } else if let text = item["text"] as? String {
                parts.append(text)
            }
        }

        let joined = parts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? nil : joined
    }

    private static func parseAPIErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let message = json["error"] as? String {
            return message
        }

        if let error = json["error"] as? [String: Any], let message = error["message"] as? String {
            return message
        }

        return nil
    }

    private static func stripMarkdownMarkers(from text: String) -> String {
        return text.replacingOccurrences(of: "*", with: "")
    }
}
