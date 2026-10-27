//
//  ChallengeQuestionCountView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeQuestionCountView: View {
    let kind: ChallengeKind
    let verseReference: String
    @Binding var selectedCount: Int?
    var onBack: () -> Void
    var onGenerate: (Int, ChallengeDifficulty) -> Void

    @State private var difficulty: ChallengeDifficulty?
    private let counts = [5, 10, 15]
    private var canGenerate: Bool { selectedCount != nil && difficulty != nil }

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

                    Text("Create from Scripture")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .multilineTextAlignment(.center)
                        .padding(.top, 18)
                        .padding(.horizontal, 24)

                    Text("\(kind.title) · \(verseReference)")
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

                    Text("Difficulty")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    HStack(spacing: 12) {
                        ForEach(ChallengeDifficulty.allCases) { level in
                            Button(action: { difficulty = level }) {
                                Text(level.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(difficulty == level ? .white : ChallengeVerseDeepTheme.blueDeep)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(difficulty == level ? ChallengeVerseDeepTheme.blue : Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(difficulty == level ? ChallengeVerseDeepTheme.blue : ChallengeVerseDeepTheme.cardBorder, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    if let selectedCount {
                        Text("Up to \(selectedCount) quality question\(selectedCount == 1 ? "" : "s") can be created from this verse.")
                            .font(.system(size: 14))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 16)
                    }
                }
            }

            Button(action: {
                guard let selectedCount, let difficulty else { return }
                onGenerate(selectedCount, difficulty)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Generate Questions")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canGenerate ? ChallengeVerseDeepTheme.blue : Color.gray.opacity(0.4))
                .cornerRadius(14)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canGenerate)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
