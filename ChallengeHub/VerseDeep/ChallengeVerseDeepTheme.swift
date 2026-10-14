//
//  ChallengeVerseDeepTheme.swift
//  NKJV Bible
//

import SwiftUI

enum ChallengeVerseDeepTheme {
    static let blue = Color(hex: "1C46B2")
    static let blueDeep = Color(hex: "0B1B3A")
    static let green = Color(hex: "34C759")
    static let greenBg = Color(hex: "E8F8EE")
    static let pageBg = Color.white
    static let cardBorder = Color.black.opacity(0.08)
    static let muted = Color.black.opacity(0.45)
    static let gold = Color(hex: "C9A227")
}

struct ChallengePhotoBackdrop: View {
    var imageName: String

    var body: some View {
        ZStack {
            Color.white
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.45),
                                Color.white
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Spacer(minLength: 0)
            }
        }
        .ignoresSafeArea()
    }
}
