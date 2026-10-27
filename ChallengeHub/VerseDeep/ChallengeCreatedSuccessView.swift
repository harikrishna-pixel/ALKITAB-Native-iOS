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
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                        .frame(width: 36, height: 36)
                        .accessibilityLabel("Close")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "34C759"))

            Text("Quiz Saved")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .padding(.top, 12)
            Text("Your quiz is saved as a draft.")
                .font(.system(size: 15))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Draft")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "8A5A00"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "FFF4D6"))
                    .cornerRadius(8)
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
            .padding(.horizontal, 24)
            .padding(.top, 24)

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
        .background(ChallengePhotoBackdrop(imageName: "VerseDeepHeroSunrise"))
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
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(ChallengeVerseDeepTheme.blue.opacity(0.35), lineWidth: 1.5)
            )
        }
    }
}
