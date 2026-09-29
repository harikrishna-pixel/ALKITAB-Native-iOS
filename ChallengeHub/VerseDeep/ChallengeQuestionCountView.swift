//
//  ChallengeQuestionCountView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeQuestionCountView: View {
    let kind: ChallengeKind
    let verseReference: String
    @Binding var selectedCount: Int
    var onBack: () -> Void
    var onGenerate: () -> Void

    private let counts = [1, 3, 5, 10]

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
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "E8EEFF"))
                            .frame(width: 72, height: 72)
                        Image(systemName: "doc.text")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(ChallengeVerseDeepTheme.blue)
                    }
                    .padding(.top, 12)

                    Text(displayTitle)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .multilineTextAlignment(.center)
                        .padding(.top, 18)
                        .padding(.horizontal, 24)

                    Text("From \(verseReference)")
                        .font(.system(size: 15))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .padding(.top, 6)

                    Text("Number of Questions")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    HStack(spacing: 12) {
                        ForEach(counts, id: \.self) { n in
                            Button(action: { selectedCount = n }) {
                                Text("\(n)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(selectedCount == n ? .white : ChallengeVerseDeepTheme.blueDeep)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedCount == n ? ChallengeVerseDeepTheme.blue : Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCount == n ? ChallengeVerseDeepTheme.blue : ChallengeVerseDeepTheme.cardBorder, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    Text("Up to \(selectedCount) quality question\(selectedCount == 1 ? "" : "s") can be created from this verse.")
                        .font(.system(size: 14))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }
            }

            Button(action: onGenerate) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Generate \(selectedCount) Question\(selectedCount == 1 ? "" : "s")")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(ChallengeVerseDeepTheme.blue)
                .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var displayTitle: String {
        "Create \(kind.title)"
    }
}
