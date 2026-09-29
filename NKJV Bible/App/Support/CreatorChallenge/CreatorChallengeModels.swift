//
//  CreatorChallengeModels.swift
//  NKJV Bible
//

import Foundation

// MARK: - Request bodies

struct CreatorRegisterRequest: Encodable {
    let appId: String
    let appName: String
    let email: String
}

struct ChallengeCreateRequest: Encodable {
    let title: String
    let description: String
    let contentType: String
    let questions: [ChallengeQuestionPayload]
}

struct ChallengeQuestionPayload: Encodable {
    let questionId: String
    let question: String
    let options: [ChallengeOptionPayload]
    let correctAnswer: String
    let explanation: String?
}

struct ChallengeOptionPayload: Encodable {
    let id: String
    let text: String
}

struct ChallengeStatusUpdateRequest: Encodable {
    let status: String
}

// MARK: - Responses

struct CreatorAPIEnvelope<T: Decodable>: Decodable {
    let success: Bool?
    let message: String?
    let data: T?
}

struct CreatorData: Decodable {
    let userId: String
    let appId: String?
    let appName: String?
    let email: String?
}

struct ChallengeSummary: Decodable {
    let id: String
    let title: String?
    let description: String?
    let totalQuestions: Int?
    let status: String?
    let shareUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, totalQuestions, status, shareUrl
    }
}

struct ChallengeAttempt: Decodable {
    let attemptId: String?
    let playerName: String?
    let email: String?
    let score: Int?
    let totalQuestions: Int?
    let percentage: Double?

    enum CodingKeys: String, CodingKey {
        case attemptId
        case id
        case playerName, email, score, totalQuestions, percentage
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        attemptId = try c.decodeIfPresent(String.self, forKey: .attemptId)
            ?? c.decodeIfPresent(String.self, forKey: .id)
        playerName = try c.decodeIfPresent(String.self, forKey: .playerName)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        score = try c.decodeIfPresent(Int.self, forKey: .score)
        totalQuestions = try c.decodeIfPresent(Int.self, forKey: .totalQuestions)
        if let p = try c.decodeIfPresent(Double.self, forKey: .percentage) {
            percentage = p
        } else if let pInt = try c.decodeIfPresent(Int.self, forKey: .percentage) {
            percentage = Double(pInt)
        } else {
            percentage = nil
        }
    }
}

enum CreatorChallengeError: Error, LocalizedError {
    case invalidURL
    case noData
    case networkError(Error)
    case apiError(String)
    case missingUserId
    case missingEmail
    case decodeError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noData: return "No data from server."
        case .networkError(let error): return error.localizedDescription
        case .apiError(let message): return message
        case .missingUserId: return "Missing creator user id."
        case .missingEmail: return "Missing email for creator."
        case .decodeError: return "Could not read server response."
        }
    }
}
