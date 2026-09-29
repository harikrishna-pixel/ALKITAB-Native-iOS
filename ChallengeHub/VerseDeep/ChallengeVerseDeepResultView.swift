//
//  ChallengeVerseDeepResultView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeVerseDeepResultView: View {
    let correct: Int
    let total: Int
    let elapsed: TimeInterval
    var challengeTitle: String = ""
    var onPlayAgain: () -> Void
    var onShare: () -> Void
    var onDone: () -> Void

    private var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total) * 100).rounded())
    }

    private var timeText: String {
        let s = Int(elapsed.rounded())
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            ZStack {
                confetti
                Image(systemName: "trophy.fill")
                    .font(.system(size: 56))
                    .foregroundColor(ChallengeVerseDeepTheme.gold)
            }
            .frame(height: 90)

            Text("Challenge Completed!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .padding(.top, 8)
            if !challengeTitle.isEmpty {
                Text(challengeTitle)
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                    .padding(.top, 4)
            }

            HStack(spacing: 10) {
                statCard(icon: "checkmark.circle.fill", tint: ChallengeVerseDeepTheme.green, value: "\(correct)/\(total)", label: "Correct")
                statCard(icon: "star.fill", tint: ChallengeVerseDeepTheme.gold, value: "\(percent)%", label: "Score")
                statCard(icon: "clock.fill", tint: ChallengeVerseDeepTheme.blue, value: timeText, label: "Time")
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            VStack(spacing: 4) {
                Text("\"Your word is a lamp for my feet, a light on my path.\"")
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    .multilineTextAlignment(.center)
                Text("Psalm 119:105")
                    .font(.system(size: 13))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
            }
            .padding(.horizontal, 28)
            .padding(.top, 18)

            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Play Again")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(ChallengeVerseDeepTheme.blue)
                    .cornerRadius(14)
                }
                Button(action: onShare) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Challenge")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "D6DCE8"), lineWidth: 1)
                    )
                }
                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }

    private var confetti: some View {
        ZStack {
            dot(Color(hex: "7EB6FF"), -54, -28, 7)
            dot(Color(hex: "F5C16C"), 48, -24, 6)
            dot(Color(hex: "F08A8A"), -30, 30, 5)
            dot(ChallengeVerseDeepTheme.blue, 36, 26, 6)
            dot(Color(hex: "34C759"), 8, -40, 5)
        }
    }

    private func dot(_ color: Color, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .offset(x: x, y: y)
    }

    private func statCard(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(tint)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "F7F8FA"))
        .cornerRadius(14)
    }
}
