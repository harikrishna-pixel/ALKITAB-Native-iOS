//
//  ChallengeTrueFalseView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeTrueFalseView: View {
    let verse: ChallengeVerseContext
    var onClose: () -> Void

    @State private var questions: [TrueFalseQuestion] = []
    @State private var index = 0
    @State private var selected: Bool?
    @State private var score = 0
    @State private var finished = false

    var body: some View {
        VStack(spacing: 0) {
            header("True or False")

            if finished {
                VStack(spacing: 16) {
                    Spacer()
                    Text("Great job! 🎉")
                        .font(.system(size: 24, weight: .bold))
                    Text("You scored \(score) / \(questions.count)")
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
            } else if questions.indices.contains(index) {
                let q = questions[index]
                Text("Question \(index + 1) of \(questions.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                Spacer()

                Text(q.statement)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "0B1B3A"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                VStack(spacing: 12) {
                    tfButton(title: "True", value: true, correct: q.isTrue)
                    tfButton(title: "False", value: false, correct: !q.isTrue)
                }
                .padding(20)

                Spacer()

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
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            questions = ChallengeGameFactory.trueFalse(from: verse)
        }
    }

    private func tfButton(title: String, value: Bool, correct: Bool) -> some View {
        let isSelected = selected == value
        let showCorrect = selected != nil && correct
        let showWrong = selected != nil && isSelected && !correct
        return Button(action: { if selected == nil { selected = value } }) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0B1B3A"))
                Spacer()
                if showCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "34C759"))
                }
            }
            .padding(18)
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
        if selected == questions[index].isTrue {
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
