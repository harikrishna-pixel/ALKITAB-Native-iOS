//
//  AuthHubConfig.swift
//  NKJV Bible
//

import Foundation

enum AuthHubConfig {
    static let baseURL = "https://bibleoffice.com/authhub/API/public/"

    static var appID: String { AuthHubSecrets.appID }
    static var clientID: String { AuthHubSecrets.clientID }
    static var clientSecret: String { AuthHubSecrets.clientSecret }

    static var isConfigured: Bool {
        !appID.isEmpty && !clientID.isEmpty && !clientSecret.isEmpty
    }
}
