//
//  BeforeYouContinueCreditsCard.swift
//  NKJV Bible
//
//  First-time AI credits notice after Lifetime / Exit purchase.
//

import SwiftUI
import UIKit

enum BeforeYouContinueCreditsNotice {
    private static let shownKey = "BeforeYouContinueCreditsNoticeShown"
    private static var isPresenting = false

    static var shouldShow: Bool {
        AIUsageLimiter.shared.ownsLifetimeAccess
            && !UserDefaults.standard.bool(forKey: shownKey)
    }

    static func markShown() {
        UserDefaults.standard.set(true, forKey: shownKey)
    }

    /// Presents once. `onContinue` runs after Got it (then credits spend / feature open).
    static func present(creditCost: Int = 20, onContinue: @escaping () -> Void) {
        DispatchQueue.main.async {
            guard shouldShow else {
                onContinue()
                return
            }
            guard !isPresenting else { return }
            guard let top = OnboardingAuthManager.topViewController() else {
                onContinue()
                return
            }
            if top.presentedViewController != nil {
                onContinue()
                return
            }
            isPresenting = true

            weak var hostRef: UIViewController?
            let finish: (_ proceed: Bool) -> Void = { proceed in
                if proceed {
                    markShown()
                }
                isPresenting = false
                guard let host = hostRef else {
                    if proceed { onContinue() }
                    return
                }
                host.dismiss(animated: true) {
                    guard proceed else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: onContinue)
                }
            }

            let host = UIHostingController(rootView: BeforeYouContinueCreditsCard(
                creditCost: creditCost,
                onClose: { finish(false) },
                onGotIt: { finish(true) }
            ))
            host.modalPresentationStyle = .overFullScreen
            host.modalTransitionStyle = .crossDissolve
            host.view.backgroundColor = .clear
            hostRef = host
            top.view.endEditing(true)
            top.present(host, animated: true)
        }
    }
}

struct BeforeYouContinueCreditsCard: View {
    var creditCost: Int = 20
    var onClose: () -> Void
    var onGotIt: () -> Void

    @State private var dontShowAgain = false

    private let titleBlue = Color(hex: "12315C")
    private let bodyGray = Color(hex: "6B7280")
    private let buttonBlue = Color(hex: "1C46B2")
    private let pillBg = Color(hex: "E8F0FF")
    private let pillInk = Color(hex: "1A46C7")

    var body: some View {
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(titleBlue.opacity(0.75))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text("Before You Continue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(titleBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                Text("Chats, Verse Explanation and Chapter Summary use")
                    .font(.system(size: 16))
                    .foregroundColor(bodyGray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 16)

                HStack(spacing: 6) {
                    Text("\(creditCost) credits")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(pillInk)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(pillBg))

                    Text("per request.")
                        .font(.system(size: 16))
                        .foregroundColor(bodyGray)
                }
                .padding(.top, 8)

                Rectangle()
                    .fill(Color(hex: "E5E7EB"))
                    .frame(height: 1)
                    .padding(.top, 22)

                Button(action: { dontShowAgain.toggle() }) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color(hex: "9CA3AF"), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            if dontShowAgain {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(buttonBlue)
                                    .frame(width: 22, height: 22)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        Text("Don't show this again")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(bodyGray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 18)

                Button(action: onGotIt) {
                    Text("Got it")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(buttonBlue))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 20)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 22)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 20, y: 10)
            .padding(.horizontal, 28)
        }
    }
}
