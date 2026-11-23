//
//  DailyLimitReachedCard.swift
//  NKJV Bible
//
//  Free-user daily AI limit card — Go Unlimited + Use N Credits.
//

import SwiftUI
import UIKit

enum DailyLimitReachedPresenter {

    static func freeUsedLine(for feature: AIUsageFeature) -> String {
        switch feature {
        case .aiChat:
            return "You've used today's free chats."
        case .explanation:
            return "You've used today's free verse explanations."
        case .chapterSummary:
            return "You've used today's free chapter summary."
        case .quiz:
            return "You've used today's free quiz."
        }
    }

    static func present(feature: AIUsageFeature,
                        creditCost: Int,
                        balance: Int = ChallengeWallet.coins,
                        showUnlimited: Bool,
                        onClose: @escaping () -> Void = {},
                        onUnlimited: @escaping () -> Void,
                        onUseCredits: @escaping () -> Void) {
        DispatchQueue.main.async {
            guard let top = OnboardingAuthManager.topViewController() else { return }
            if top.presentedViewController != nil { return }

            weak var hostRef: UIViewController?
            let close: (_ then: (() -> Void)?) -> Void = { then in
                guard let host = hostRef else {
                    then?()
                    return
                }
                host.dismiss(animated: true) {
                    guard let then = then else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: then)
                }
            }

            let host = UIHostingController(rootView: DailyLimitReachedCard(
                freeUsedLine: freeUsedLine(for: feature),
                creditCost: creditCost,
                balance: balance,
                showUnlimited: showUnlimited,
                onClose: { close(onClose) },
                onUnlimited: { close(onUnlimited) },
                onUseCredits: { close(onUseCredits) }
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

struct DailyLimitReachedCard: View {
    var freeUsedLine: String
    var creditCost: Int
    var balance: Int
    var showUnlimited: Bool
    var onClose: () -> Void
    var onUnlimited: () -> Void
    var onUseCredits: () -> Void

    private let titleBlue = Color(hex: "12315C")
    private let bodyInk = Color(hex: "1C2A44")
    private let buttonBlue = Color(hex: "1C46B2")
    private let softBlue = Color(hex: "E8F0FF")
    private let pillInk = Color(hex: "1A46C7")

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(titleBlue.opacity(0.8))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text("Daily Limit Reached")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(titleBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)

                Text(freeUsedLine)
                    .font(.system(size: 16))
                    .foregroundColor(bodyInk)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 14)

                HStack(spacing: 6) {
                    Text("You still have")
                        .font(.system(size: 16))
                        .foregroundColor(bodyInk)
                        .lineLimit(1)
                    Text("\(balance) credits")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(pillInk)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(softBlue))
                    Text("to continue.")
                        .font(.system(size: 16))
                        .foregroundColor(bodyInk)
                        .lineLimit(1)
                }
                .padding(.top, 10)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    if showUnlimited {
                        Button(action: onUnlimited) {
                            Text("Go Unlimited")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(buttonBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Capsule().fill(softBlue))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: onUseCredits) {
                        Text("Use \(creditCost) Credits")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Capsule().fill(buttonBlue))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)
            .padding(.bottom, 22)
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 20, y: 10)
            .padding(.horizontal, 28)
        }
    }
}
