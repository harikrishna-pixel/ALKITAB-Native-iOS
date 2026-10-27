//
//  ChallengeCreatorListsView.swift
//  NKJV Bible
//
//  Created quizzes, shared quizzes, quiz detail, and who played.
//

import SwiftUI
import UIKit

final class ChallengeCreatorDirectory: ObservableObject {
    @Published var challenges: [ChallengeSummary] = []
    @Published var attemptCounts: [String: Int] = [:]
    @Published var attemptsById: [String: [ChallengeAttempt]] = [:]
    @Published var isLoading = false
    @Published var message: String?

    var created: [ChallengeSummary] {
        challenges.filter { ($0.status ?? "active").lowercased() != "deleted" }
    }

    var shared: [ChallengeSummary] {
        created.filter { !($0.shareUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var totalPlayers: Int {
        created.reduce(0) { $0 + (attemptCounts[$1.id] ?? 0) }
    }

    private static let favoriteKey = "VerseDeepFavoriteQuizIds"

    var favoriteIds: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: Self.favoriteKey) ?? [])
    }

    var favorites: [ChallengeSummary] {
        created.filter { favoriteIds.contains($0.id) }
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }

    func toggleFavorite(_ id: String) {
        var ids = favoriteIds
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        UserDefaults.standard.set(Array(ids), forKey: Self.favoriteKey)
        objectWillChange.send()
    }

    var email: String {
        let stored = UserDefaults.standard.string(forKey: "OnboardingUserEmail")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if stored.isEmpty || stored.hasSuffix(".local") { return "" }
        return stored
    }

    var displayName: String {
        let local = email.split(separator: "@").first.map(String.init) ?? ""
        guard !local.isEmpty else { return "Creator" }
        return local.prefix(1).uppercased() + local.dropFirst()
    }

    func reload() {
        guard NetworkManager.sharedInstance.isConnectedToInternet() else {
            message = "No internet connection"
            return
        }
        if challenges.isEmpty { isLoading = true }
        CreatorChallengeService.shared.listChallenges { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.isLoading = false
                    self.challenges = []
                    self.message = error.localizedDescription
                case .success(let list):
                    let active = list.filter { ($0.status ?? "active").lowercased() != "deleted" }
                    if active.isEmpty {
                        self.isLoading = false
                        self.challenges = []
                        self.attemptCounts = [:]
                        self.message = "No quizzes yet. Create one, then players will show up here."
                    } else {
                        self.loadCounts(for: active)
                    }
                }
            }
        }
    }

    func loadAttempts(for id: String) {
        CreatorChallengeService.shared.getAttempts(challengeId: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let list) = result {
                    self.attemptsById[id] = list
                    self.attemptCounts[id] = list.count
                }
            }
        }
    }

    func pause(_ quiz: ChallengeSummary) {
        CreatorChallengeService.shared.updateChallengeStatus(id: quiz.id, status: "paused") { [weak self] _ in
            DispatchQueue.main.async {
                self?.reload()
            }
        }
    }

    func averageScore(for id: String) -> Int? {
        let scores = (attemptsById[id] ?? []).compactMap { $0.percentage }
        guard !scores.isEmpty else { return nil }
        return Int((scores.reduce(0, +) / Double(scores.count)).rounded())
    }

    private func loadCounts(for list: [ChallengeSummary]) {
        let group = DispatchGroup()
        var counts: [String: Int] = [:]
        var loadedAttempts: [String: [ChallengeAttempt]] = [:]
        for quiz in list {
            group.enter()
            CreatorChallengeService.shared.getAttempts(challengeId: quiz.id) { result in
                if case .success(let attempts) = result {
                    counts[quiz.id] = attempts.count
                    loadedAttempts[quiz.id] = attempts
                } else {
                    counts[quiz.id] = 0
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.challenges = list
            self.attemptCounts = counts
            self.attemptsById = loadedAttempts
            self.message = nil
        }
    }
}

struct ChallengeCreatorQuizListView: View {
    let title: String
    let quizzes: [ChallengeSummary]
    @ObservedObject var directory: ChallengeCreatorDirectory
    var showsFilters: Bool
    var draftFilters: Bool = false
    var onBack: () -> Void
    var onOpen: (ChallengeSummary) -> Void

    @State private var filter = "All"
    @State private var query = ""

    private var visible: [ChallengeSummary] {
        var list = quizzes
        if draftFilters {
            if filter == "Drafts" {
                list = list.filter { isDraft($0) }
            } else if filter == "Completed" {
                list = list.filter { !isDraft($0) }
            }
        } else if filter == "Shared" {
            list = list.filter { ($0.status ?? "active").lowercased() != "paused" }
        } else if filter == "Paused" {
            list = list.filter { ($0.status ?? "active").lowercased() == "paused" }
        }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            list = list.filter { ($0.title ?? "").localizedCaseInsensitiveContains(trimmed) }
        }
        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: title, onBack: onBack)
            if !showsFilters {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                    TextField("Search quizzes", text: $query)
                }
                .padding(12)
                .background(Color(hex: "F4F6FA"))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            if showsFilters {
                HStack(spacing: 8) {
                    ForEach(draftFilters ? ["All", "Drafts", "Completed"] : ["All", "Shared", "Paused"], id: \.self) { name in
                        Button(action: { filter = name }) {
                            Text(name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(filter == name ? .white : ChallengeVerseDeepTheme.blueDeep)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(filter == name ? ChallengeVerseDeepTheme.blue : Color(hex: "F4F6FA"))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            if directory.isLoading && quizzes.isEmpty {
                Spacer()
                Text("Loading…")
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                Spacer()
            } else if visible.isEmpty {
                Spacer()
                Text(directory.message ?? "No quizzes here yet.")
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(visible.enumerated()), id: \.element.id) { index, quiz in
                            Button(action: { onOpen(quiz) }) {
                                quizCard(quiz, index: index)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
    }

    private func quizCard(_ quiz: ChallengeSummary, index: Int) -> some View {
        HStack(spacing: 12) {
            Image(VerseDeepHero.name(at: index))
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipped()
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.title ?? "Quiz")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    .lineLimit(2)
                Text("\(quiz.totalQuestions ?? 0) Questions")
                    .font(.system(size: 13))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                Text("\(directory.attemptCounts[quiz.id] ?? 0) played")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blue)
                if !showsFilters, let average = directory.averageScore(for: quiz.id) {
                    Text("\(average)% completed")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                }
            }
            Spacer()
            Text(badgeTitle(quiz))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(badgeIsWarm(quiz) ? Color(hex: "8A5A00") : Color(hex: "1B7A3D"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(badgeIsWarm(quiz) ? Color(hex: "FFF4D6") : Color(hex: "E8F8EE"))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }

    private func isDraft(_ quiz: ChallengeSummary) -> Bool {
        (quiz.shareUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func badgeTitle(_ quiz: ChallengeSummary) -> String {
        if draftFilters { return isDraft(quiz) ? "Draft" : "Completed" }
        return (quiz.status ?? "active").lowercased() == "paused" ? "Paused" : "Shared"
    }

    private func badgeIsWarm(_ quiz: ChallengeSummary) -> Bool {
        if draftFilters { return isDraft(quiz) }
        return (quiz.status ?? "active").lowercased() == "paused"
    }
}

struct ChallengeCreatorQuizDetailView: View {
    let quiz: ChallengeSummary
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onBack: () -> Void
    var onParticipants: () -> Void
    var onAnalytics: () -> Void

    @State private var showShare = false

    private var isDraft: Bool {
        (quiz.shareUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Quiz Details", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Image("VerseDeepHeroSea")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 170)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(16)

                    HStack {
                        Text(quiz.title ?? "Quiz")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        Spacer()
                        Button(action: { directory.toggleFavorite(quiz.id) }) {
                            Image(systemName: directory.isFavorite(quiz.id) ? "heart.fill" : "heart")
                                .foregroundColor(Color(hex: "E85D4C"))
                        }
                    }
                    Text(isDraft ? "Draft" : "\(quiz.totalQuestions ?? 0) Questions · Shared")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDraft ? Color(hex: "8A5A00") : ChallengeVerseDeepTheme.muted)

                    HStack(spacing: 10) {
                        statTile(value: "\(directory.attemptCounts[quiz.id] ?? 0)", label: "Participants")
                        statTile(value: "\(directory.attemptCounts[quiz.id] ?? 0)", label: "Completed")
                        statTile(value: averageText, label: "Avg Score")
                    }

                    if isDraft {
                        detailButton("Continue Editing", filled: true, action: editingNote)
                        detailButton("Preview", filled: false, action: editingNote)
                        detailButton("Edit Details", filled: false, action: editingNote)
                        detailButton("Regenerate Questions", filled: false, action: editingNote)
                        detailButton("Delete Draft", filled: false, destructive: true) {
                            directory.pause(quiz)
                        }
                    } else {
                        detailButton("Share Again", filled: true) { showShare = true }
                        detailButton("View Quiz", filled: false) { openLink() }
                        detailButton("Question Analytics", filled: false, action: onAnalytics)
                        detailButton("Participants", filled: false, action: onParticipants)
                        if (quiz.status ?? "active").lowercased() != "paused" {
                            detailButton("Stop Sharing", filled: false, destructive: true) {
                                directory.pause(quiz)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .onAppear { directory.loadAttempts(for: quiz.id) }
        .sheet(isPresented: $showShare) {
            ChallengeCreatorShareFlow(
                shareUrl: quiz.shareUrl ?? "",
                challengeTitle: quiz.title ?? "Quiz",
                questionCount: quiz.totalQuestions ?? 0,
                kindTitle: "Quiz",
                onBack: { showShare = false },
                onShared: { showShare = false },
                onViewQuiz: { showShare = false }
            )
        }
    }

    private var averageText: String {
        if let average = directory.averageScore(for: quiz.id) {
            return "\(average)%"
        }
        return "—"
    }

    private func openLink() {
        guard let raw = quiz.shareUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = URL(string: raw), !raw.isEmpty else {
            OnboardingAuthManager.topViewController()?.view.makeToast("No share link yet", duration: 1.5, position: .top)
            return
        }
        UIApplication.shared.open(url)
    }

    private func editingNote() {
        OnboardingAuthManager.topViewController()?.view.makeToast("Edit questions from the preview while you are creating the quiz.", duration: 2.0, position: .top)
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }

    private func detailButton(_ title: String, filled: Bool, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(filled ? .white : (destructive ? Color(hex: "D70015") : ChallengeVerseDeepTheme.blue))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(filled ? ChallengeVerseDeepTheme.blue : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(filled ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChallengeCreatorParticipantsView: View {
    let quiz: ChallengeSummary
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onBack: () -> Void

    private let colors = ["1C46B2", "34C759", "F5A623", "7B61FF", "E85D4C", "5AC8FA"]

    private var people: [ChallengeAttempt] {
        directory.attemptsById[quiz.id] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Participants", onBack: onBack)
            HStack {
                Text("\(people.count) played")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if people.isEmpty {
                Spacer()
                Text("No one has played this quiz yet.")
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(people.enumerated()), id: \.offset) { index, person in
                            participantRow(person, index: index)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .onAppear { directory.loadAttempts(for: quiz.id) }
    }

    private func participantRow(_ person: ChallengeAttempt, index: Int) -> some View {
        let name = displayName(person)
        let pct = Int((person.percentage ?? 0).rounded())
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: colors[index % colors.count]))
                    .frame(width: 40, height: 40)
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                if let email = person.email, !email.isEmpty, email != name {
                    Text(email)
                        .font(.system(size: 12))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text("\(pct)%")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blue)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
    }

    private func displayName(_ person: ChallengeAttempt) -> String {
        let name = person.playerName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !name.isEmpty { return name }
        let email = person.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !email.isEmpty { return email }
        return "Player"
    }
}

struct ChallengeCreatorResultsView: View {
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onBack: () -> Void
    var onOpen: (ChallengeSummary) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "My Results", onBack: onBack)
            if directory.created.isEmpty {
                Spacer()
                Text(directory.message ?? "No results yet.")
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(directory.created, id: \.id) { quiz in
                            Button(action: { onOpen(quiz) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(quiz.title ?? "Quiz")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                                        Text("\(directory.attemptCounts[quiz.id] ?? 0) played")
                                            .font(.system(size: 13))
                                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.black.opacity(0.25))
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
    }
}
