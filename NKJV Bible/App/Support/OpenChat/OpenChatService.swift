//
//  OpenChatService.swift
//  NKJV Bible
//

import Foundation

struct OpenChatModel {
    let id: String
    let name: String
    let provider: String
}

enum OpenChatError: LocalizedError {
    case invalidURL
    case noData
    case emptyResponse
    case missingAuthorization
    case apiError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not reach the Open Chat service."
        case .noData, .emptyResponse:
            return "No reply was returned. Please try again."
        case .missingAuthorization:
            return "Open Chat authorization is not configured."
        case .apiError(let message):
            return message
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

final class OpenChatService {

    static let shared = OpenChatService()

    private let modelsEndpoint = "https://ai-model-api-seven.vercel.app/api/ai/models"
    private let chatEndpoint = "https://all-model-api.vercel.app/"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchModels(completion: @escaping (Result<[OpenChatModel], OpenChatError>) -> Void) {
        guard let url = URL(string: modelsEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        let auth = Secrets.openChatAuthorization.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !auth.isEmpty, auth != "YOUR_OPEN_CHAT_AUTHORIZATION_HERE" else {
            completion(.failure(.missingAuthorization))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

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

            let models = Self.parseModels(from: data)
            DispatchQueue.main.async {
                if models.isEmpty {
                    completion(.failure(.emptyResponse))
                } else {
                    completion(.success(models))
                }
            }
        }.resume()
    }

    func send(input: String, model: String, completion: @escaping (Result<String, OpenChatError>) -> Void) {
        guard let url = URL(string: chatEndpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 90
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "input": input,
            "model": model
        ])

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
                completion(.success(text))
            }
        }.resume()
    }

    private static func parseModels(from data: Data) -> [OpenChatModel] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = json["models"] as? [[String: Any]] else {
            return []
        }

        return list.compactMap { item in
            guard let id = item["id"] as? String, !id.isEmpty else { return nil }
            return OpenChatModel(
                id: id,
                name: (item["name"] as? String) ?? id,
                provider: (item["provider"] as? String) ?? ""
            )
        }
    }

    private static func parseOutputText(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // OpenAI-style chat.completion: choices[0].message.content
            if let choices = json["choices"] as? [[String: Any]] {
                for choice in choices {
                    if let message = choice["message"] as? [String: Any],
                       let content = message["content"] as? String,
                       !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return content
                    }
                    if let text = choice["text"] as? String,
                       !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return text
                    }
                }
            }

            for key in ["output_text", "output", "response", "text", "message", "result", "reply", "content"] {
                if let text = json[key] as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return text
                }
            }

            if let output = json["output"] as? [[String: Any]] {
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
                if !joined.isEmpty { return joined }
            }

            if let dataObj = json["data"] as? [String: Any] {
                for key in ["output_text", "output", "response", "text", "message", "result"] {
                    if let text = dataObj[key] as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return text
                    }
                }
            }
        }

        if let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty,
           !text.hasPrefix("{") {
            return text
        }

        return nil
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

        if let message = json["message"] as? String {
            return message
        }

        return nil
    }
}
