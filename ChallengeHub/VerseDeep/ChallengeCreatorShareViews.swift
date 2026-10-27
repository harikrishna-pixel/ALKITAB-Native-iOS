//
//  ChallengeCreatorShareViews.swift
//  NKJV Bible
//
//  Share permission and share options, matching the VerseDeep creator mockup.
//

import SwiftUI
import UIKit

struct ChallengeCreatorShareFlow: View {
    let shareUrl: String
    let challengeTitle: String
    let questionCount: Int
    let kindTitle: String
    var onBack: () -> Void
    var onShared: () -> Void
    var onViewQuiz: () -> Void

    private static let rememberKey = "VerseDeepShareRemembered"

    @State private var showOptions: Bool
    @State private var rememberChoice: Bool

    init(
        shareUrl: String,
        challengeTitle: String,
        questionCount: Int,
        kindTitle: String,
        onBack: @escaping () -> Void,
        onShared: @escaping () -> Void,
        onViewQuiz: @escaping () -> Void
    ) {
        self.shareUrl = shareUrl
        self.challengeTitle = challengeTitle
        self.questionCount = questionCount
        self.kindTitle = kindTitle
        self.onBack = onBack
        self.onShared = onShared
        self.onViewQuiz = onViewQuiz
        let remembered = UserDefaults.standard.bool(forKey: Self.rememberKey)
        _showOptions = State(initialValue: remembered)
        _rememberChoice = State(initialValue: remembered)
    }

    var body: some View {
        Group {
            if showOptions {
                shareOptions
            } else {
                sharePermission
            }
        }
        .navigationBarHidden(true)
    }

    private var sharePermission: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Share Your Quiz?", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Image("VerseDeepHeroBible")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("To let others play this quiz, VerseDeep will upload this quiz to our servers and generate a unique link.")
                            .font(.system(size: 15))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)

                        permissionRow(icon: "link", text: "Your quiz will be accessible via a unique link")
                        permissionRow(icon: "person.2.fill", text: "You can track participants and view results")
                        permissionRow(icon: "hand.raised.fill", text: "You can stop sharing anytime")

                        Button(action: { rememberChoice.toggle() }) {
                            HStack(spacing: 10) {
                                Image(systemName: rememberChoice ? "checkmark.square.fill" : "square")
                                    .foregroundColor(ChallengeVerseDeepTheme.blue)
                                Text("Remember my choice")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            VStack(spacing: 8) {
                Button(action: allowAndShowLink) {
                    Text("Allow & Create Link")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(ChallengeVerseDeepTheme.blue)
                        .cornerRadius(14)
                }
                Button(action: onBack) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(ChallengePhotoBackdrop(imageName: "VerseDeepHeroBible"))
    }

    private var shareOptions: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Share", onBack: { showOptions = false })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Image("VerseDeepHeroSunrise")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)

                    Text("Your Quiz is Ready to Share!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .multilineTextAlignment(.center)

                    Text(challengeTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    Text("\(questionCount) Questions · \(kindTitle)")
                        .font(.system(size: 14))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)

                    Text(shareUrl.isEmpty ? "Link will appear here" : shareUrl)
                        .font(.system(size: 13))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    HStack(spacing: 18) {
                        shareIcon("WhatsApp", symbol: "message.fill", color: Color(hex: "25D366"), action: openWhatsApp)
                        shareIcon("Messages", symbol: "bubble.left.and.bubble.right.fill", color: Color(hex: "34C759"), action: openMessages)
                        shareIcon("Instagram", symbol: "camera.fill", color: Color(hex: "E1306C"), action: openInstagram)
                        shareIcon("More", symbol: "ellipsis", color: Color(hex: "8E8E93"), action: openMore)
                    }
                    .padding(.top, 8)
                }
            }

            VStack(spacing: 8) {
                Button(action: openMore) {
                    Text("Share Link")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(ChallengeVerseDeepTheme.blue)
                        .cornerRadius(14)
                }
                Button(action: onViewQuiz) {
                    Text("View Quiz")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
    }

    private func permissionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ChallengeVerseDeepTheme.blue)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func shareIcon(_ title: String, symbol: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(color))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func allowAndShowLink() {
        UserDefaults.standard.set(rememberChoice, forKey: Self.rememberKey)
        showOptions = true
    }

    private var shareMessage: String {
        "Can you beat my score on this Bible challenge?\n\n\(challengeTitle)\n\nPlay this challenge: \(shareUrl)"
    }

    private func openWhatsApp() {
        let encoded = shareMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "whatsapp://send?text=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Please install WhatsApp to share", duration: 2.0, position: .top)
        }
    }

    private func openMessages() {
        ChallengeShareFinish.shared.presentMessages(body: shareMessage, onSent: onShared)
    }

    private func openInstagram() {
        UIPasteboard.general.string = shareUrl
        if let url = URL(string: "instagram://app"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            OnboardingAuthManager.topViewController()?.view.makeToast("Link copied. Please install Instagram to share", duration: 2.0, position: .top)
        }
    }

    private func openMore() {
        guard let top = OnboardingAuthManager.topViewController() else { return }
        let vc = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        vc.completionWithItemsHandler = { activity, completed, _, _ in
            if completed, activity != nil { onShared() }
        }
        vc.popoverPresentationController?.sourceView = top.view
        vc.popoverPresentationController?.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.maxY, width: 0, height: 0)
        top.present(vc, animated: true)
    }
}
