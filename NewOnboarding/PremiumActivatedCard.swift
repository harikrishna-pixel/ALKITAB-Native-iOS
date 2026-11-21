//
//  PremiumActivatedCard.swift
//  NKJV Bible
//
//  Success card after Month/Year (Premium) or Lifetime/Exit (Lifetime) purchase.
//  Same bg + bible + crown assets; content changes by plan.
//

import SwiftUI
import UIKit

enum PremiumActivatedKind {
    case monthYear
    case lifetime
}

/// Presents the success card on the top screen (Home after onboarding, or current screen in-app).
enum PremiumActivatedPresenter {
    private static var isPresenting = false

    static func isMonthOrYear(_ productId: String) -> Bool {
        guard !productId.isEmpty else { return false }
        return productId == SUBSCRIPTIONID_Six_month || productId == SUBSCRIPTIONID_OneYear
    }

    static func isLifetimeOrExit(_ productId: String) -> Bool {
        guard !productId.isEmpty else { return false }
        if productId == SUBSCRIPTIONID_LifeTime { return true }
        if !SUBSCRIPTIONID_ExitOffer.isEmpty, productId == SUBSCRIPTIONID_ExitOffer { return true }
        return false
    }

    static func kind(for productId: String) -> PremiumActivatedKind? {
        if isMonthOrYear(productId) { return .monthYear }
        if isLifetimeOrExit(productId) { return .lifetime }
        return nil
    }

    /// Call after purchase success + any Home redirect.
    static func presentAfterPurchase(productId: String) {
        guard let kind = kind(for: productId) else { return }
        // Let onboarding paywall → Home finish first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            presentNow(kind: kind)
        }
    }

    static func presentNow(kind: PremiumActivatedKind) {
        DispatchQueue.main.async {
            guard !isPresenting else { return }
            guard let top = OnboardingAuthManager.topViewController() else { return }
            isPresenting = true
            let host = UIHostingController(rootView: PremiumActivatedCard(kind: kind) {
                dismissHost(kind: kind)
            })
            host.modalPresentationStyle = .overFullScreen
            host.modalTransitionStyle = .crossDissolve
            host.view.backgroundColor = .clear
            top.present(host, animated: true)
        }
    }

    private static func dismissHost(kind: PremiumActivatedKind) {
        DispatchQueue.main.async {
            defer { isPresenting = false }
            if kind == .lifetime {
                // Lifetime card already shown after purchase — skip the later AI-entry notice.
                UserDefaults.standard.set(true, forKey: "LifetimeAIAccessNoticeShown")
            }
            OnboardingAuthManager.topViewController()?.dismiss(animated: true)
        }
    }
}

/// Shared shell (exact card bg + crown + bible). Content depends on `kind`.
struct PremiumActivatedCard: View {
    var kind: PremiumActivatedKind = .monthYear
    var onContinue: () -> Void

    private let titleBlue = Color(hex: "1A46C7")
    private let bodyInk = Color(hex: "1C2A44")
    private let subInk = Color(hex: "2F3D56")
    private let checkYellow = Color(hex: "F5C518")
    private let buttonTop = Color(hex: "2F6BFF")
    private let buttonBottom = Color(hex: "1B4FD8")
    private let aiBox = Color(hex: "EEF0FF")
    private let aiStroke = Color(hex: "C9CFFF")

    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width - horizontalPad(geo), maxCardWidth(geo))
            let height = min(width * (kind == .lifetime ? 1.36 : 1.40), geo.size.height - verticalPad(geo))

            ZStack {
                Color.black.opacity(0.48)
                    .ignoresSafeArea()

                card(width: width, height: height)
                    .frame(width: width, height: height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func horizontalPad(_ geo: GeometryProxy) -> CGFloat {
        geo.size.width >= 768 ? 120 : 32
    }

    private func verticalPad(_ geo: GeometryProxy) -> CGFloat {
        geo.size.width >= 768 ? 80 : 48
    }

    private func maxCardWidth(_ geo: GeometryProxy) -> CGFloat {
        if geo.size.width >= 1024 { return 400 }
        if geo.size.width >= 768 { return 380 }
        return 340
    }

    private func card(width: CGFloat, height: CGFloat) -> some View {
        let s = width / 340
        let headerShare: CGFloat = kind == .lifetime ? 0.42 : 0.40

        return ZStack {
            Image("premium_activated_card_bg")
                .resizable()
                .scaledToFill()
                // Crop baked-in white frame from the asset edge.
                .scaleEffect(1.035)
                .frame(width: width, height: height)
                .clipped()

            VStack(spacing: 0) {
                headerBlock(scale: s)
                    .frame(height: height * headerShare)

                Group {
                    if kind == .lifetime {
                        lifetimeBody(scale: s)
                    } else {
                        monthYearBody(scale: s)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, kind == .lifetime ? 20 * s : 24 * s)
                .padding(.top, kind == .lifetime ? 4 * s : 6 * s)
                .padding(.bottom, 20 * s)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26 * s, style: .continuous))
        // No white border — shadow only (both Premium + Lifetime).
        .shadow(color: Color.black.opacity(0.28), radius: 22 * s, y: 10 * s)
    }

    private func headerBlock(scale s: CGFloat) -> some View {
        VStack(spacing: kind == .lifetime ? 4 * s : 2 * s) {
            Image("premium_activated_crown")
                .resizable()
                .scaledToFit()
                .frame(width: kind == .lifetime ? 78 * s : 92 * s,
                       height: kind == .lifetime ? 40 * s : 48 * s)
                .padding(.top, kind == .lifetime ? 10 * s : 12 * s)

            if kind == .lifetime {
                Text("Congratulations!")
                    .font(.system(size: 28 * s, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 2, y: 1)

                Text("You're on the Lifetime Plan!")
                    .font(.system(size: 15 * s, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.top, 2 * s)
            } else {
                Text("Premium Activated!")
                    .font(.system(size: 26 * s, weight: .bold).italic())
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 2, y: 1)
                    .padding(.top, 2 * s)
            }

            Spacer(minLength: 0)

            Image("premium_activated_bible")
                .resizable()
                .scaledToFit()
                .frame(width: kind == .lifetime ? 140 * s : 148 * s,
                       height: kind == .lifetime ? 80 * s : 84 * s)
                .offset(y: kind == .lifetime ? 22 * s : 24 * s)
        }
        .frame(maxWidth: .infinity)
    }

    private func monthYearBody(scale s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("You're on a Premium Plan!")
                .font(.system(size: 20 * s, weight: .bold))
                .foregroundColor(titleBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 30 * s)

            Text("Enjoy unlimited access to all AI study features.")
                .font(.system(size: 14 * s, weight: .regular))
                .foregroundColor(subInk)
                .padding(.top, 6 * s)

            Rectangle()
                .fill(Color(hex: "E6ECF5"))
                .frame(height: 1)
                .padding(.top, 14 * s)

            VStack(alignment: .leading, spacing: 14 * s) {
                featureRow("Unlimited AI chat", scale: s)
                featureRow("Unlimited verse explanations and chapter summaries", scale: s)
                featureRow("Ad-free Bible reading", scale: s)
            }
            .padding(.top, 14 * s)

            ctaButton(title: "Continue Exploring", scale: s)
                .padding(.top, 18 * s)

            Spacer(minLength: 0)
        }
    }

    private func lifetimeBody(scale s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Welcome to Lifetime Access!")
                .font(.system(size: 19 * s, weight: .bold))
                .foregroundColor(titleBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 28 * s)

            Text("Enjoy an ad-free Bible reading experience.")
                .font(.system(size: 13.5 * s, weight: .regular))
                .foregroundColor(subInk)
                .padding(.top, 6 * s)

            aiCreditsBox(scale: s)
                .padding(.top, 14 * s)

            // Fixed gap like referral — do not stretch empty white on iPad.
            ctaButton(title: "Got it", scale: s)
                .padding(.top, 16 * s)

            Spacer(minLength: 0)
        }
    }

    private func aiCreditsBox(scale s: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E4E7FF"))
                    .frame(width: 38 * s, height: 38 * s)
                Image(systemName: "sparkles")
                    .font(.system(size: 15 * s, weight: .semibold))
                    .foregroundColor(Color(hex: "6B5CFF"))
            }

            VStack(alignment: .leading, spacing: 3 * s) {
                Text("AI Features Access")
                    .font(.system(size: 14 * s, weight: .bold))
                    .foregroundColor(titleBlue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text("Verse Explanation, Chapter Summary & Bible Companion")
                    .font(.system(size: 11 * s, weight: .medium))
                    .foregroundColor(Color(hex: "4A5A8C"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 10 * s)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(aiStroke)
                .frame(width: 1, height: 40 * s)
                .padding(.horizontal, 10 * s)

            VStack(spacing: 1 * s) {
                Text("20")
                    .font(.system(size: 20 * s, weight: .bold))
                    .foregroundColor(titleBlue)
                Text("Credits")
                    .font(.system(size: 10 * s, weight: .semibold))
                    .foregroundColor(Color(hex: "5A6BB0"))
            }
            .frame(width: 56 * s, height: 48 * s)
            .background(
                RoundedRectangle(cornerRadius: 12 * s, style: .continuous)
                    .fill(Color(hex: "E8EBFF"))
            )
        }
        .padding(.leading, 12 * s)
        .padding(.trailing, 10 * s)
        .padding(.vertical, 12 * s)
        .background(
            RoundedRectangle(cornerRadius: 16 * s, style: .continuous)
                .fill(aiBox)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16 * s, style: .continuous)
                .stroke(aiStroke, lineWidth: 1)
        )
    }

    private func ctaButton(title: String, scale s: CGFloat) -> some View {
        Button(action: onContinue) {
            Text(title)
                .font(.system(size: 16 * s, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52 * s)
                .background(
                    Capsule().fill(
                        LinearGradient(colors: [buttonTop, buttonBottom], startPoint: .top, endPoint: .bottom)
                    )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func featureRow(_ text: String, scale s: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 12 * s) {
            ZStack {
                Circle()
                    .fill(checkYellow)
                    .frame(width: 24 * s, height: 24 * s)
                Image(systemName: "checkmark")
                    .font(.system(size: 12 * s, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.top, 1 * s)

            Text(text)
                .font(.system(size: 15 * s, weight: .medium))
                .foregroundColor(bodyInk)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2 * s)
            Spacer(minLength: 0)
        }
    }
}
