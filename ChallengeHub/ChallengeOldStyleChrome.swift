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

enum ChallengeQuizTheme {
    static var accent: Color {
        Color(UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)
    }
}

private struct ChallengeSwitchActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var challengeSwitchAction: (() -> Void)? {
        get { self[ChallengeSwitchActionKey.self] }
        set { self[ChallengeSwitchActionKey.self] = newValue }
    }
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

/// Shared top block inside the white quiz card — reference + instruction (UI only).
struct ChallengeQuizContentHeader: View {
    let reference: String
    let instruction: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reference)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ChallengeQuizTheme.accent)
            Text(instruction)
                .font(.system(size: 15))
                .foregroundColor(Color.black.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Fill-in-the-blank verse layout matching the classic quiz reading flow (UI only).
struct ChallengeFillVerseBoard: View {
    let tokens: [String]
    let blankIndices: [Int]
    let filled: [Int: String]
    let selectedBlank: Int?
    let isLocked: Bool
    let isWrongBlank: (Int) -> Bool
    var onTapBlank: (Int) -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            ChallengeVerseFlowLayout(spacing: 5, lineSpacing: 8) {
                wordViews
            }
        } else {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 36), spacing: 5, alignment: .leading)],
                alignment: .leading,
                spacing: 8
            ) {
                wordViews
            }
        }
    }

    @ViewBuilder
    private var wordViews: some View {
        ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
            if blankIndices.contains(index) {
                let wrong = isWrongBlank(index)
                Button(action: { if !isLocked { onTapBlank(index) } }) {
                    Text(filled[index] ?? "______")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(
                            wrong ? Color(hex: "D70015") :
                                (filled[index] == nil ? Color.black.opacity(0.35) : ChallengeQuizTheme.accent)
                        )
                        .underline(color: selectedBlank == index ? ChallengeQuizTheme.accent : Color.black.opacity(0.2))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLocked)
            } else {
                Text(token + " ")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
    }
}

/// Word bank chips styled like the legacy fill-in quiz (UI only).
struct ChallengeWordBankGrid: View {
    let words: [String]
    let hiddenWords: Set<String>
    let isWrongWord: (String) -> Bool
    let isLocked: Bool
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Word bank")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.black.opacity(0.45))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
                ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                    if !hiddenWords.contains(word) {
                        let wrong = isWrongWord(word)
                        Button(action: { onSelect(word) }) {
                            Text(word)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(wrong ? Color(hex: "D70015") : Color(hex: "0B1B3A"))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(wrong ? Color(hex: "FDECEC") : Color(hex: "EEF1F7"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(wrong ? Color(hex: "D70015") : Color.black.opacity(0.08), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isLocked)
                    }
                }
            }
        }
    }
}

/// Multiple-choice row styled like legacy quiz answer cells (UI only).
struct ChallengeQuizOptionRow: View {
    let title: String
    let isSelected: Bool
    let showCorrect: Bool
    let showWrong: Bool
    let isDisabled: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: showCorrect ? "checkmark.circle.fill" : (showWrong ? "xmark.circle.fill" : (isSelected ? "largecircle.fill.circle" : "circle")))
                    .foregroundColor(
                        showCorrect ? Color(hex: "34C759") :
                            (showWrong ? Color(hex: "D70015") :
                                (isSelected ? ChallengeQuizTheme.accent : Color.black.opacity(0.25)))
                    )
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "0B1B3A"))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(14)
            .background(
                showCorrect ? Color(hex: "E8F8EE") :
                    (showWrong ? Color(hex: "FDECEC") : Color(hex: "F7F8FC"))
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        showCorrect ? Color(hex: "34C759") :
                            (showWrong ? Color(hex: "D70015") :
                                (isSelected ? ChallengeQuizTheme.accent : Color.black.opacity(0.08))),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

@available(iOS 16.0, *)
private struct ChallengeVerseFlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

/// Quiz-style header bar (Mark as Read / Challenge Hub list).
struct ChallengeQuizHeaderBar: View {
    let title: String
    var showBackButton: Bool = true
    var onBack: (() -> Void)? = nil
    var walletTick: Int = 0

    private var accent: Color { ChallengeQuizTheme.accent }

    var body: some View {
        ZStack {
            accent.ignoresSafeArea(edges: .top)
            HStack(spacing: 8) {
                if showBackButton, let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }
                Spacer(minLength: 4)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                ChallengeQuizCoinPill(walletTick: walletTick)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .padding(.top, 4)
        }
        .frame(height: 56)
    }
}

struct ChallengeQuizCoinPill: View {
    var walletTick: Int
    @State private var refreshTick = 0

    var body: some View {
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
        .onAppear { refreshTick += 1 }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refreshTick += 1
        }
    }
}

/// Shared old-style shell: blue header, coins, hearts, progress, lifelines, Check Answer.
struct ChallengeOldStyleShell<Content: View>: View {
    var screenTitle: String = "Bible Quiz"
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
    /// When true, middle content is not wrapped in ScrollView (e.g. Word Search drag grid).
    var contentScrollDisabled: Bool = false
    @ViewBuilder var content: () -> Content

    @Environment(\.challengeSwitchAction) private var onChangeChallenge
    @State private var refreshTick = 0

    private var accent: Color { ChallengeQuizTheme.accent }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            VStack(spacing: 10) {
                heartsRow
                questionProgress
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)

            Group {
                if contentScrollDisabled {
                    VStack(spacing: 0) {
                        shellScrollBody
                        Spacer(minLength: 0)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        shellScrollBody
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
                .background(primaryEnabled ? accent : Color.gray.opacity(0.45))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
        .onAppear { refreshTick += 1 }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refreshTick += 1
        }
    }

    private var shellScrollBody: some View {
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

    private var headerBar: some View {
        ZStack {
            accent.ignoresSafeArea(edges: .top)
            HStack(spacing: 8) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                Spacer(minLength: 4)
                Text(screenTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 4)
                if let onChangeChallenge {
                    Button(action: onChangeChallenge) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Change")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.22))
                        .cornerRadius(14)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                coinPill
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
            .padding(.top, 4)
        }
        .frame(height: 56)
    }

    private var coinPill: some View {
        ChallengeQuizCoinPill(walletTick: walletTick)
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
                        .fill(accent)
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
                        .foregroundColor(enabled ? accent : Color.gray.opacity(0.45))
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
                    .foregroundColor(enabled ? accent : Color.gray.opacity(0.45))
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
                    .background(ChallengeQuizTheme.accent)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
    }
}
