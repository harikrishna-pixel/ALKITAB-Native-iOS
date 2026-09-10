//
//  AuthHubSession.swift
//  NKJV Bible
//
//  Local session cache matching AuthHub MD keys + existing OnboardingLoggedIn gate.
//

import Foundation

enum AuthHubSession {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys (AuthHub MD + existing onboarding flags)
    private enum Key {
        static let loggedIn = "OnboardingLoggedIn"
        static let provider = "OnboardingLoginProvider"
        static let onboardingUserId = "OnboardingUserId"
        static let onboardingEmail = "OnboardingUserEmail"
        static let onboardingName = "OnboardingUserName"

        static let userEmail = "user"
        static let userId = "userid"
        static let name = "name"
        static let authToken = "authtoken"
        static let referralCode = "referral_code"
        static let referredBy = "referred_by"
        static let referralCount = "referral_count"
        static let walletBalance = "wallet_balance"
    }

    static var isLoggedIn: Bool {
        defaults.bool(forKey: Key.loggedIn) && !(authToken ?? "").isEmpty
    }

    static var authToken: String? { defaults.string(forKey: Key.authToken) }
    static var userId: String? { defaults.string(forKey: Key.userId) }
    static var email: String? { defaults.string(forKey: Key.userEmail) ?? defaults.string(forKey: Key.onboardingEmail) }
    static var name: String? { defaults.string(forKey: Key.name) ?? defaults.string(forKey: Key.onboardingName) }
    static var referralCode: String? { defaults.string(forKey: Key.referralCode) }
    static var referredBy: String? { defaults.string(forKey: Key.referredBy) }
    static var referralCount: Int { defaults.integer(forKey: Key.referralCount) }
    static var walletBalance: Int { defaults.integer(forKey: Key.walletBalance) }

    static func saveLogin(
        email: String,
        name: String,
        userId: String,
        token: String,
        referralCode: String?,
        referredBy: String?,
        referralCount: Int?,
        walletBalance: Int?
    ) {
        defaults.set(true, forKey: Key.loggedIn)
        defaults.set("authhub", forKey: Key.provider)
        defaults.set(email, forKey: Key.userEmail)
        defaults.set(email, forKey: Key.onboardingEmail)
        defaults.set(name, forKey: Key.name)
        defaults.set(name, forKey: Key.onboardingName)
        defaults.set(userId, forKey: Key.userId)
        defaults.set(userId, forKey: Key.onboardingUserId)
        defaults.set(token, forKey: Key.authToken)
        if let referralCode = referralCode { defaults.set(referralCode, forKey: Key.referralCode) }
        if let referredBy = referredBy { defaults.set(referredBy, forKey: Key.referredBy) }
        if let referralCount = referralCount { defaults.set(referralCount, forKey: Key.referralCount) }
        if let walletBalance = walletBalance { defaults.set(walletBalance, forKey: Key.walletBalance) }
    }

    static func updateReferralFields(
        referralCode: String?,
        referredBy: String?,
        referralCount: Int?,
        walletBalance: Int?
    ) {
        if let referralCode = referralCode { defaults.set(referralCode, forKey: Key.referralCode) }
        if let referredBy = referredBy { defaults.set(referredBy, forKey: Key.referredBy) }
        if let referralCount = referralCount { defaults.set(referralCount, forKey: Key.referralCount) }
        if let walletBalance = walletBalance { defaults.set(walletBalance, forKey: Key.walletBalance) }
    }

    static func clear() {
        defaults.set(false, forKey: Key.loggedIn)
        defaults.removeObject(forKey: Key.provider)
        defaults.removeObject(forKey: Key.onboardingUserId)
        defaults.removeObject(forKey: Key.onboardingEmail)
        defaults.removeObject(forKey: Key.onboardingName)
        defaults.removeObject(forKey: Key.userEmail)
        defaults.removeObject(forKey: Key.userId)
        defaults.removeObject(forKey: Key.name)
        defaults.removeObject(forKey: Key.authToken)
        defaults.removeObject(forKey: Key.referralCode)
        defaults.removeObject(forKey: Key.referredBy)
        defaults.removeObject(forKey: Key.referralCount)
        defaults.removeObject(forKey: Key.walletBalance)
    }
}
