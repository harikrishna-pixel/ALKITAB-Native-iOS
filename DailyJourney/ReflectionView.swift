//
//  ReflectionView.swift
//  NKJV Bible
//

import SwiftUI
import IQKeyboardManager

struct ReflectionView: View {
    let verse: DailyVerseSnapshot
    @ObservedObject var store: DailyJourneyStore
    var onDone: () -> Void

    @State private var selectedOption: Int?
    @State private var text: String = ""
    /// Lifts the form with the keyboard instead of letting the layout snap.
    @State private var keyboardLift: CGFloat = 0
    /// True when reflection was already completed before this visit (edit / review day).
    @State private var wasAlreadyCompleted = false

    private let options: [(icon: String, title: String)] = [
        ("heart.fill", "I feel encouraged"),
        ("bookmark.fill", "I want to remember this"),
        ("arrow.triangle.2.circlepath", "I need to trust God more"),
        ("person.2.fill", "I want to share this with someone")
    ]

    var body: some View {
        ScrollViewReader { proxy in
        VStack(spacing: 0) {
            progressBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(wasAlreadyCompleted ? "Your Reflection" : "My Reflection")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    Text(verse.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1C46B2"))

                    Text(wasAlreadyCompleted
                          ? "You can still add or change your reflection today."
                          : "What spoke to you? What will you take from today's verse?")
                        .font(.system(size: 15))
                        .foregroundColor(Color.black.opacity(0.55))

                    VStack(spacing: 10) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectedOption = index
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
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(wasAlreadyCompleted ? "Your thoughts" : "Write your thoughts...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.45))

                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("A short note to yourself...")
                                    .foregroundColor(Color.black.opacity(0.3))
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            TextEditor(text: $text)
                                .frame(minHeight: 120)
                                .padding(8)
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .id("reflectionNotes")

                        Text("\(min(text.count, 300))/300")
                            .font(.system(size: 12))
                            .foregroundColor(Color.black.opacity(0.35))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    if wasAlreadyCompleted {
                        Text("Completed for today")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1B7A3D"))
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                Button(action: save) {
                    Text(wasAlreadyCompleted ? "Done" : "Save Reflection")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1C46B2"))
                        .cornerRadius(27)
                }

                if !wasAlreadyCompleted {
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
        .padding(.bottom, keyboardLift)
        .background(Color(hex: "F7F8FC").ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            let lift = keyboardLift(from: notification)
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            withAnimation(.easeOut(duration: duration)) {
                keyboardLift = lift
                if lift > 0 {
                    proxy.scrollTo("reflectionNotes", anchor: .bottom)
                }
            }
        }
        .onAppear {
            IQKeyboardManager.shared().isEnabled = false
            wasAlreadyCompleted = store.reflectionCompleted
            text = String(store.reflectionText.prefix(300))
            selectedOption = store.reflectionOptionIndex
            if selectedOption == nil {
                selectedOption = options.firstIndex(where: { store.reflectionText.contains($0.title) })
            }
        }
        .onDisappear {
            keyboardLift = 0
            IQKeyboardManager.shared().isEnabled = true
        }
        .onChange(of: text) { newValue in
            if newValue.count > 300 {
                text = String(newValue.prefix(300))
            }
        }
        }
    }

    /// How far the form should rise so it meets the keyboard, without counting the home indicator twice.
    private func keyboardLift(from notification: Notification) -> CGFloat {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return 0 }
        let screenHeight = UIScreen.main.bounds.height
        let overlap = max(0, screenHeight - frame.origin.y)
        let homeInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        return max(0, overlap - homeInset)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.08))
                Capsule()
                    .fill(Color(hex: "1C46B2"))
                    .frame(width: geo.size.width * (wasAlreadyCompleted || store.reflectionCompleted ? 1.0 : 0.75))
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
        // Re-saving after completion only updates content; streak reward is already guarded for today.
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
