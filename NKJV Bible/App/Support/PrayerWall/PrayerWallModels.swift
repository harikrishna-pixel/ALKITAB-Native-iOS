//
//  PrayerWallModels.swift
//  NKJV Bible
//

import Foundation

struct PrayerWallItem: Decodable {
    let id: String
    let title: String
    let description: String
    let category: String
    let durationDays: Int?
    let userName: String
    let isAnonymous: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case prayerId = "prayerId"
        case title = "prayer_title"
        case description = "prayer_description"
        case category = "prayer_category"
        case durationDays = "prayer_duration"
        case userName = "user_name"
        case isAnonymous
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Backend responses may use either `_id` or `prayerId` for the prayer identifier.
        // Sometimes `_id` can also come as a MongoDB extended JSON object like `{ "$oid": "..." }`.
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let dict = try? container.decode([String: String].self, forKey: .id),
                  let oid = dict["$oid"] {
            id = oid
        } else if let prayerIdString = try? container.decode(String.self, forKey: .prayerId) {
            id = prayerIdString
        } else if let dict = try? container.decode([String: String].self, forKey: .prayerId),
                  let oid = dict["$oid"] {
            id = oid
        } else {
            id = ""
        }

        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        category = (try? container.decode(String.self, forKey: .category)) ?? ""
        durationDays = try? container.decode(Int.self, forKey: .durationDays)
        userName = (try? container.decode(String.self, forKey: .userName)) ?? ""
        isAnonymous = (try? container.decode(Bool.self, forKey: .isAnonymous)) ?? true
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = PrayerWallDateParser.parse(dateString)
        } else {
            createdAt = nil
        }
    }
}

struct PrayerWallComment: Decodable {
    let id: String
    let prayerId: String
    let text: String
    let isAnonymous: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case prayerId
        case text = "comment_text"
        case isAnonymous
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let dict = try? container.decode([String: String].self, forKey: .id), let oid = dict["$oid"] {
            id = oid
        } else {
            id = ""
        }
        prayerId = (try? container.decode(String.self, forKey: .prayerId)) ?? ""
        text = (try? container.decode(String.self, forKey: .text)) ?? ""
        isAnonymous = (try? container.decode(Bool.self, forKey: .isAnonymous)) ?? true
        if let dateString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = PrayerWallDateParser.parse(dateString)
        } else {
            createdAt = nil
        }
    }
}

struct PrayerWallLike: Decodable {
    let id: String
    let prayerId: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case prayerId
        case userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let dict = try? container.decode([String: String].self, forKey: .id), let oid = dict["$oid"] {
            id = oid
        } else {
            id = ""
        }
        prayerId = (try? container.decode(String.self, forKey: .prayerId)) ?? ""
        userId = try? container.decode(String.self, forKey: .userId)
    }
}

struct PrayerWallLikesResponse: Decodable {
    let prayerId: String?
    let count: Int?
    let likes: [PrayerWallLike]?
}

enum PrayerWallDateParser {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static func parse(_ value: String) -> Date? {
        if let date = isoFormatter.date(from: value) {
            return date
        }
        return fallbackFormatter.date(from: value)
    }
}

enum PrayerWallError: LocalizedError {
    case invalidURL
    case noData
    case apiError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not reach the prayer service."
        case .noData:
            return "No data was returned."
        case .apiError(let message):
            return message
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}
