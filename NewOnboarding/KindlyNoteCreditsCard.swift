//
//  KindlyNoteCreditsCard.swift
//  NKJV Bible
//
//  Shared “Kindly Note” after purchase — Quiz (once) and Wallet (once).
//

import SwiftUI
import UIKit

enum KindlyNoteCreditsSurface {
    case quiz
    case wallet

    var shownKey: String {
        switch self {
        case .quiz: return "PayNote"
        case .wallet: return "WalletPayNote"
        }
    }
}

enum KindlyNoteCreditsNotice {
    private static var isPresenting = false

    static func shouldShow(surface: KindlyNoteCreditsSurface) -> Bool {
        !UserDefaults.standard.bool(forKey: surface.shownKey) && hasPurchasedAccess()
    }

    /// Same purchase gate as the quiz PayNote overlay.
    static func hasPurchasedAccess() -> Bool {
        if PaymentHistory.sharedInstance.hasActivePurchase() { return true }
        if LegacyPaidAppService.shared.isLegacyPaidAppUser { return true }
        if PaymentHistory.sharedInstance.paymentInfo() == false && ADS_TYPE != 0 { return true }
        let paymentId = UserDefaults.standard.string(forKey: "PaymentId") ?? ""
        let lower = paymentId.lowercased()
        if !lower.isEmpty && lower.contains("lifetime") { return true }
        let ids = [
            SUBSCRIPTIONID_LifeTime,
            SUBSCRIPTIONID_ExitOffer,
            FallbackIAPConstants.lifetimeProductID,
            FallbackIAPConstants.exitOfferProductID
        ]
        return ids.contains { !$0.isEmpty && $0.caseInsensitiveCompare(paymentId) == .orderedSame }
    }

    static func presentIfNeeded(surface: KindlyNoteCreditsSurface) {
        DispatchQueue.main.async {
            guard shouldShow(surface: surface) else { return }
            guard !isPresenting else { return }
            guard let top = OnboardingAuthManager.topViewController() else { return }
            if top.presentedViewController != nil { return }

            isPresenting = true
            weak var hostRef: UIViewController?
            let finish: () -> Void = {
                UserDefaults.standard.set(true, forKey: surface.shownKey)
                isPresenting = false
                guard let host = hostRef else { return }
                host.dismiss(animated: true)
            }

            let host = UIHostingController(rootView: KindlyNoteCreditsCard(
                onClose: finish,
                onGotIt: finish
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

struct KindlyNoteCreditsCard: View {
    var onClose: () -> Void
    var onGotIt: () -> Void

    private let titleBlue = Color(hex: "12315C")
    private let bodyInk = Color(hex: "374151")
    private let buttonBlue = Color(hex: "1C46B2")
    private let borderBlue = Color(hex: "B8D0F5")
    private let dividerGray = Color(hex: "E5E7EB")

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

                Text("Kindly Note")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(titleBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)

                Text("Earn Wallet Credits by watching reward ads, even with an active Paid Plan.")
                    .font(.system(size: 16))
                    .foregroundColor(bodyInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 18)
                    .padding(.horizontal, 4)

                Rectangle()
                    .fill(dividerGray)
                    .frame(height: 1)
                    .padding(.top, 18)

                Text("Use your Credits for Quiz and AI Feature Access.")
                    .font(.system(size: 16))
                    .foregroundColor(bodyInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 18)
                    .padding(.horizontal, 4)

                Button(action: onGotIt) {
                    Text("Okay, Got it")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(buttonBlue))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 22)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 22)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(borderBlue, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.14), radius: 18, y: 8)
            .padding(.horizontal, 28)
        }
    }
}
