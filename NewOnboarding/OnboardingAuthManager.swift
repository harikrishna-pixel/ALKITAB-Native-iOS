//
//  OnboardingAuthManager.swift
//  NKJV Bible
//

import UIKit
import AuthenticationServices
import CryptoKit
// FIREBASE SOCIAL LOGIN — commented out; AuthHub email/password is the active path.
// import FirebaseAuth
// import FirebaseCore
// import GoogleSignIn

final class OnboardingAuthManager: NSObject, ObservableObject {
    @Published var isBusy = false
    @Published var errorMessage: String?

    /// When set (e.g. Prayer Wall login), called after successful sign-in instead of navigating to IAP.
    /// Nil keeps the existing onboarding behavior (`navigateToIAPView`).
    var onAuthSuccess: (() -> Void)?

    // MARK: - AuthHub email/password

    func registerWithAuthHub(
        name: String,
        email: String,
        password: String,
        friendReferralCode: String?
    ) {
        guard !isBusy else { return }
        errorMessage = nil
        isBusy = true
        AuthHubAPI.shared.register(
            name: name,
            email: email,
            password: password,
            friendReferralCode: friendReferralCode
        ) { [weak self] result in
            self?.finishAuthHub(result)
        }
    }

    func loginWithAuthHub(email: String, password: String) {
        guard !isBusy else { return }
        errorMessage = nil
        isBusy = true
        AuthHubAPI.shared.login(email: email, password: password) { [weak self] result in
            self?.finishAuthHub(result)
        }
    }

    private func finishAuthHub(_ result: Result<AuthHubUser, Error>) {
        DispatchQueue.main.async {
            self.isBusy = false
            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            case .success(let user):
                AuthHubSession.saveLogin(
                    email: user.email,
                    name: user.name,
                    userId: user.userId,
                    token: user.token,
                    referralCode: user.referralCode,
                    referredBy: user.referredBy,
                    referralCount: user.referralCount,
                    walletBalance: user.walletBalance
                )
                AuthHubAPI.shared.fetchProfile { profileResult in
                    if case .success(let json) = profileResult {
                        AuthHubAPI.applyProfileJSON(json)
                    }
                    if let onAuthSuccess = self.onAuthSuccess {
                        onAuthSuccess()
                    } else {
                        UIKitNavigationHelper.navigateToIAPView()
                    }
                }
            }
        }
    }

    /*
    // MARK: - Firebase Apple / Google (disabled — AuthHub active)
    private var currentNonce: String?
    private var appleCompletion: ((Bool) -> Void)?

    func signInWithApple() { ... }
    func signInWithGoogle() { ... }
    private func signInToFirebase(credential: AuthCredential, provider: String) { ... }
    */

    /// Clears local login flags and AuthHub session. Does not change other app state.
    static func logOut() {
        // try? Auth.auth().signOut()
        AuthHubSession.clear()
    }

    static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// Apple Sign-In delegate kept commented with Firebase path.
// extension OnboardingAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding { ... }
