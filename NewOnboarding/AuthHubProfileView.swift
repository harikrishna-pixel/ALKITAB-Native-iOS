//
//  AuthHubProfileView.swift
//  NKJV Bible
//
//  Profile: name, email, referral code, login / logout.
//  Forgot password stays on the existing Login UI.
//

import SwiftUI
import UIKit

struct AuthHubProfileView: View {
    /// Pops/dismisses Profile back to Settings (or previous screen).
    var onBack: (() -> Void)? = nil

    @State private var isLoggedIn = AuthHubSession.isLoggedIn
    @State private var displayName = AuthHubSession.name ?? ""
    @State private var displayEmail = AuthHubSession.email ?? ""
    @State private var referralCode = AuthHubSession.referralCode ?? ""
    @State private var referralCount = AuthHubSession.referralCount
    @State private var showAuthSheet = false
    @State private var authMode: AuthHubEmailMode = .login
    @State private var copied = false
    @State private var showLogoutConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: goBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundColor(OnboardingTheme.primaryBlue)
                }
                Spacer()
                Text("Profile")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(OnboardingTheme.paperInk)
                Spacer()
                // Balance the leading Back so title stays centered
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                    Text("Back").font(.system(size: 17))
                }
                .opacity(0)
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(OnboardingTheme.primaryBlue.opacity(0.85))
                        .padding(.top, 12)

                    if isLoggedIn {
                        loggedInContent
                    } else {
                        loggedOutContent
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { refreshFromSession(); refreshProfileIfNeeded() }
        .sheet(isPresented: $showAuthSheet) {
            authSheet
        }
        .alert(isPresented: $showLogoutConfirm) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    OnboardingAuthManager.logOut()
                    refreshFromSession()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func goBack() {
        if let onBack = onBack {
            onBack()
            return
        }
        guard let top = OnboardingAuthManager.topViewController() else { return }
        if let nav = top.navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            top.dismiss(animated: true, completion: nil)
        }
    }

    private var loggedOutContent: some View {
        VStack(spacing: 14) {
            Text("You're not logged in")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(OnboardingTheme.paperInk)

            Text("Sign in to see your profile and referral code.")
                .font(.system(size: 14))
                .foregroundColor(OnboardingTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                authMode = .login
                showAuthSheet = true
            }) {
                Text("Login")
                    .font(.system(size: 16.5, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(OnboardingTheme.primaryBlue)
                    .cornerRadius(15)
            }
            .padding(.top, 8)

            Button(action: {
                authMode = .signUp
                showAuthSheet = true
            }) {
                Text("Sign Up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(OnboardingTheme.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "F5F6FA"))
                    .cornerRadius(15)
            }
        }
    }

    private var loggedInContent: some View {
        VStack(spacing: 16) {
            Text(displayName.isEmpty ? "Profile" : displayName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(OnboardingTheme.paperInk)

            if !displayEmail.isEmpty {
                Text(displayEmail)
                    .font(.system(size: 14))
                    .foregroundColor(OnboardingTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Your referral code")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(OnboardingTheme.textSecondary)

                HStack {
                    Text(referralCode.isEmpty ? "—" : referralCode)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(OnboardingTheme.paperInk)
                        .lineLimit(1)

                    Spacer()

                    if !referralCode.isEmpty {
                        Button(action: copyReferral) {
                            Text(copied ? "Copied" : "Copy")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(OnboardingTheme.primaryBlue)
                        }
                    }
                }

                Text("Friends referred: \(referralCount)")
                    .font(.system(size: 13))
                    .foregroundColor(OnboardingTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F5F6FA"))
            .cornerRadius(14)

            Button(action: { showLogoutConfirm = true }) {
                Text("Log Out")
                    .font(.system(size: 16.5, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(15)
            }
            .padding(.top, 8)
        }
    }

    private var authSheet: some View {
        VStack(spacing: 0) {
            Picker("", selection: $authMode) {
                Text("Login").tag(AuthHubEmailMode.login)
                Text("Sign Up").tag(AuthHubEmailMode.signUp)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 24)
            .padding(.top, 16)

            AuthHubEmailAuthView(
                mode: authMode,
                onAuthSuccess: {
                    // Stay on Profile after login — do not jump to IAP/reader.
                    DispatchQueue.main.async {
                        showAuthSheet = false
                        refreshFromSession()
                    }
                },
                onCancel: {
                    showAuthSheet = false
                }
            )
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func refreshFromSession() {
        isLoggedIn = AuthHubSession.isLoggedIn || UserDefaults.standard.bool(forKey: "OnboardingLoggedIn")
        displayName = AuthHubSession.name ?? ""
        displayEmail = AuthHubSession.email ?? ""
        referralCode = AuthHubSession.referralCode ?? ""
        referralCount = AuthHubSession.referralCount
    }

    private func refreshProfileIfNeeded() {
        guard AuthHubSession.isLoggedIn else { return }
        AuthHubAPI.shared.fetchProfile { result in
            DispatchQueue.main.async {
                if case .success(let json) = result {
                    AuthHubAPI.applyProfileJSON(json)
                    refreshFromSession()
                }
            }
        }
    }

    private func copyReferral() {
        guard !referralCode.isEmpty else { return }
        UIPasteboard.general.string = referralCode
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copied = false
        }
    }
}
