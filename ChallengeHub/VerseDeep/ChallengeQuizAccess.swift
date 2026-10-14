//
//  ChallengeQuizAccess.swift
//  NKJV Bible
//
//  Quiz creator gate. Uses the main account when that login is already active.
//  Signing out here only turns off quiz access.
//

import Foundation

enum ChallengeQuizAccess {
    private static let signedOutKey = "QuizCreatorSignedOut"

    /// Main login is used unless this quiz profile was signed out on purpose.
    static var allowsChallenges: Bool {
        if UserDefaults.standard.bool(forKey: signedOutKey) { return false }
        return AuthHubSession.isLoggedIn
    }

    static func signOutOfQuiz() {
        UserDefaults.standard.set(true, forKey: signedOutKey)
    }

    static func noteLogin() {
        UserDefaults.standard.set(false, forKey: signedOutKey)
    }
}
