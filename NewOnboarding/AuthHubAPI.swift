//
//  AuthHubAPI.swift
//  NKJV Bible
//
//  AuthHub form-urlencoded client (temp-token, register, login, forgot, profile).
//

import Foundation
import UIKit

struct AuthHubUser {
    var name: String
    var email: String
    var userId: String
    var referralCode: String?
    var referredBy: String?
    var referralCount: Int?
    var walletBalance: Int?
    var token: String
}

enum AuthHubAPIError: LocalizedError {
    case notConfigured
    case network(String)
    case server(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AuthHub credentials are missing. Fill AuthHubSecrets.swift (appID, clientID, clientSecret)."
        case .network(let message), .server(let message):
            return message
        case .invalidResponse:
            return "Unexpected server response."
        }
    }
}

final class AuthHubAPI {
    static let shared = AuthHubAPI()
    private init() {}

    // MARK: - Public API

    func register(
        name: String,
        email: String,
        password: String,
        friendReferralCode: String?,
        completion: @escaping (Result<AuthHubUser, Error>) -> Void
    ) {
        fetchTempToken { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let temp):
                var body: [String: String] = [
                    "name": name,
                    "email": email,
                    "password": password,
                    "password_confirmation": password,
                    "app_id": AuthHubConfig.appID,
                    "device_type": "iOS",
                    "email_verify": "0",
                    "app_version": Self.appVersion
                ]
                let code = friendReferralCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !code.isEmpty {
                    body["referred_by"] = code
                    body["referral_code"] = code
                }
                self.post(
                    path: "api/register",
                    body: body,
                    bearer: temp
                ) { result in
                    completion(result.flatMap { Self.parseAuthPayload($0) })
                }
            }
        }
    }

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthHubUser, Error>) -> Void
    ) {
        fetchTempToken { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let temp):
                let body: [String: String] = [
                    "email": email,
                    "password": password,
                    "app_id": AuthHubConfig.appID,
                    "device_type": "iOS",
                    "app_version": Self.appVersion
                ]
                self.post(
                    path: "api/login",
                    body: body,
                    bearer: temp
                ) { result in
                    completion(result.flatMap { Self.parseAuthPayload($0) })
                }
            }
        }
    }

    func fetchProfile(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        fetchTempToken { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let temp):
                let userKey = AuthHubSession.authToken ?? AuthHubSession.userId ?? ""
                let body: [String: String] = [
                    "app_id": AuthHubConfig.appID,
                    "user_id": userKey
                ]
                self.post(path: "api/profile", body: body, bearer: temp, completion: completion)
            }
        }
    }

    func sendForgotOTP(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchTempToken { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let temp):
                let body: [String: String] = [
                    "email": email,
                    "app_id": AuthHubConfig.appID
                ]
                self.post(path: "api/forgot-pwd/send-otp", body: body, bearer: temp) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let json):
                        if Self.isSuccess(json) {
                            completion(.success(()))
                        } else {
                            completion(.failure(AuthHubAPIError.server(Self.message(from: json))))
                        }
                    }
                }
            }
        }
    }

    func verifyForgotOTP(
        email: String,
        otp: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let body: [String: String] = [
            "email": email,
            "app_id": AuthHubConfig.appID,
            "otp": otp
        ]
        post(path: "api/forgot-pwd/verify-otp", body: body, bearer: nil) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let json):
                if !Self.isSuccess(json) {
                    completion(.failure(AuthHubAPIError.server(Self.message(from: json))))
                    return
                }
                let token = Self.extractResetToken(from: json)
                if token.isEmpty {
                    completion(.failure(AuthHubAPIError.server("OTP verified but reset token was missing.")))
                } else {
                    completion(.success(token))
                }
            }
        }
    }

    func resetPassword(
        email: String,
        token: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let body: [String: String] = [
            "email": email,
            "app_id": AuthHubConfig.appID,
            "token": token,
            "password": password,
            "password_confirmation": password
        ]
        post(path: "api/forgot-pwd/reset-pwd", body: body, bearer: nil) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let json):
                if Self.isSuccess(json) {
                    completion(.success(()))
                } else {
                    completion(.failure(AuthHubAPIError.server(Self.message(from: json))))
                }
            }
        }
    }

    // MARK: - Temp token

    private func fetchTempToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard AuthHubConfig.isConfigured else {
            completion(.failure(AuthHubAPIError.notConfigured))
            return
        }
        let body: [String: String] = [
            "client_id": AuthHubConfig.clientID,
            "client_secret": AuthHubConfig.clientSecret,
            "app_id": AuthHubConfig.appID
        ]
        post(path: "api/temp-token", body: body, bearer: nil) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let json):
                if !Self.isSuccess(json) {
                    completion(.failure(AuthHubAPIError.server(Self.message(from: json))))
                    return
                }
                let data = json["data"] as? [String: Any]
                let token = (data?["temp_access_token"] as? String) ?? ""
                if token.isEmpty {
                    completion(.failure(AuthHubAPIError.invalidResponse))
                } else {
                    completion(.success(token))
                }
            }
        }
    }

    // MARK: - HTTP

    private func post(
        path: String,
        body: [String: String],
        bearer: String?,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        let urlString = AuthHubConfig.baseURL + path
        guard let url = URL(string: urlString) else {
            completion(.failure(AuthHubAPIError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let bearer = bearer, !bearer.isEmpty {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = Self.formBody(body)
        request.timeoutInterval = 60

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(AuthHubAPIError.network(error.localizedDescription)))
                    return
                }
                guard let data = data else {
                    completion(.failure(AuthHubAPIError.invalidResponse))
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                    guard let dict = json as? [String: Any] else {
                        completion(.failure(AuthHubAPIError.invalidResponse))
                        return
                    }
                    completion(.success(dict))
                } catch {
                    completion(.failure(AuthHubAPIError.network(error.localizedDescription)))
                }
            }
        }.resume()
    }

    // MARK: - Parse helpers

    private static func parseAuthPayload(_ json: [String: Any]) -> Result<AuthHubUser, Error> {
        if !isSuccess(json) {
            return .failure(AuthHubAPIError.server(message(from: json)))
        }
        guard let data = json["data"] as? [String: Any] else {
            return .failure(AuthHubAPIError.invalidResponse)
        }
        let userMap = (data["user"] as? [String: Any]) ?? data
        let token = (data["token"] as? String) ?? ""
        let userId = stringValue(userMap["user_id"])
        let email = stringValue(userMap["email"])
        let name = stringValue(userMap["name"])
        if token.isEmpty || userId.isEmpty || email.isEmpty {
            return .failure(AuthHubAPIError.invalidResponse)
        }
        let user = AuthHubUser(
            name: name.isEmpty ? email : name,
            email: email,
            userId: userId,
            referralCode: optionalString(userMap["referral_code"]),
            referredBy: optionalString(userMap["referred_by"]),
            referralCount: intValue(userMap["referral_count"]) ?? intValue(userMap["total_referred_count"]),
            walletBalance: intValue(userMap["wallet_balance"]),
            token: token
        )
        return .success(user)
    }

    static func applyProfileJSON(_ json: [String: Any]) {
        guard isSuccess(json) else { return }
        let data = (json["data"] as? [String: Any]) ?? json
        let userMap = (data["user"] as? [String: Any]) ?? data
        AuthHubSession.updateReferralFields(
            referralCode: optionalString(userMap["referral_code"]),
            referredBy: optionalString(userMap["referred_by"]),
            referralCount: intValue(userMap["referral_count"]) ?? intValue(userMap["total_referred_count"]),
            walletBalance: intValue(userMap["wallet_balance"])
        )
        if let name = optionalString(userMap["name"]), !name.isEmpty {
            UserDefaults.standard.set(name, forKey: "name")
            UserDefaults.standard.set(name, forKey: "OnboardingUserName")
        }
    }

    private static func isSuccess(_ json: [String: Any]) -> Bool {
        if let b = json["status"] as? Bool { return b }
        if let n = json["status"] as? NSNumber { return n.boolValue }
        if let s = json["status"] as? String {
            return s == "1" || s.lowercased() == "true"
        }
        return false
    }

    private static func message(from json: [String: Any]) -> String {
        if let message = json["message"] as? String, !message.isEmpty { return message }
        if let errors = json["errors"] as? [String: Any] {
            let parts = errors.values.compactMap { value -> String? in
                if let arr = value as? [String] { return arr.joined(separator: " ") }
                if let s = value as? String { return s }
                return nil
            }
            if !parts.isEmpty { return parts.joined(separator: " ") }
        }
        return "Request failed."
    }

    private static func extractResetToken(from json: [String: Any]) -> String {
        if let data = json["data"] as? [String: Any] {
            for key in ["token", "reset_token", "pwd_token", "access_token"] {
                if let s = optionalString(data[key]), !s.isEmpty { return s }
            }
        }
        for key in ["token", "reset_token"] {
            if let s = optionalString(json[key]), !s.isEmpty { return s }
        }
        return ""
    }

    private static func formBody(_ fields: [String: String]) -> Data? {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let pairs = fields.map { key, value -> String in
            let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return "\(k)=\(v)"
        }
        return pairs.joined(separator: "&").data(using: .utf8)
    }

    private static func stringValue(_ any: Any?) -> String {
        if let s = any as? String { return s }
        if let n = any as? NSNumber { return n.stringValue }
        return ""
    }

    private static func optionalString(_ any: Any?) -> String? {
        let s = stringValue(any).trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }

    private static func intValue(_ any: Any?) -> Int? {
        if let i = any as? Int { return i }
        if let n = any as? NSNumber { return n.intValue }
        if let s = any as? String, let i = Int(s) { return i }
        return nil
    }

    private static var appVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
}
