//
//  ChallengeInviteFriendsView.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct ChallengeInviteFriendsView: View {
    let shareUrl: String
    let challengeTitle: String
    var onBack: () -> Void
    var onShared: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(width: 36, height: 36)
                }
                Spacer()
                Text("Invite Friends to Play")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    peopleIllustration
                        .padding(.top, 4)

                    Text("Share God's Word in a fun way!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .padding(.top, 14)

                    Text("Invite your friends and family to play this challenge and grow together in Scripture.")
                        .font(.system(size: 15))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                    HStack(spacing: 10) {
                        Text(shareUrl.isEmpty ? "Link will appear here" : shareUrl)
                            .font(.system(size: 13))
                            .foregroundColor(ChallengeVerseDeepTheme.blue)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Button(action: copyLink) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ChallengeVerseDeepTheme.blue)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color(hex: "F4F6FA"))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.top, 22)

                    HStack(spacing: 22) {
                        brandIcon("WhatsApp", symbol: "message.fill", color: Color(hex: "25D366")) { openWhatsApp() }
                        brandIcon("Messages", symbol: "bubble.left.and.bubble.right.fill", color: Color(hex: "34C759")) { openMessages() }
                        brandIcon("Email", symbol: "envelope.fill", color: Color(hex: "3B82F6")) { openMail() }
                        brandIcon("More", symbol: "ellipsis", color: Color(hex: "C7C7CC"), glyph: ChallengeVerseDeepTheme.blueDeep) { openMore() }
                    }
                    .padding(.top, 22)

                    Text("Or invite directly from VerseDeep")
                        .font(.system(size: 13))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .padding(.top, 22)

                    Button(action: openMore) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                            Text("Invite from Contacts")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var peopleIllustration: some View {
        HStack(spacing: -8) {
            personBubble(Color(hex: "7EB6FF"), "person.fill")
            personBubble(Color(hex: "F5C16C"), "person.fill")
                .offset(y: -6)
            personBubble(Color(hex: "F08A8A"), "person.fill")
        }
        .padding(.bottom, 6)
        .overlay(
            Image(systemName: "iphone")
                .font(.system(size: 18))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .offset(y: 28)
        )
        .frame(height: 110)
    }

    private func personBubble(_ color: Color, _ symbol: String) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 72, height: 72)
            Circle()
                .fill(color)
                .frame(width: 56, height: 56)
            Image(systemName: symbol)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
    }

    private func brandIcon(_ title: String, symbol: String, color: Color, glyph: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(glyph)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(color))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var shareMessage: String {
        "Can you beat my score on this Bible challenge?\n\n\(challengeTitle)\n\nPlay this challenge: \(shareUrl)"
    }

    private func copyLink() {
        UIPasteboard.general.string = shareUrl
        OnboardingAuthManager.topViewController()?.view.makeToast("Link copied", duration: 1.5, position: .bottom)
    }

    private func openWhatsApp() {
        let encoded = shareMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "whatsapp://send?text=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            onShared()
        } else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .bottom)
        }
    }

    private func openMessages() {
        let encoded = shareMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:&body=\(encoded)") {
            UIApplication.shared.open(url)
            onShared()
        }
    }

    private func openMail() {
        let subject = challengeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = shareMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:?subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
            onShared()
        }
    }

    private func openMore() {
        guard let top = OnboardingAuthManager.topViewController() else { return }
        let vc = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        vc.completionWithItemsHandler = { _, completed, _, _ in
            if completed { onShared() }
        }
        top.present(vc, animated: true)
    }
}
