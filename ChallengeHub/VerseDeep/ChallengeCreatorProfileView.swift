//
//  ChallengeCreatorProfileView.swift
//  NKJV Bible
//
//  Creator profile, matching the VerseDeep dashboard layout.
//

import SwiftUI

enum VerseDeepHero {
    static let names = [
        "VerseDeepHeroBible",
        "VerseDeepHeroCross",
        "VerseDeepHeroSunrise",
        "VerseDeepHeroPrayer",
        "VerseDeepHeroCandle",
        "VerseDeepHeroCandles",
        "VerseDeepHeroSea"
    ]

    static func name(at index: Int) -> String {
        names[abs(index) % names.count]
    }
}

enum CreatorHubPage: Equatable {
    case profile
    case created
    case shared
    case results
    case detail(String)
    case participants(String)
}

struct ChallengeCreatorHeader: View {
    let title: String
    var onBack: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack = onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        .frame(width: 36, height: 36)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}

struct ChallengeCreatorHubView: View {
    var onClose: () -> Void

    @StateObject private var directory = ChallengeCreatorDirectory()
    @State private var page: CreatorHubPage = .profile
    @State private var listSource: CreatorHubPage = .created

    var body: some View {
        Group {
            switch page {
            case .profile:
                ChallengeCreatorProfileView(
                    directory: directory,
                    onClose: onClose,
                    onOpen: { page = $0 }
                )
            case .created:
                ChallengeCreatorQuizListView(
                    title: "My Created Quizzes",
                    quizzes: directory.created,
                    directory: directory,
                    showsFilters: true,
                    onBack: { page = .profile },
                    onOpen: {
                        listSource = .created
                        page = .detail($0.id)
                    }
                )
            case .shared:
                ChallengeCreatorQuizListView(
                    title: "My Shared Quizzes",
                    quizzes: directory.shared,
                    directory: directory,
                    showsFilters: false,
                    onBack: { page = .profile },
                    onOpen: {
                        listSource = .shared
                        page = .detail($0.id)
                    }
                )
            case .results:
                ChallengeCreatorResultsView(
                    directory: directory,
                    onBack: { page = .profile },
                    onOpen: { page = .participants($0.id) }
                )
            case .detail(let id):
                if let quiz = directory.created.first(where: { $0.id == id }) {
                    ChallengeCreatorQuizDetailView(
                        quiz: quiz,
                        directory: directory,
                        onBack: { page = listSource },
                        onParticipants: { page = .participants(id) }
                    )
                } else {
                    missingQuiz(onBack: { page = .profile })
                }
            case .participants(let id):
                if let quiz = directory.created.first(where: { $0.id == id }) {
                    ChallengeCreatorParticipantsView(
                        quiz: quiz,
                        directory: directory,
                        onBack: { page = .detail(id) }
                    )
                } else {
                    missingQuiz(onBack: { page = .profile })
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { directory.reload() }
    }

    private func missingQuiz(onBack: @escaping () -> Void) -> some View {
        VStack {
            ChallengeCreatorHeader(title: "Quiz", onBack: onBack)
            Spacer()
            Text("This quiz is no longer available.")
                .foregroundColor(ChallengeVerseDeepTheme.muted)
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct ChallengeCreatorProfileView: View {
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onClose: () -> Void
    var onOpen: (CreatorHubPage) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Profile", onBack: onClose)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Image("VerseDeepHeroPrayer")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 3)

                        Text(directory.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        Text(directory.email.isEmpty ? "Creator on this device" : directory.email)
                            .font(.system(size: 14))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                            .lineLimit(1)
                    }
                    .padding(.top, 12)

                    VStack(spacing: 12) {
                        profileRow(
                            icon: "square.and.pencil",
                            tint: Color(hex: "1C46B2"),
                            title: "My Created Quizzes",
                            count: directory.created.count,
                            page: .created
                        )
                        profileRow(
                            icon: "square.and.arrow.up",
                            tint: Color(hex: "34C759"),
                            title: "My Shared Quizzes",
                            count: directory.shared.count,
                            page: .shared
                        )
                        profileRow(
                            icon: "chart.bar.fill",
                            tint: Color(hex: "F5A623"),
                            title: "My Results",
                            count: directory.totalPlayers,
                            page: .results
                        )
                    }
                    .padding(.horizontal, 20)

                    if let message = directory.message, directory.created.isEmpty {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                }
                .padding(.bottom, 28)
            }
        }
        .background(
            ZStack {
                Color.white
                VStack {
                    Image("VerseDeepHeroSunrise")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .overlay(Color.white.opacity(0.82))
                    Spacer()
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        )
    }

    private func profileRow(icon: String, tint: Color, title: String, count: Int, page: CreatorHubPage) -> some View {
        Button(action: { onOpen(page) }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 40, height: 40)
                    .background(tint.opacity(0.12))
                    .cornerRadius(12)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(tint.opacity(0.12))
                    .clipShape(Capsule())
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.25))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
