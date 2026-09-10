//
//  PrayerWallLoginView.swift
//  NKJV Bible
//

import SwiftUI

/// Login sheet for Prayer Wall actions only. Uses AuthHub email/password.
struct PrayerWallLoginView: View {
    let onSuccess: () -> Void
    let onCancel: () -> Void
    @State private var mode: AuthHubEmailMode = .login

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $mode) {
                Text("Login").tag(AuthHubEmailMode.login)
                Text("Sign Up").tag(AuthHubEmailMode.signUp)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 24)
            .padding(.top, 16)

            AuthHubEmailAuthView(
                mode: mode,
                onAuthSuccess: onSuccess,
                onCancel: onCancel
            )
        }
        .background(Color.white.ignoresSafeArea())
    }
}
