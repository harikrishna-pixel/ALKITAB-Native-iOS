//
//  GeminiKeyProvider.swift
//  NKJV Bible
//

import Foundation

enum GeminiKeyProvider {
    static var apiKey: String {
        // TODO: move to Keychain or backend proxy before release
        return Secrets.geminiAPIKey
    }
}
