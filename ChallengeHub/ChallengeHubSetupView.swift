//
//  ChallengeHubSetupView.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct ChallengeHubSetupView: View {
    let prefillBook: String
    let prefillChapter: String
    var onBack: () -> Void
    var onStart: (ChallengeSessionConfig) -> Void

    @State private var bookName: String
    @State private var chapterName: String
    @State private var chapterCount: Int
    @State private var difficulty: ChallengeDifficulty?
    @State private var showBookPicker = false
    @State private var showChapterPicker = false

    private let themeColor = Color(UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor)

    init(
        prefillBook: String,
        prefillChapter: String,
        onBack: @escaping () -> Void,
        onStart: @escaping (ChallengeSessionConfig) -> Void
    ) {
        self.prefillBook = prefillBook
        self.prefillChapter = prefillChapter
        self.onBack = onBack
        self.onStart = onStart

        let book = prefillBook.isEmpty ? (UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) : prefillBook
        let chapter = prefillChapter.isEmpty ? (UserDefaults.standard.string(forKey: "BookChapter") ?? "1") : prefillChapter
        let count = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: book)

        _bookName = State(initialValue: book)
        _chapterName = State(initialValue: chapter)
        _chapterCount = State(initialValue: count)
    }

    private var canStart: Bool {
        difficulty != nil && !bookName.isEmpty && Int(chapterName) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(
                title: "Bible Quiz",
                showBackButton: true,
                onBack: onBack
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose your book, chapter, and difficulty to start the challenge hub.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.black.opacity(0.55))
                        .padding(.top, 4)

                    pickerCard(title: "Book", value: bookName) {
                        showBookPicker = true
                    }

                    pickerCard(title: "Chapter", value: chapterName) {
                        guard !bookName.isEmpty else { return }
                        showChapterPicker = true
                    }

                    Text("Difficulty")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "0B1B3A"))

                    HStack(spacing: 10) {
                        ForEach(ChallengeDifficulty.allCases) { level in
                            difficultyButton(level)
                        }
                    }

                    if let difficulty {
                        Text(difficulty.blankHint)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Challenge counts")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0B1B3A"))
                        Text("Fill in the blank · 10  |  Quiz · 10  |  True or False · 10  |  Verse Match · 5  |  Word Search · 5")
                            .font(.system(size: 13))
                            .foregroundColor(Color.black.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)

                    Button(action: startTapped) {
                        Text("Start Challenge Hub")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(canStart ? themeColor : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!canStart)
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
        .sheet(isPresented: $showBookPicker) {
            ChallengeQuizPickerSheet(title: "Select Book", onClose: { showBookPicker = false }) {
                ChallengeBookListPicker { selection in
                    bookName = selection.bookName
                    chapterCount = selection.chapterCount
                    chapterName = "Chapter"
                    difficulty = nil
                    showBookPicker = false
                }
            }
        }
        .sheet(isPresented: $showChapterPicker) {
            ChallengeQuizPickerSheet(title: "Select Chapter", onClose: { showChapterPicker = false }) {
                ChallengeChapterListPicker(chapterCount: chapterCount) { chapter in
                    chapterName = chapter
                    showChapterPicker = false
                }
            }
        }
    }

    private func pickerCard(title: String, value: String, action: @escaping () -> Void) -> some View {
        ChallengeHubPickerCard(title: title, value: value, action: action)
    }

    private func difficultyButton(_ level: ChallengeDifficulty) -> some View {
        let selected = difficulty == level
        return Button(action: { difficulty = level }) {
            Text(level.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(selected ? .white : Color(hex: "0B1B3A"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selected ? themeColor : Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.08), lineWidth: selected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func startTapped() {
        guard let difficulty, let chapter = Int(chapterName) else { return }
        UserDefaults.standard.setValue(difficulty.rawValue.capitalized, forKey: "Qlevel")
        UserDefaults.standard.setValue(bookName, forKey: "Qbook")
        UserDefaults.standard.setValue(chapter, forKey: "Qchapter")
        UserDefaults.standard.setValue(bookName, forKey: "LastSelectedBook")
        UserDefaults.standard.setValue("\(chapter)", forKey: "LastSelectedChapter")
        onStart(ChallengeSessionConfig.markAsRead(book: bookName, chapter: chapter, difficulty: difficulty))
    }
}
