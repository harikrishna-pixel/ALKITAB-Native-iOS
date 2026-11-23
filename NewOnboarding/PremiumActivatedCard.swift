//
//  PremiumActivatedCard.swift
//  NKJV Bible
//
//  Success card after Month/Year (Premium) or Lifetime/Exit (Lifetime) purchase.
//  Matches referral layouts on phone + iPad: content height, white border, no overflow.
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
                UserDefaults.standard.set(true, forKey: "LifetimeAIAccessNoticeShown")
            }
            OnboardingAuthManager.topViewController()?.dismiss(animated: true)
        }
    }
}

/// Shared shell. Content depends on `kind`. Height fits content so crown/CTA never clip.
struct PremiumActivatedCard: View {
    var kind: PremiumActivatedKind = .monthYear
    var onContinue: () -> Void

    private let titleBlue = Color(hex: "0B2E8A")
    private let bodyInk = Color(hex: "1C2A44")
    private let subInk = Color(hex: "2F3D56")
    private let checkYellow = Color(hex: "FACC15")
    private let ctaBlue = Color(hex: "0B46C1")
    private let headerTop = Color(hex: "1A46C7")
    private let headerBottom = Color(hex: "0D3AA8")
    private let bodyFill = Color(hex: "FFFDF9")
    private let aiBox = Color(hex: "EEF0FF")
    private let aiStroke = Color(hex: "C9CFFF")
    private let corner: CGFloat = 30

    var body: some View {
        GeometryReader { geo in
            let width = cardWidth(for: geo)
            let s = max(0.92, min(width / 340, 1.35))

            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                card(scale: s)
                    .frame(width: width)
                    .padding(.horizontal, horizontalInset(geo))
                    .padding(.vertical, max(geo.safeAreaInsets.top, geo.safeAreaInsets.bottom, 24))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func horizontalInset(_ geo: GeometryProxy) -> CGFloat {
        geo.size.width >= 768 ? max(geo.size.width * 0.16, 48) : max(geo.size.width * 0.06, 18)
    }

    private func cardWidth(for geo: GeometryProxy) -> CGFloat {
        let usable = geo.size.width - horizontalInset(geo) * 2
        if geo.size.width >= 1024 {
            return min(usable, 520)
        }
        if geo.size.width >= 768 {
            return min(usable, 500)
        }
        return min(usable, 360)
    }

    private func card(scale s: CGFloat) -> some View {
        let content = VStack(spacing: 0) {
            headerBlock(scale: s)

            Group {
                if kind == .lifetime {
                    lifetimeBody(scale: s)
                } else {
                    monthYearBody(scale: s)
                }
            }
            .frame(maxWidth: .infinity)
            .background(bodyFill)
        }

        return content
            .background(bodyFill)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 24, y: 12)
    }

    private func headerBlock(scale s: CGFloat) -> some View {
        let headerH: CGFloat = kind == .lifetime ? 188 * s : 200 * s
        let bibleW: CGFloat = kind == .lifetime ? 150 * s : 156 * s
        let bibleH: CGFloat = kind == .lifetime ? 86 * s : 90 * s

        return ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [headerTop, headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(PremiumHeaderWave())

            VStack(spacing: 0) {
                Image("premium_activated_crown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: kind == .lifetime ? 82 * s : 88 * s,
                           height: kind == .lifetime ? 42 * s : 46 * s)
                    .padding(.top, 18 * s)

                if kind == .lifetime {
                    Text("Congratulations!")
                        .font(.system(size: 28 * s, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6 * s)

                    Text("You're on the Lifetime Plan!")
                        .font(.system(size: 15 * s, weight: .semibold))
                        .foregroundColor(.white.opacity(0.96))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6 * s)
                        .padding(.horizontal, 12 * s)
                } else {
                    Text("Premium Activated!")
                        .font(.system(size: 26 * s, weight: .bold).italic())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8 * s)
                }

                Spacer(minLength: 8 * s)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, bibleH * 0.42)

            Image("premium_activated_bible")
                .resizable()
                .scaledToFit()
                .frame(width: bibleW, height: bibleH)
                .offset(y: bibleH * 0.28)
        }
        .frame(height: headerH)
        .clipped()
    }

    private func monthYearBody(scale s: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text("You're on a Premium Plan!")
                .font(.system(size: 20 * s, weight: .bold))
                .foregroundColor(titleBlue)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 36 * s)

            Text("Enjoy unlimited access to all AI study features.")
                .font(.system(size: 14.5 * s, weight: .regular))
                .foregroundColor(subInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8 * s)
                .padding(.horizontal, 4 * s)

            Rectangle()
                .fill(Color(hex: "E6ECF5"))
                .frame(height: 1)
                .padding(.top, 16 * s)

            VStack(alignment: .leading, spacing: 14 * s) {
                featureRow("Unlimited AI chat", scale: s)
                featureRow("Unlimited verse explanations and chapter summaries", scale: s)
                featureRow("Ad-free Bible reading", scale: s)
            }
            .padding(.top, 16 * s)

            ctaButton(title: "Continue Exploring", scale: s, widthFraction: 1)
                .padding(.top, 20 * s)
                .padding(.bottom, 26 * s)
        }
        .padding(.horizontal, 24 * s)
    }

    private func lifetimeBody(scale s: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Welcome to Lifetime Access!")
                .font(.system(size: 20 * s, weight: .bold))
                .foregroundColor(titleBlue)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 36 * s)

            Text("Enjoy an ad-free Bible reading experience.")
                .font(.system(size: 14.5 * s, weight: .regular))
                .foregroundColor(subInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8 * s)

            aiCreditsBox(scale: s)
                .padding(.top, 16 * s)

            ctaButton(title: "Continue Exploring", scale: s, widthFraction: 0.62)
                .padding(.top, 20 * s)
                .padding(.bottom, 26 * s)
        }
        .padding(.horizontal, 22 * s)
    }

    private func aiCreditsBox(scale s: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E4E7FF"))
                    .frame(width: 40 * s, height: 40 * s)
                Image(systemName: "sparkles")
                    .font(.system(size: 15 * s, weight: .semibold))
                    .foregroundColor(Color(hex: "6B5CFF"))
            }

            VStack(alignment: .leading, spacing: 3 * s) {
                Text("AI Features Access")
                    .font(.system(size: 14 * s, weight: .bold))
                    .foregroundColor(titleBlue)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Verse Explanation, Chapter Summary & Bible Companion")
                    .font(.system(size: 11.5 * s, weight: .medium))
                    .foregroundColor(Color(hex: "4A5A8C"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 10 * s)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(aiStroke)
                .frame(width: 1, height: 42 * s)
                .padding(.horizontal, 10 * s)

            VStack(spacing: 1 * s) {
                Text("20")
                    .font(.system(size: 20 * s, weight: .bold))
                    .foregroundColor(titleBlue)
                Text("Credits")
                    .font(.system(size: 10 * s, weight: .semibold))
                    .foregroundColor(Color(hex: "5A6BB0"))
            }
            .frame(width: 58 * s, height: 50 * s)
            .background(
                RoundedRectangle(cornerRadius: 12 * s, style: .continuous)
                    .fill(Color(hex: "DDE5FF"))
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
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
    }

    private func ctaButton(title: String, scale s: CGFloat, widthFraction: CGFloat) -> some View {
        Button(action: onContinue) {
            Text(title)
                .font(.system(size: 16.5 * s, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52 * s)
                .background(Capsule().fill(ctaBlue))
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal, widthFraction >= 1 ? 0 : (1 - widthFraction) * 80 * s)
    }

    private func featureRow(_ text: String, scale s: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 12 * s) {
            ZStack {
                Circle()
                    .fill(checkYellow)
                    .frame(width: 24 * s, height: 24 * s)
                Image(systemName: "checkmark")
                    .font(.system(size: 12 * s, weight: .bold))
                    .foregroundColor(Color(hex: "0B2E8A"))
            }
            .padding(.top, 1 * s)

            Text(text)
                .font(.system(size: 15 * s, weight: .medium))
                .foregroundColor(bodyInk)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2 * s)
            Spacer(minLength: 0)
        }
    }
}

/// Soft double-hump wave under the blue header (matches card_bg curve without stretching the PNG).
private struct PremiumHeaderWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let waveY = h * 0.78
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: waveY))
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.88),
            control1: CGPoint(x: w * 0.92, y: waveY),
            control2: CGPoint(x: w * 0.84, y: h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.28, y: h * 0.88),
            control1: CGPoint(x: w * 0.58, y: h * 0.98),
            control2: CGPoint(x: w * 0.42, y: h * 0.98)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: waveY),
            control1: CGPoint(x: w * 0.16, y: h * 0.88),
            control2: CGPoint(x: w * 0.08, y: waveY)
        )
        path.closeSubpath()
        return path
    }
}
