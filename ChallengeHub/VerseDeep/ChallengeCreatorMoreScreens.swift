//
//  ChallengeCreatorMoreScreens.swift
//  NKJV Bible
//
//  Preview, favorites, question analytics, and creator settings.
//

import SwiftUI
import UIKit

struct ChallengeQuizPreviewView: View {
    let verseReference: String
    @Binding var questions: [ChallengeVerseDeepPlayQuestion]
    var onBack: () -> Void
    var onRegenerate: () -> Void
    var onSave: () -> Void

    @State private var index = 0
    @State private var selectedOffset: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Quiz Preview", onBack: onBack)
            if questions.isEmpty {
                Spacer()
                Text("No questions yet.")
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                Spacer()
            } else {
                let safeIndex = min(index, questions.count - 1)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(verseReference)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ChallengeVerseDeepTheme.blue)
                        Text("Question \(safeIndex + 1) of \(questions.count)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)

                        Text(questions[safeIndex].prompt)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(Array(questions[safeIndex].options.enumerated()), id: \.offset) { offset, option in
                            previewOption(option, offset: offset, correctIndex: questions[safeIndex].correctIndex)
                        }
                    }
                    .padding(20)
                }

                HStack(spacing: 12) {
                    if safeIndex > 0 {
                        Button(action: { index = max(0, safeIndex - 1); selectedOffset = nil }) {
                            Text("Previous")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(ChallengeVerseDeepTheme.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(ChallengeVerseDeepTheme.blue, lineWidth: 1))
                        }
                    }
                    Button(action: {
                        if safeIndex >= questions.count - 1 {
                            onSave()
                        } else {
                            index = min(questions.count - 1, safeIndex + 1)
                            selectedOffset = nil
                        }
                    }) {
                        Text(safeIndex >= questions.count - 1 ? "Save Quiz" : "Next")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(ChallengeVerseDeepTheme.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)

                HStack(spacing: 16) {
                    Button(action: onRegenerate) {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(ChallengeVerseDeepTheme.blue)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
    }

    private func previewOption(_ option: String, offset: Int, correctIndex: Int) -> some View {
        let letter = ["A", "B", "C", "D", "E", "F"][min(offset, 5)]
        let revealed = selectedOffset != nil
        let correct = revealed && offset == correctIndex
        let wrong = revealed && selectedOffset == offset && offset != correctIndex
        return Button(action: {
            guard selectedOffset == nil else { return }
            selectedOffset = offset
        }) {
            HStack(spacing: 10) {
                Text(letter)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(correct ? Color(hex: "1B7A3D") : ChallengeVerseDeepTheme.blueDeep)
                    .frame(width: 24)
                Text(option)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Spacer()
                if correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "34C759"))
                } else if wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "D70015"))
                }
            }
            .padding(12)
            .background(correct ? Color(hex: "E8F8EE") : (wrong ? Color(hex: "FDECEC") : Color.white))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        correct ? Color(hex: "34C759") : (wrong ? Color(hex: "D70015") : Color.black.opacity(0.08)),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChallengeCreatorFavoritesView: View {
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onBack: () -> Void
    var onOpen: (ChallengeSummary) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Favorites", onBack: onBack)
            if directory.favorites.isEmpty {
                Spacer()
                Image(systemName: "heart")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "E85D4C"))
                Text("No favorite quizzes yet.")
                    .font(.system(size: 15))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
                    .padding(.top, 8)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(directory.favorites, id: \.id) { quiz in
                            Button(action: { onOpen(quiz) }) {
                                HStack {
                                    Image("VerseDeepHeroBible")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipped()
                                        .cornerRadius(10)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(quiz.title ?? "Quiz")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                                        Text("\(quiz.totalQuestions ?? 0) Questions")
                                            .font(.system(size: 13))
                                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.black.opacity(0.25))
                                }
                                .padding(12)
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

struct ChallengeCreatorAnalyticsView: View {
    let quiz: ChallengeSummary
    @ObservedObject var directory: ChallengeCreatorDirectory
    var onBack: () -> Void

    private var people: [ChallengeAttempt] {
        directory.attemptsById[quiz.id] ?? []
    }

    private var average: Int {
        directory.averageScore(for: quiz.id) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Question Analytics", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(quiz.title ?? "Quiz")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                    Text("\(quiz.totalQuestions ?? 0) Questions · \(people.count) played")
                        .font(.system(size: 14))
                        .foregroundColor(ChallengeVerseDeepTheme.muted)

                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color(hex: "E8EEFF"), lineWidth: 10)
                            Circle()
                                .trim(from: 0, to: CGFloat(average) / 100)
                                .stroke(ChallengeVerseDeepTheme.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Text("\(average)%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                        }
                        .frame(width: 96, height: 96)

                        VStack(alignment: .leading, spacing: 8) {
                            statLine("Played", "\(people.count)", Color(hex: "34C759"))
                            statLine("Average score", "\(average)%", ChallengeVerseDeepTheme.blue)
                            statLine("Questions", "\(quiz.totalQuestions ?? 0)", Color(hex: "F5A623"))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)

                    Text("Who played")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)

                    if people.isEmpty {
                        Text("No answers yet. Scores appear here after someone plays.")
                            .font(.system(size: 14))
                            .foregroundColor(ChallengeVerseDeepTheme.muted)
                    } else {
                        ForEach(Array(people.enumerated()), id: \.offset) { _, person in
                            let pct = Int((person.percentage ?? 0).rounded())
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(person.playerName?.isEmpty == false ? (person.playerName ?? "Player") : (person.email ?? "Player"))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                                    Spacer()
                                    Text("\(pct)%")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(ChallengeVerseDeepTheme.blue)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color(hex: "EEF2F8"))
                                        Capsule()
                                            .fill(ChallengeVerseDeepTheme.blue)
                                            .frame(width: geo.size.width * CGFloat(min(max(pct, 0), 100)) / 100)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .onAppear { directory.loadAttempts(for: quiz.id) }
    }

    private func statLine(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(ChallengeVerseDeepTheme.muted)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
        }
    }
}

struct ChallengeCreatorSettingsView: View {
    var onBack: () -> Void

    @State private var notificationsOn = true
    @State private var showName = UserDefaults.standard.bool(forKey: "VerseDeepCreatorShowName")
    @State private var emailReports = UserDefaults.standard.bool(forKey: "VerseDeepCreatorEmailReports")
    @State private var confirmSignOut = false

    var body: some View {
        VStack(spacing: 0) {
            ChallengeCreatorHeader(title: "Settings", onBack: onBack)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    toggleRow("Notifications", "Quiz updates stay with your app notification settings.", isOn: $notificationsOn)
                    toggleRow("Show my name to participants", "Uses the name on your profile.", isOn: $showName)
                    toggleRow("Email me quiz reports", "Saved on this device.", isOn: $emailReports)
                    Button(action: { confirmSignOut = true }) {
                        HStack {
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "D70015"))
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert(isPresented: $confirmSignOut) {
            Alert(
                title: Text("Sign Out"),
                message: Text("If you sign out, you can't create challenges."),
                primaryButton: .destructive(Text("Sign Out")) {
                    ChallengeQuizAccess.signOutOfQuiz()
                    onBack()
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: showName) { value in
            UserDefaults.standard.set(value, forKey: "VerseDeepCreatorShowName")
        }
        .onChange(of: emailReports) { value in
            UserDefaults.standard.set(value, forKey: "VerseDeepCreatorEmailReports")
        }
    }

    private func toggleRow(_ title: String, _ detail: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeVerseDeepTheme.blueDeep)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(ChallengeVerseDeepTheme.muted)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, 12)
    }
}
