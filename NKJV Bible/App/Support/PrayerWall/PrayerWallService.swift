//
//  PrayerWallService.swift
//  NKJV Bible
//

import Foundation

final class PrayerWallService {

    static let shared = PrayerWallService()

    private let baseURL = "https://api.biblehi.com"
    private let authHeaderValue = "marberx@123tech"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private let likedPrayerIDsKey = "PrayerWallLikedPrayerIDs"
    private let likeDocumentIDsKey = "PrayerWallLikeDocumentIDs"

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    private var deviceUserID: String {
        return Udid
    }

    func fetchPrayers(completion: @escaping (Result<[PrayerWallItem], PrayerWallError>) -> Void) {
        request(method: "GET", path: "/api/prayers", body: nil) { result in
            switch result {
            case .success(let data):
                if let prayers = try? self.decoder.decode([PrayerWallItem].self, from: data) {
                    completion(.success(prayers))
                    return
                }
                completion(.failure(.apiError("Could not read prayers.")))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func createPrayer(
        title: String,
        description: String,
        category: String,
        durationDays: Int,
        userName: String,
        isAnonymous: Bool,
        completion: @escaping (Result<PrayerWallItem, PrayerWallError>) -> Void
    ) {
        let body: [String: Any] = [
            "prayer_title": title,
            "prayer_description": description,
            "prayer_category": category,
            "prayer_duration": durationDays,
            "app_id": bundleID,
            "app_name": APPNAME,
            "user_name": userName,
            "isAnonymous": isAnonymous
        ]

        request(method: "POST", path: "/api/prayers", body: body) { result in
            switch result {
            case .success(let data):
                if let prayer = try? self.decoder.decode(PrayerWallItem.self, from: data) {
                    completion(.success(prayer))
                    return
                }
                completion(.failure(.apiError("Could not read created prayer.")))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchComments(prayerId: String, completion: @escaping (Result<[PrayerWallComment], PrayerWallError>) -> Void) {
        request(method: "GET", path: "/api/comments?prayerId=\(prayerId)", body: nil) { result in
            switch result {
            case .success(let data):
                if let comments = try? self.decoder.decode([PrayerWallComment].self, from: data) {
                    completion(.success(comments))
                    return
                }
                completion(.failure(.apiError("Could not read comments.")))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func createComment(
        prayerId: String,
        text: String,
        isAnonymous: Bool,
        completion: @escaping (Result<PrayerWallComment, PrayerWallError>) -> Void
    ) {
        let body: [String: Any] = [
            "prayerId": prayerId,
            "comment_text": text,
            "isAnonymous": isAnonymous
        ]

        request(method: "POST", path: "/api/comments", body: body) { result in
            switch result {
            case .success(let data):
                if let comment = try? self.decoder.decode(PrayerWallComment.self, from: data) {
                    completion(.success(comment))
                    return
                }
                completion(.failure(.apiError("Could not read created comment.")))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchLikes(prayerId: String, completion: @escaping (Result<PrayerWallLikesResponse, PrayerWallError>) -> Void) {
        request(method: "GET", path: "/api/likes?prayerId=\(prayerId)", body: nil) { result in
            switch result {
            case .success(let data):
                if let response = try? self.decoder.decode(PrayerWallLikesResponse.self, from: data) {
                    completion(.success(response))
                    return
                }
                if let likes = try? self.decoder.decode([PrayerWallLike].self, from: data) {
                    completion(.success(PrayerWallLikesResponse(prayerId: prayerId, count: likes.count, likes: likes)))
                    return
                }
                completion(.failure(.apiError("Could not read likes.")))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func createLike(prayerId: String, completion: @escaping (Result<Void, PrayerWallError>) -> Void) {
        // `userId` is optional on the backend. Do not send it to avoid "invalid user id" errors.
        let body: [String: Any] = ["prayerId": prayerId]

        request(method: "POST", path: "/api/likes", body: body) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if let like = try? self.decoder.decode(PrayerWallLike.self, from: data), !like.id.isEmpty {
                    self.storeLikeDocumentId(like.id, for: prayerId)
                }
                self.storeLikedPrayerId(prayerId)
                completion(.success(()))
            case .failure(let error):
                if case .apiError(let message) = error, message.lowercased().contains("already liked") {
                    self.storeLikedPrayerId(prayerId)
                    completion(.success(()))
                    return
                }
                completion(.failure(error))
            }
        }
    }

    func deleteLike(prayerId: String, completion: @escaping (Result<Void, PrayerWallError>) -> Void) {
        var body: [String: Any] = [:]
        if let likeId = likeDocumentId(for: prayerId), !likeId.isEmpty {
            body["likeId"] = likeId
        } else {
            body["prayerId"] = prayerId
        }

        request(method: "DELETE", path: "/api/likes", body: body) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.removeLikedPrayerId(prayerId)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func isPrayerLiked(_ prayerId: String) -> Bool {
        return likedPrayerIds().contains(prayerId)
    }

    private func likedPrayerIds() -> Set<String> {
        let values = UserDefaults.standard.stringArray(forKey: likedPrayerIDsKey) ?? []
        return Set(values)
    }

    private func storeLikedPrayerId(_ prayerId: String) {
        var values = likedPrayerIds()
        values.insert(prayerId)
        UserDefaults.standard.set(Array(values), forKey: likedPrayerIDsKey)
    }

    private func removeLikedPrayerId(_ prayerId: String) {
        var values = likedPrayerIds()
        values.remove(prayerId)
        UserDefaults.standard.set(Array(values), forKey: likedPrayerIDsKey)
        removeLikeDocumentId(for: prayerId)
    }

    private func likeDocumentId(for prayerId: String) -> String? {
        let map = UserDefaults.standard.dictionary(forKey: likeDocumentIDsKey) as? [String: String]
        return map?[prayerId]
    }

    private func storeLikeDocumentId(_ likeId: String, for prayerId: String) {
        var map = UserDefaults.standard.dictionary(forKey: likeDocumentIDsKey) as? [String: String] ?? [:]
        map[prayerId] = likeId
        UserDefaults.standard.set(map, forKey: likeDocumentIDsKey)
    }

    private func removeLikeDocumentId(for prayerId: String) {
        var map = UserDefaults.standard.dictionary(forKey: likeDocumentIDsKey) as? [String: String] ?? [:]
        map.removeValue(forKey: prayerId)
        UserDefaults.standard.set(map, forKey: likeDocumentIDsKey)
    }

    private func request(
        method: String,
        path: String,
        body: [String: Any]?,
        completion: @escaping (Result<Data, PrayerWallError>) -> Void
    ) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
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
                let message = Self.parseErrorMessage(from: data) ?? "Request failed (\(http.statusCode))."
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
        if let message = json["message"] as? String {
            return message
        }
        if let error = json["error"] as? String {
            return error
        }
        return nil
    }
}
