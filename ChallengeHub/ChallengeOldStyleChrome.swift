//
//  ChallengeOldStyleChrome.swift
//  NKJV Bible
//
//  Old Quiz visual chrome for Challenge Hub games.
//  Does not change ChallengeGameFactory / question content logic.
//

import SwiftUI
import UIKit

enum ChallengeLifelineKind {
    case fiftyFifty
    case hint
    case skip
}

enum ChallengeWallet {
    static var coins: Int {
        UserDefaults.standard.integer(forKey: "WalletMoney")
    }

    static func spend(_ amount: Int) -> Bool {
        let balance = coins
        guard balance >= amount else { return false }
        UserDefaults.standard.set(balance - amount, forKey: "WalletMoney")
        return true
    }

    static var fiftyFiftyCost: Int { HalfCoin }
    static var hintCost: Int { HintCoins }
    static var skipCost: Int { HintCoins }

    /// Same route as classic Quiz coin button → Wallet screen.
    static func openWalletScreen() {
        DispatchQueue.main.async {
            guard
                let top = OnboardingAuthManager.topViewController(),
                let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController
            else { return }
            if let nav = top.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                top.present(vc, animated: true)
            }
        }
    }
}

/// Shared old-style shell: blue header, coins, hearts, progress, lifelines, Check Answer.
struct ChallengeOldStyleShell<Content: View>: View {
    var onBack: () -> Void
    var lives: Int
    var questionNumber: Int
    var questionTotal: Int
    var caption: String
    var primaryTitle: String
    var primaryEnabled: Bool
    var onPrimary: () -> Void
    var fiftyFiftyEnabled: Bool
    var hintEnabled: Bool
    var skipEnabled: Bool
    var onLifeline: (ChallengeLifelineKind) -> Void
    var walletTick: Int
    @ViewBuilder var content: () -> Content

    @State private var refreshTick = 0
    private let blue = Color(hex: "1C46B2")

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            VStack(spacing: 10) {
                heartsRow
                questionProgress
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    content()
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)

                    lifelineRow
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            }

            Button(action: onPrimary) {
                HStack(spacing: 8) {
                    Text(primaryTitle)
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(primaryEnabled ? blue : Color.gray.opacity(0.45))
                .cornerRadius(12)
            }
            .disabled(!primaryEnabled)
            .padding(.horizontal, 16)
            .padding(.top, 4)

            Text(caption)
                .font(.system(size: 12))
                .foregroundColor(Color.black.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
        .onAppear { refreshTick += 1 }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refreshTick += 1
        }
    }

    private var headerBar: some View {
        ZStack {
            blue.ignoresSafeArea(edges: .top)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                Spacer()
                Text("Memory Challenge")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                coinPill
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .padding(.top, 4)
        }
        .frame(height: 56)
    }

    private var coinPill: some View {
        Button(action: {
            ChallengeWallet.openWalletScreen()
        }) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F5C518"))
                        .frame(width: 18, height: 18)
                    Text("$")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "8A5A00"))
                }
                Text("\(ChallengeWallet.coins)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B3A"))
                    .id("\(walletTick)-\(refreshTick)")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var heartsRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < lives ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundColor(i < lives ? Color(hex: "E53935") : Color.black.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var questionProgress: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Question \(max(questionNumber, 1))/\(max(questionTotal, 1))")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.black.opacity(0.55))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.08))
                    Capsule()
                        .fill(blue)
                        .frame(
                            width: geo.size.width * CGFloat(max(questionNumber, 1)) / CGFloat(max(questionTotal, 1))
                        )
                }
            }
            .frame(height: 5)
        }
    }

    private var lifelineRow: some View {
        HStack(spacing: 10) {
            lifelineButton(
                title: "50/50",
                systemImage: "circle.lefthalf.filled",
                cost: ChallengeWallet.fiftyFiftyCost,
                enabled: fiftyFiftyEnabled,
                kind: .fiftyFifty
            )
            lifelineButton(
                title: "Hint",
                systemImage: "lightbulb.fill",
                cost: ChallengeWallet.hintCost,
                enabled: hintEnabled,
                kind: .hint
            )
            lifelineButton(
                title: "Skip",
                systemImage: "forward.fill",
                cost: ChallengeWallet.skipCost,
                enabled: skipEnabled,
                kind: .skip
            )
        }
    }

    private func lifelineButton(
        title: String,
        systemImage: String,
        cost: Int,
        enabled: Bool,
        kind: ChallengeLifelineKind
    ) -> some View {
        Button(action: { onLifeline(kind) }) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(enabled ? blue : Color.gray.opacity(0.45))
                        .frame(height: 24)
                    Text("\(cost)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(hex: "8A5A00"))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(hex: "F5C518"))
                        .cornerRadius(6)
                        .offset(x: 10, y: -8)
                }
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(enabled ? blue : Color.gray.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .opacity(enabled ? 1 : 0.55)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
    }
}

struct ChallengeOldStyleResult: View {
    var scoreText: String
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Great job!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "0B1B3A"))
            Text(scoreText)
                .font(.system(size: 16))
                .foregroundColor(Color.black.opacity(0.55))
            Button(action: onDone) {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
    }
}
