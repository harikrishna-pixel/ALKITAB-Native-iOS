//
//  ReflectionView.swift
//  NKJV Bible
//

import SwiftUI

struct ReflectionView: View {
    let verse: DailyVerseSnapshot
    @ObservedObject var store: DailyJourneyStore
    var onDone: () -> Void

    @State private var selectedOption: Int?
    @State private var text: String = ""
    @State private var isReviewMode = false

    private let options: [(icon: String, title: String)] = [
        ("heart.fill", "I feel encouraged"),
        ("bookmark.fill", "I want to remember this"),
        ("arrow.triangle.2.circlepath", "I need to trust God more"),
        ("person.2.fill", "I want to share this with someone")
    ]

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(isReviewMode ? "Your Reflection" : "My Reflection")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Text(verse.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1C46B2"))

                    Text(isReviewMode
                          ? "Here’s what you saved today. Resets tomorrow."
                          : "What spoke to you? What will you take from today's verse?")
                        .font(.system(size: 15))
                        .foregroundColor(Color.black.opacity(0.55))

                    VStack(spacing: 10) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                if !isReviewMode {
                                    selectedOption = index
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: option.icon)
                                        .foregroundColor(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.35))
                                        .frame(width: 24)
                                    Text(option.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: selectedOption == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.2))
                                }
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedOption == index ? Color(hex: "1C46B2") : Color.black.opacity(0.08), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isReviewMode)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(isReviewMode ? "Your thoughts" : "Write your thoughts...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.45))

                        ZStack(alignment: .topLeading) {
                            if text.isEmpty && !isReviewMode {
                                Text("A short note to yourself...")
                                    .foregroundColor(Color.black.opacity(0.3))
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            TextEditor(text: $text)
                                .frame(minHeight: 120)
                                .padding(8)
                                .disabled(isReviewMode)
                                .opacity(isReviewMode ? 0.95 : 1)
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )

                        if !isReviewMode {
                            Text("\(min(text.count, 300))/300")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black.opacity(0.35))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    if isReviewMode {
                        Text("Completed for today")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1B7A3D"))
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                Button(action: {
                    if isReviewMode {
                        onDone()
                    } else {
                        save()
                    }
                }) {
                    Text(isReviewMode ? "Done" : "Save Reflection")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1C46B2"))
                        .cornerRadius(27)
                }

                if !isReviewMode {
                    Button(action: skip) {
                        Text("Skip for Today")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "1C46B2"))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if store.reflectionCompleted {
                isReviewMode = true
                text = String(store.reflectionText.prefix(300))
                selectedOption = store.reflectionOptionIndex
                if selectedOption == nil {
                    selectedOption = options.firstIndex(where: { store.reflectionText.contains($0.title) })
                }
            } else {
                isReviewMode = false
                text = String(store.reflectionText.prefix(300))
                selectedOption = store.reflectionOptionIndex
            }
        }
        .onChange(of: text) { newValue in
            guard !isReviewMode else { return }
            if newValue.count > 300 {
                text = String(newValue.prefix(300))
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.08))
                Capsule()
                    .fill(Color(hex: "1C46B2"))
                    .frame(width: geo.size.width * (isReviewMode ? 1.0 : 0.75))
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func save() {
        var combined = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let selectedOption = selectedOption {
            let label = options[selectedOption].title
            if combined.isEmpty {
                combined = label
            } else if !combined.contains(label) {
                combined = "\(label). \(combined)"
            }
        }
        store.markReflectionCompleted(text: combined, optionIndex: selectedOption)
        store.markVerseCompleted()
        onDone()
    }

    private func skip() {
        store.markReflectionCompleted(text: store.reflectionText, optionIndex: selectedOption)
        store.markVerseCompleted()
        onDone()
    }
}
