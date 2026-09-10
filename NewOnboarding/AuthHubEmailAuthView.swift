//
//  AuthHubEmailAuthView.swift
//  NKJV Bible
//
//  Email/password Sign Up, Login, Forgot Password + referral on Sign Up.
//

import SwiftUI
import IQKeyboardManager

enum AuthHubEmailMode {
    case signUp
    case login
}

struct AuthHubEmailAuthView: View {
    let mode: AuthHubEmailMode
    /// When set (Prayer Wall), called after success instead of navigating to IAP.
    var onAuthSuccess: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    /// Top trailing X (used by sheets). Off for onboarding create-account.
    var showsTopCloseButton: Bool = true

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var referralCode = ""
    @State private var isBusy = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?
    @State private var showForgot = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if showsTopCloseButton, let onCancel = onCancel {
                    HStack {
                        Spacer()
                        Button(action: onCancel) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.gray.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        Text(mode == .signUp ? "Create Account" : "Login")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(OnboardingTheme.paperInk)
                            .padding(.top, 8)

                        Text(mode == .signUp
                             ? "Save your progress. Optional referral code on sign up only."
                             : "Sign in with your email and password.")
                            .font(.system(size: 14))
                            .foregroundColor(OnboardingTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        if mode == .signUp {
                            field("Name", text: $name)
                        }
                        field("Email", text: $email, keyboard: .emailAddress)
                        secureField("Password", text: $password)
                        if mode == .signUp {
                            secureField("Confirm Password", text: $confirmPassword)
                            field("Friend's referral code (optional)", text: $referralCode)
                        }

                        if mode == .login {
                            Button("Forgot password?") {
                                showForgot = true
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(OnboardingTheme.primaryBlue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 26)
                        }

                        if isBusy {
                            SwiftUI.ProgressView()
                                .padding(.top, 4)
                        }

                        if let errorMessage = errorMessage, !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 26)
                        }

                        if let infoMessage = infoMessage, !infoMessage.isEmpty {
                            Text(infoMessage)
                                .font(.system(size: 13))
                                .foregroundColor(OnboardingTheme.grow)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 26)
                        }

                        Button(action: submit) {
                            Text(mode == .signUp ? "Sign Up" : "Login")
                                .font(.system(size: 16.5, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(OnboardingTheme.primaryBlue)
                                .cornerRadius(15)
                        }
                        .disabled(isBusy)
                        .padding(.horizontal, 26)
                        .padding(.top, 6)
                    }
                    .padding(.bottom, onCancel == nil ? 24 : 72)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let onCancel = onCancel {
                Button("Not Now", action: onCancel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(OnboardingTheme.paperInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "EEF2F8"))
                    .disabled(isBusy)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            IQKeyboardManager.shared().isEnabled = false
        }
        .onDisappear {
            IQKeyboardManager.shared().isEnabled = true
        }
        .sheet(isPresented: $showForgot) {
            AuthHubForgotPasswordView(initialEmail: email) {
                showForgot = false
            }
        }
    }

    private func field(
        _ title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        TextField(title, text: text)
            .keyboardType(keyboard)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color(hex: "F5F6FA"))
            .cornerRadius(12)
            .padding(.horizontal, 26)
    }

    private func secureField(_ title: String, text: Binding<String>) -> some View {
        SecureField(title, text: text)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color(hex: "F5F6FA"))
            .cornerRadius(12)
            .padding(.horizontal, 26)
    }

    private func submit() {
        errorMessage = nil
        infoMessage = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard AuthHubConfig.isConfigured else {
            errorMessage = AuthHubAPIError.notConfigured.localizedDescription
            return
        }
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        if mode == .signUp {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                errorMessage = "Name is required."
                return
            }
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }
            let code = referralCode.trimmingCharacters(in: .whitespacesAndNewlines)
            if let own = AuthHubSession.referralCode, !code.isEmpty, code == own {
                errorMessage = "You cannot use your own referral code."
                return
            }
            isBusy = true
            AuthHubAPI.shared.register(
                name: trimmedName,
                email: trimmedEmail,
                password: password,
                friendReferralCode: code.isEmpty ? nil : code
            ) { result in
                handleAuthResult(result)
            }
        } else {
            isBusy = true
            AuthHubAPI.shared.login(email: trimmedEmail, password: password) { result in
                handleAuthResult(result)
            }
        }
    }

    private func handleAuthResult(_ result: Result<AuthHubUser, Error>) {
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
                    DispatchQueue.main.async {
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
    }
}

struct AuthHubForgotPasswordView: View {
    let initialEmail: String
    let onDone: () -> Void

    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var resetToken: String = ""
    @State private var step = 0
    @State private var isBusy = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                Text(stepTitle)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 12)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(hex: "F5F6FA"))
                    .cornerRadius(12)
                    .disabled(step > 0)

                if step >= 1 {
                    TextField("OTP", text: $otp)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(hex: "F5F6FA"))
                        .cornerRadius(12)
                }
                if step >= 2 {
                    SecureField("New password", text: $password)
                        .padding()
                        .background(Color(hex: "F5F6FA"))
                        .cornerRadius(12)
                    SecureField("Confirm password", text: $confirmPassword)
                        .padding()
                        .background(Color(hex: "F5F6FA"))
                        .cornerRadius(12)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage).font(.system(size: 13)).foregroundColor(.red)
                }
                if let infoMessage = infoMessage {
                    Text(infoMessage).font(.system(size: 13)).foregroundColor(OnboardingTheme.grow)
                }

                Button(action: advance) {
                    Text(stepButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(OnboardingTheme.primaryBlue)
                        .cornerRadius(12)
                }
                .disabled(isBusy)

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDone)
                }
            }
            .onAppear {
                if email.isEmpty { email = initialEmail }
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case 0: return "Send OTP"
        case 1: return "Verify OTP"
        default: return "Reset Password"
        }
    }

    private var stepButtonTitle: String {
        switch step {
        case 0: return "Send OTP"
        case 1: return "Verify OTP"
        default: return "Reset Password"
        }
    }

    private func advance() {
        errorMessage = nil
        infoMessage = nil
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Email is required."
            return
        }
        isBusy = true
        switch step {
        case 0:
            AuthHubAPI.shared.sendForgotOTP(email: trimmed) { result in
                isBusy = false
                switch result {
                case .failure(let error): errorMessage = error.localizedDescription
                case .success:
                    infoMessage = "OTP sent. Check your email."
                    step = 1
                }
            }
        case 1:
            AuthHubAPI.shared.verifyForgotOTP(email: trimmed, otp: otp) { result in
                isBusy = false
                switch result {
                case .failure(let error): errorMessage = error.localizedDescription
                case .success(let token):
                    resetToken = token
                    infoMessage = "OTP verified. Set a new password."
                    step = 2
                }
            }
        default:
            guard password == confirmPassword, !password.isEmpty else {
                isBusy = false
                errorMessage = "Passwords must match."
                return
            }
            AuthHubAPI.shared.resetPassword(email: trimmed, token: resetToken, password: password) { result in
                isBusy = false
                switch result {
                case .failure(let error): errorMessage = error.localizedDescription
                case .success:
                    infoMessage = "Password updated. You can log in."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onDone() }
                }
            }
        }
    }
}
