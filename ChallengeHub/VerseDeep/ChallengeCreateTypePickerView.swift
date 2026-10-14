//
//  ChallengeCreateTypePickerView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeCreateTypePickerView: View {
    var verseReference: String
    var onBack: (() -> Void)?
    var onSelect: (ChallengeKind) -> Void

    private let kinds: [ChallengeKind] = ChallengeKind.allCases

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Create a New Quiz")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    Text("Choose a quiz type to get started.")
                        .font(.system(size: 14))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                    Text(verseReference)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ChallengeVerseDeepTheme.blue)

                    ForEach(kinds) { kind in
                        Button(action: { onSelect(kind) }) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: kind.iconBgHex))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: kind.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: kind.iconTintHex))
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(typeTitle(kind))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                                    Text(typeDetail(kind))
                                        .font(.system(size: 13))
                                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.25))
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(ChallengeVerseDeepTheme.cardBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(20)
            }
        }
        .background(ChallengeVerseDeepTheme.pageBg.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(width: 36, height: 36)
                }
            }
            Spacer()
            Text("Create a New Quiz")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func typeTitle(_ kind: ChallengeKind) -> String {
        switch kind {
        case .fillVerse: return "Fill in the Blanks"
        case .quickQuiz: return "Multiple Choice"
        case .trueFalse: return "True or False"
        case .verseMatch: return "Match"
        case .wordSearch: return "Verse Search"
        }
    }

    private func typeDetail(_ kind: ChallengeKind) -> String {
        switch kind {
        case .fillVerse: return "Remember the missing words"
        case .quickQuiz: return "Choose the correct answer"
        case .trueFalse: return "Test your understanding"
        case .verseMatch: return "Connect related words or ideas"
        case .wordSearch: return "Find the correct verse or reference"
        }
    }
}
