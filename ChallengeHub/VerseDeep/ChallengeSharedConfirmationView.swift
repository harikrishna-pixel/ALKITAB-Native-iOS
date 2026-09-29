//
//  ChallengeSharedConfirmationView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeSharedConfirmationView: View {
    var onMyChallenges: () -> Void
    var onCreateAnother: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(ChallengeVerseDeepTheme.green)
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Challenge Shared!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .padding(.top, 18)

            Text("You've just shared God's Word with others. ✨")
                .font(.system(size: 15))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 8)

            VStack(spacing: 8) {
                Text("\"Let us encourage one another to love and do good deeds.\"")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    .multilineTextAlignment(.center)
                Text("Hebrews 10:24")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "F7F8FA"))
            .cornerRadius(14)
            .padding(.horizontal, 24)
            .padding(.top, 22)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onMyChallenges) {
                    Text("Back to My Challenges")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(ChallengeVerseDeepTheme.blueDeep)
                        .cornerRadius(14)
                }
                Button(action: onCreateAnother) {
                    Text("Create Another Challenge")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}
