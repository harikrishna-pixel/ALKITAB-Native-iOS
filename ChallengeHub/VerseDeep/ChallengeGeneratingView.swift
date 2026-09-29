//
//  ChallengeGeneratingView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeGeneratingView: View {
    let verseReference: String
    @State private var progress: CGFloat = 0.2

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(ChallengeVerseDeepTheme.blue)
                Text("VerseDeep")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            }
            .padding(.top, 12)

            Spacer()

            ZStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 16))
                    .foregroundColor(ChallengeVerseDeepTheme.blue.opacity(0.7))
                    .offset(x: -70, y: -40)
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "7EB6FF"))
                    .offset(x: 74, y: -28)
                Image(systemName: "book.fill")
                    .font(.system(size: 72))
                    .foregroundColor(ChallengeVerseDeepTheme.blue)
            }
            .frame(height: 140)

            Text("Creating Your Challenge")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .padding(.top, 20)

            Text("Building questions from\n\(verseReference)...")
                .font(.system(size: 15))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "E8EEFF"))
                    Capsule()
                        .fill(ChallengeVerseDeepTheme.blue)
                        .frame(width: max(12, geo.size.width * progress))
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 48)
            .padding(.top, 22)

            Spacer()

            Text("\"Let the word of Christ dwell in you richly...\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                .multilineTextAlignment(.center)
            Text("Colossians 3:16")
                .font(.system(size: 13))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .padding(.top, 4)
                .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                progress = 0.82
            }
        }
    }
}
