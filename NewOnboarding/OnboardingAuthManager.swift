//
//  OnboardingAuthManager.swift
//  NKJV Bible
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

final class OnboardingAuthManager: NSObject, ObservableObject {
    @Published var isBusy = false
    @Published var errorMessage: String?

    /// When set (e.g. Prayer Wall login), called after successful sign-in instead of navigating to IAP.
    /// Nil keeps the existing onboarding behavior (`navigateToIAPView`).
    var onAuthSuccess: (() -> Void)?

    private var currentNonce: String?
    private var appleCompletion: ((Bool) -> Void)?

    func signInWithApple() {
        guard !isBusy else { return }
        errorMessage = nil
        isBusy = true

        let nonce = randomNonce()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func signInWithGoogle() {
        guard !isBusy else { return }
        errorMessage = nil

        guard let clientID = FirebaseApp.app()?.options.clientID ?? googleClientIDFromPlist() else {
            errorMessage = "Google Sign-In is unavailable right now. Please try Apple Sign-In or Not Now."
            return
        }

        signInWithGoogleSDK(clientID: clientID)
    }

    private func signInWithGoogleSDK(clientID: String) {
        guard let presenter = Self.topViewController() else {
            errorMessage = "Unable to start Google Sign-In."
            return
        }

        isBusy = true
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error as NSError?, error.code == GIDSignInError.canceled.rawValue {
                    self.isBusy = false
                    return
                }
                if let error = error {
                    self.isBusy = false
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    self.isBusy = false
                    self.errorMessage = "Google Sign-In failed."
                    return
                }
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                self.signInToFirebase(credential: credential, provider: "google")
            }
        }
    }

    private func signInToFirebase(credential: AuthCredential, provider: String) {
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isBusy = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                UserDefaults.standard.set(true, forKey: "OnboardingLoggedIn")
                UserDefaults.standard.set(provider, forKey: "OnboardingLoginProvider")
                UserDefaults.standard.set(result?.user.uid, forKey: "OnboardingUserId")
                UserDefaults.standard.set(result?.user.email, forKey: "OnboardingUserEmail")
                Self.persistDisplayName(
                    firebaseDisplayName: result?.user.displayName,
                    email: result?.user.email
                )
                if let onAuthSuccess = self.onAuthSuccess {
                    onAuthSuccess()
                } else {
                    UIKitNavigationHelper.navigateToIAPView()
                }
            }
        }
    }

    /// Saves a friendly name for Home greeting without changing auth flow.
    static func persistDisplayName(firebaseDisplayName: String?, email: String?) {
        if let name = firebaseDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            UserDefaults.standard.set(name, forKey: "OnboardingUserName")
            return
        }
        let existing = UserDefaults.standard.string(forKey: "OnboardingUserName")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !existing.isEmpty { return }
        if let email = email, let at = email.firstIndex(of: "@") {
            let local = String(email[..<at]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !local.isEmpty {
                UserDefaults.standard.set(local, forKey: "OnboardingUserName")
            }
        }
    }

    /// Clears local login flags and Firebase session. Does not change other app state.
    static func logOut() {
        try? Auth.auth().signOut()
        UserDefaults.standard.set(false, forKey: "OnboardingLoggedIn")
        UserDefaults.standard.removeObject(forKey: "OnboardingLoginProvider")
        UserDefaults.standard.removeObject(forKey: "OnboardingUserId")
        UserDefaults.standard.removeObject(forKey: "OnboardingUserEmail")
        UserDefaults.standard.removeObject(forKey: "OnboardingUserName")
    }

    private func googleClientIDFromPlist() -> String? {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path)
        else { return nil }
        return dict["CLIENT_ID"] as? String
    }

    private func randomNonce(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let hash = SHA256.hash(data: Data(input.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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

extension OnboardingAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        Self.topViewController()?.view.window
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleIDCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            isBusy = false
            errorMessage = "Apple Sign-In failed."
            return
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        if let fullName = appleIDCredential.fullName {
            let formatted = PersonNameComponentsFormatter().string(from: fullName)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !formatted.isEmpty {
                UserDefaults.standard.set(formatted, forKey: "OnboardingUserName")
            }
        }
        signInToFirebase(credential: credential, provider: "apple")
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isBusy = false
        let nsError = error as NSError
        if nsError.code == ASAuthorizationError.canceled.rawValue {
            return
        }
        errorMessage = error.localizedDescription
    }
}
