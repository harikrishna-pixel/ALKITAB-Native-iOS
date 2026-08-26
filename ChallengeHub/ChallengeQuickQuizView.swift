//
//  ChallengeQuickQuizView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeQuickQuizView: View {
    let verse: ChallengeVerseContext
    var onClose: () -> Void
    var onOpenLegacyQuiz: () -> Void

    @State private var questions: [QuickQuizQuestion] = []
    @State private var index = 0
    @State private var selected: Int?
    @State private var score = 0
    @State private var finished = false

    var body: some View {
        VStack(spacing: 0) {
            header("Quick Quiz")

            if finished {
                resultBlock
            } else if questions.indices.contains(index) {
                let q = questions[index]
                Text("Question \(index + 1) of \(questions.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.08))
                        Capsule()
                            .fill(Color(hex: "1C46B2"))
                            .frame(width: geo.size.width * CGFloat(index + 1) / CGFloat(max(questions.count, 1)))
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(q.prompt)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "0B1B3A"))

                        ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                            optionRow(option, index: i, correct: q.correctIndex)
                        }
                    }
                    .padding(20)
                }

                Button(action: next) {
                    Text(index + 1 >= questions.count ? "Finish" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(selected == nil ? Color.gray.opacity(0.4) : Color(hex: "1C46B2"))
                        .cornerRadius(27)
                }
                .disabled(selected == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                Button("Open classic Bible Quiz") {
                    onOpenLegacyQuiz()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "1C46B2"))
                .padding(.bottom, 18)
            } else {
                Spacer()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            questions = ChallengeGameFactory.quickQuiz(from: verse)
        }
    }

    private var resultBlock: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Great job! 🎉")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "0B1B3A"))
            Text("You scored \(score) / \(questions.count)")
                .font(.system(size: 16))
                .foregroundColor(Color.black.opacity(0.55))
            Button(action: onClose) {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(27)
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }

    private func optionRow(_ option: String, index i: Int, correct: Int) -> some View {
        let isSelected = selected == i
        let showCorrect = selected != nil && i == correct
        let showWrong = selected != nil && isSelected && i != correct
        return Button(action: { if selected == nil { selected = i } }) {
            HStack(spacing: 12) {
                Image(systemName: showCorrect ? "checkmark.circle.fill" : (showWrong ? "xmark.circle.fill" : "circle"))
                    .foregroundColor(showCorrect ? Color(hex: "34C759") : (showWrong ? Color(hex: "D70015") : Color.black.opacity(0.25)))
                Text(option)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "0B1B3A"))
                    .multilineTextAlignment(.leading)
                Spacer()
                if showCorrect {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(hex: "34C759"))
                } else if showWrong {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "D70015"))
                }
            }
            .padding(14)
            .background(showCorrect ? Color(hex: "E8F8EE") : (showWrong ? Color(hex: "FDECEC") : Color.white))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(showCorrect ? Color(hex: "34C759") : (showWrong ? Color(hex: "D70015") : Color.black.opacity(0.1)), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(selected != nil)
    }

    private func next() {
        guard let selected = selected else { return }
        if selected == questions[index].correctIndex {
            score += 1
        }
        if index + 1 >= questions.count {
            finished = true
        } else {
            index += 1
            self.selected = nil
        }
    }

    private func header(_ title: String) -> some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B3A"))
            }
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "0B1B3A"))
            Spacer()
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
