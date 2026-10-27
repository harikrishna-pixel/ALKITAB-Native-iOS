//
//  OnboardingCreateAccountView.swift
//  NKJV Bible
//

import SwiftUI
import IQKeyboardManager

struct OnboardingCreateAccountView: View {
    @State private var mode: AuthHubEmailMode = .signUp

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $mode) {
                        Text("Sign Up").tag(AuthHubEmailMode.signUp)
                        Text("Login").tag(AuthHubEmailMode.login)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 26)
                    .padding(.top, max(geometry.safeAreaInsets.top, 16) + 16)

                    AuthHubEmailAuthView(
                        mode: mode,
                        onAuthSuccess: {
                            UIKitNavigationHelper.navigateToIAPView()
                        },
                        onCancel: {
                            UIKitNavigationHelper.navigateToIAPView()
                        },
                        showsTopCloseButton: false
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 8)
                    .background(Color.white)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            IQKeyboardManager.shared().isEnabled = false
        }
        .onDisappear {
            IQKeyboardManager.shared().isEnabled = true
        }
    }
}

#Preview {
    OnboardingCreateAccountView()
}
