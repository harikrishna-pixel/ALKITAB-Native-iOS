//
//  ChallengeCreatedSuccessView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeCreatedSuccessView: View {
    let title: String
    let detail: String
    var onPlay: () -> Void
    var onShare: () -> Void
    var onInvite: () -> Void
    var onMyChallenges: () -> Void
    var onDone: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { (onDone ?? onMyChallenges)() }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill([Color(hex: "7EB6FF"), Color(hex: "F5C16C"), Color(hex: "F08A8A"), ChallengeVerseDeepTheme.blue][i % 4])
                        .frame(width: i % 2 == 0 ? 8 : 6, height: i % 2 == 0 ? 8 : 6)
                        .offset(x: CGFloat([-70, 60, -40, 75, -20, 40, -80, 20][i]),
                                y: CGFloat([-50, -40, -70, -10, 30, -60, 10, 40][i]))
                }
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(ChallengeVerseDeepTheme.blue)
            }
            .frame(height: 120)

            Text("Challenge Created!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .padding(.top, 8)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
            Text(detail)
                .font(.system(size: 14))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .padding(.top, 2)

            VStack(spacing: 12) {
                Button(action: onPlay) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Play Challenge Now")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(ChallengeVerseDeepTheme.blue)
                    .cornerRadius(14)
                }
                outlineButton("Share Challenge", icon: "square.and.arrow.up", action: onShare)
                outlineButton("Invite Friends", icon: "person.badge.plus", action: onInvite)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            Spacer()

            Button(action: onMyChallenges) {
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                    Text("Challenge saved in My Challenges")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
            }
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }

    private func outlineButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(ChallengeVerseDeepTheme.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(ChallengeVerseDeepTheme.blue.opacity(0.35), lineWidth: 1.5)
            )
        }
    }
}
