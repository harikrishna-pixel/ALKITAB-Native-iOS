//
//  InsufficientCreditsCard.swift
//  NKJV Bible
//
//  Shown when Lifetime / Exit has too few credits for an AI feature.
//

import SwiftUI
import UIKit

enum InsufficientCreditsPresenter {
    private static var isPresenting = false

    static func present(balance: Int = ChallengeWallet.coins, creditCost: Int = 20) {
        DispatchQueue.main.async {
            guard !isPresenting else { return }
            guard var presenter = OnboardingAuthManager.topViewController() else { return }
            while let shown = presenter.presentedViewController {
                presenter = shown
            }
            isPresenting = true

            weak var hostRef: UIViewController?
            let close: (_ openWallet: Bool) -> Void = { openWallet in
                defer { isPresenting = false }
                guard let host = hostRef else {
                    if openWallet { ChallengeWallet.openWalletScreen() }
                    return
                }
                host.dismiss(animated: true) {
                    guard openWallet else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        ChallengeWallet.openWalletScreen()
                    }
                }
            }

            let host = UIHostingController(rootView: InsufficientCreditsCard(
                balance: balance,
                creditCost: creditCost,
                onClose: { close(false) },
                onGetMore: { close(true) }
            ))
            host.modalPresentationStyle = .overFullScreen
            host.modalTransitionStyle = .crossDissolve
            host.view.backgroundColor = .clear
            hostRef = host
            presenter.view.endEditing(true)
            presenter.present(host, animated: true)
        }
    }
}

struct InsufficientCreditsCard: View {
    var balance: Int
    var creditCost: Int
    var onClose: () -> Void
    var onGetMore: () -> Void

    private let titleBlue = Color(hex: "12315C")
    private let bodyBlue = Color(hex: "1A3A6E")
    private let buttonBlue = Color(hex: "1C46B2")
    private let tipBg = Color(hex: "EAF2FF")
    private let tipInk = Color(hex: "1A46C7")

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "8A94A8"))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Image("insufficient_credits_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 148, height: 100)
                    .padding(.top, 2)

                Text("Insufficient Credits")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(titleBlue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)

                Text("Your Wallet balance is \(balance) credits. Get more credits to continue using AI features.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(bodyBlue.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                    .padding(.horizontal, 4)

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tipInk)
                        .padding(.top, 1)

                    Text("Each AI response uses \(creditCost) credits for Verse Explanation, Chapter Summary & Bible Companion.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(tipInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(tipBg)
                )
                .padding(.top, 16)

                Button(action: onGetMore) {
                    HStack(spacing: 10) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Get More Credits")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule(style: .continuous).fill(buttonBlue)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 18)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 20)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 8)
            .padding(.horizontal, 28)
        }
    }
}
