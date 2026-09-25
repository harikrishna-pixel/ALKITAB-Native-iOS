//
//  AuthHubConfig.swift
//  NKJV Bible
//

import Foundation

enum AuthHubEnv {
    static func value(for key: String) -> String {
        guard let url = Bundle.main.url(forResource: "AuthHub", withExtension: "env"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            let name = parts[0].trimmingCharacters(in: .whitespaces)
            if name == key {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }
}

enum AuthHubConfig {
    static let baseURL = "https://bibleoffice.com/authhub/API/public/"

    static var appID: String { AUTHHUB_APP_ID }
    static var clientID: String { AuthHubEnv.value(for: "CLIENT_ID") }
    static var clientSecret: String { AuthHubEnv.value(for: "CLIENT_SECRET") }

    static var isConfigured: Bool {
        !appID.isEmpty && !clientID.isEmpty && !clientSecret.isEmpty
    }
}
