//
//  CreatorChallengeService.swift
//  NKJV Bible
//

import Foundation

final class CreatorChallengeService {

    static let shared = CreatorChallengeService()

    private let baseURL = "https://api.versedeep.com"
    private let authHeaderValue = "marberx@123tech"
    private let creatorUserIdKey = "CreatorChallengeUserId"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private let optionIds = ["a", "b", "c", "d", "e", "f"]

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Stored creator id

    var storedUserId: String? {
        let value = UserDefaults.standard.string(forKey: creatorUserIdKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? nil : value
    }

    private func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: creatorUserIdKey)
    }

    // MARK: - Public API (mobile creator)

    /// POST /api/creators
    func createOrFindCreator(
        email: String? = nil,
        completion: @escaping (Result<CreatorData, CreatorChallengeError>) -> Void
    ) {
        let resolvedEmail = (email ?? Self.creatorEmail())
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resolvedEmail.isEmpty else {
            completion(.failure(.missingEmail))
            return
        }

        let body = CreatorRegisterRequest(
            appId: bundleID,
            appName: APPNAME,
            email: resolvedEmail
        )

        request(method: "POST", path: "/api/creators", body: body, userId: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.printJSON("POST /api/creators", data: data)
                guard let envelope = try? self.decoder.decode(CreatorAPIEnvelope<CreatorData>.self, from: data),
                      let creator = envelope.data,
                      !creator.userId.isEmpty else {
                    completion(.failure(.decodeError))
                    return
                }
                self.saveUserId(creator.userId)
                completion(.success(creator))
            }
        }
    }

    /// Ensures creator exists, then POST /api/challenges
    func createChallenge(
        title: String,
        description: String,
        contentType: String,
        questions: [ChallengeQuestionPayload],
        completion: @escaping (Result<ChallengeSummary, CreatorChallengeError>) -> Void
    ) {
        ensureCreatorUserId { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let userId):
                self?.postChallenge(
                    userId: userId,
                    title: title,
                    description: description,
                    contentType: contentType,
                    questions: questions,
                    completion: completion
                )
            }
        }
    }

    /// Convenience: map Quick Quiz questions and create a challenge.
    func createChallengeFromQuickQuiz(
        title: String,
        description: String,
        questions: [QuickQuizQuestion],
        completion: @escaping (Result<ChallengeSummary, CreatorChallengeError>) -> Void
    ) {
        let payload = mapQuickQuizQuestions(questions)
        createChallenge(
            title: title,
            description: description,
            contentType: "quiz",
            questions: payload,
            completion: completion
        )
    }

    /// GET /api/challenges
    func listChallenges(completion: @escaping (Result<[ChallengeSummary], CreatorChallengeError>) -> Void) {
        ensureCreatorUserId { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let userId):
                self?.request(method: "GET", path: "/api/challenges", userId: userId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        self.printJSON("GET /api/challenges", data: data)
                        if let envelope = try? self.decoder.decode(CreatorAPIEnvelope<[ChallengeSummary]>.self, from: data),
                           let list = envelope.data {
                            completion(.success(list))
                            return
                        }
                        if let list = try? self.decoder.decode([ChallengeSummary].self, from: data) {
                            completion(.success(list))
                            return
                        }
                        completion(.failure(.decodeError))
                    }
                }
            }
        }
    }

    /// GET /api/challenges/:id
    func getChallenge(
        id: String,
        completion: @escaping (Result<ChallengeSummary, CreatorChallengeError>) -> Void
    ) {
        ensureCreatorUserId { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let userId):
                self?.request(method: "GET", path: "/api/challenges/\(id)", userId: userId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        self.printJSON("GET /api/challenges/\(id)", data: data)
                        guard let envelope = try? self.decoder.decode(CreatorAPIEnvelope<ChallengeSummary>.self, from: data),
                              let challenge = envelope.data else {
                            completion(.failure(.decodeError))
                            return
                        }
                        completion(.success(challenge))
                    }
                }
            }
        }
    }

    /// GET /api/challenges/:id/attempts
    func getAttempts(
        challengeId: String,
        completion: @escaping (Result<[ChallengeAttempt], CreatorChallengeError>) -> Void
    ) {
        ensureCreatorUserId { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let userId):
                self?.request(method: "GET", path: "/api/challenges/\(challengeId)/attempts", userId: userId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        self.printJSON("GET /api/challenges/\(challengeId)/attempts", data: data)
                        if let envelope = try? self.decoder.decode(CreatorAPIEnvelope<[ChallengeAttempt]>.self, from: data),
                           let list = envelope.data {
                            completion(.success(list))
                            return
                        }
                        if let list = try? self.decoder.decode([ChallengeAttempt].self, from: data) {
                            completion(.success(list))
                            return
                        }
                        completion(.failure(.decodeError))
                    }
                }
            }
        }
    }

    /// PATCH /api/challenges/:id  status: active | paused | deleted
    func updateChallengeStatus(
        id: String,
        status: String,
        completion: @escaping (Result<ChallengeSummary, CreatorChallengeError>) -> Void
    ) {
        ensureCreatorUserId { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let userId):
                let body = ChallengeStatusUpdateRequest(status: status)
                self?.request(method: "PATCH", path: "/api/challenges/\(id)", body: body, userId: userId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        self.printJSON("PATCH /api/challenges/\(id)", data: data)
                        if let envelope = try? self.decoder.decode(CreatorAPIEnvelope<ChallengeSummary>.self, from: data),
                           let challenge = envelope.data {
                            completion(.success(challenge))
                            return
                        }
                        completion(.success(ChallengeSummary(
                            id: id,
                            title: nil,
                            description: nil,
                            totalQuestions: nil,
                            status: status,
                            shareUrl: nil
                        )))
                    }
                }
            }
        }
    }

    // MARK: - Mapper

    func mapQuickQuizQuestions(_ questions: [QuickQuizQuestion]) -> [ChallengeQuestionPayload] {
        questions.enumerated().map { index, q in
            let options: [ChallengeOptionPayload] = q.options.enumerated().compactMap { optIndex, text in
                guard optIndex < optionIds.count else { return nil }
                return ChallengeOptionPayload(id: optionIds[optIndex], text: text)
            }
            let correctId: String
            if q.correctIndex >= 0, q.correctIndex < optionIds.count {
                correctId = optionIds[q.correctIndex]
            } else {
                correctId = optionIds.first ?? "a"
            }
            return ChallengeQuestionPayload(
                questionId: "q\(index + 1)",
                question: q.prompt,
                options: options,
                correctAnswer: correctId,
                explanation: nil
            )
        }
    }

    // MARK: - Internals

    private func ensureCreatorUserId(completion: @escaping (Result<String, CreatorChallengeError>) -> Void) {
        if let existing = storedUserId {
            completion(.success(existing))
            return
        }
        createOrFindCreator { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let creator):
                completion(.success(creator.userId))
            }
        }
    }

    private func postChallenge(
        userId: String,
        title: String,
        description: String,
        contentType: String,
        questions: [ChallengeQuestionPayload],
        completion: @escaping (Result<ChallengeSummary, CreatorChallengeError>) -> Void
    ) {
        let body = ChallengeCreateRequest(
            title: title,
            description: description,
            contentType: contentType,
            questions: questions
        )
        request(method: "POST", path: "/api/challenges", body: body, userId: userId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.printJSON("POST /api/challenges", data: data)
                guard let envelope = try? self.decoder.decode(CreatorAPIEnvelope<ChallengeSummary>.self, from: data),
                      let challenge = envelope.data else {
                    completion(.failure(.decodeError))
                    return
                }
                print("[CreatorChallenge] shareUrl: \(challenge.shareUrl ?? "(none)")")
                completion(.success(challenge))
            }
        }
    }

    private static func creatorEmail() -> String {
        if let email = UserDefaults.standard.string(forKey: "OnboardingUserEmail")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !email.isEmpty {
            return email
        }
        let short = String(Udid.prefix(12))
        return "\(short)@\(bundleID).local"
    }

    private func printJSON(_ label: String, data: Data) {
        if let object = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let text = String(data: pretty, encoding: .utf8) {
            print("[CreatorChallenge] \(label) response:\n\(text)")
        } else if let text = String(data: data, encoding: .utf8) {
            print("[CreatorChallenge] \(label) response:\n\(text)")
        } else {
            print("[CreatorChallenge] \(label) response: <\(data.count) bytes>")
        }
    }

    private func request(
        method: String,
        path: String,
        userId: String?,
        completion: @escaping (Result<Data, CreatorChallengeError>) -> Void
    ) {
        performRequest(method: method, path: path, httpBody: nil, userId: userId, completion: completion)
    }

    private func request<Body: Encodable>(
        method: String,
        path: String,
        body: Body?,
        userId: String?,
        completion: @escaping (Result<Data, CreatorChallengeError>) -> Void
    ) {
        var httpBody: Data?
        if let body = body {
            do {
                httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(.networkError(error)))
                return
            }
        }
        performRequest(method: method, path: path, httpBody: httpBody, userId: userId, completion: completion)
    }

    private func performRequest(
        method: String,
        path: String,
        httpBody: Data?,
        userId: String?,
        completion: @escaping (Result<Data, CreatorChallengeError>) -> Void
    ) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        if let userId = userId, !userId.isEmpty {
            request.setValue(userId, forHTTPHeaderField: "x-user-id")
        }
        request.timeoutInterval = 60
        request.httpBody = httpBody

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
                let message = Self.parseErrorMessage(from: data) ?? "Request failed (\(http.statusCode))."
                print("[CreatorChallenge] \(method) \(path) HTTP \(http.statusCode): \(message)")
                if let text = String(data: data, encoding: .utf8) {
                    print("[CreatorChallenge] error body:\n\(text)")
                }
                DispatchQueue.main.async {
                    completion(.failure(.apiError(message)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }

    private static func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let message = json["message"] as? String { return message }
        if let error = json["error"] as? String { return error }
        return nil
    }
}
