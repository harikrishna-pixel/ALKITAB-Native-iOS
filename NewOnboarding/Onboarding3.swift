//
//  Onboarding3.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding3: View {
    @State private var filled: [Int: String] = [:]
    @State private var selectedBlank: Int?
    @State private var feedback: String?
    @State private var navigateForward = false

    private let tokens = OnboardingBibleVerse.tokens
    private let blankIndices = OnboardingBibleVerse.blankIndices
    private let options = OnboardingBibleVerse.options

    private var allFilled: Bool {
        blankIndices.allSatisfy { filled[$0] != nil }
    }

    private var isAnswerCorrect: Bool {
        blankIndices.allSatisfy { idx in
            stripPunctuation(filled[idx] ?? "").caseInsensitiveCompare(stripPunctuation(tokens[idx])) == .orderedSame
        }
    }

    private var showingWrongState: Bool {
        allFilled && !isAnswerCorrect && feedback != nil
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingTheme.paper.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            OnboardingTopBar(onLight: true)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)

                            HStack {
                                Text("FILL THE VERSE")
                                                                                                                                                                                                                                        .font(.system(size: 11, weight: .heavy))
                                    .tracking(1)
                                    .foregroundColor(Color(hex: "7488A6"))
                                Spacer()
                                Text("Question 1 of 1")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(Color(hex: "8595AE"))
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 4)

                            GeometryReader { barGeo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(OnboardingTheme.paperLine)
                                        .frame(height: 4)
                                    Capsule()
                                        .fill(OnboardingTheme.primaryBlue)
                                        .frame(width: allFilled ? barGeo.size.width : barGeo.size.width * 0.35, height: 4)
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 26)
                            .padding(.top, 8)
                            .padding(.bottom, 18)

                            OnboardingSerifTitle(
                                lines: ["Remember", "What You Read"],
                                size: min(geometry.size.width * 0.08, 31),
                                alignment: .leading,
                                onDark: false
                            )
                            .padding(.horizontal, 26)
                            .padding(.bottom, 16)

                            verseBox
                                .padding(.horizontal, 26)

                            optionsRow
                                .padding(.horizontal, 26)
                                .padding(.top, 16)

                            HStack {
                                Spacer()
                                Button(action: revealHint) {
                                    Text("Need a hint?")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(OnboardingTheme.primaryBlue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(allFilled && isAnswerCorrect)
                                .opacity(allFilled && isAnswerCorrect ? 0.35 : 1)
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 10)

                            if let feedback = feedback {
                                let isWrong = feedback.hasPrefix("Not quite")
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: isWrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(isWrong ? Color(hex: "D70015") : OnboardingTheme.grow)
                                    Text(feedback)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(isWrong ? Color(hex: "D70015") : OnboardingTheme.grow)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(15)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isWrong ? Color(hex: "FDECEC") : OnboardingTheme.growBg)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isWrong ? Color(hex: "F5C2C7") : OnboardingTheme.growLine, lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 26)
                                .padding(.top, 14)
                            }

                            if showingWrongState {
                                Button(action: clearAnswers) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text("Clear & Try Again")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "D70015"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "FDECEC"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(hex: "F5C2C7"), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 26)
                                .padding(.top, 10)
                            }

                            if allFilled && isAnswerCorrect {
                                challengeTypesPreview
                                    .padding(.horizontal, 26)
                                    .padding(.top, 20)
                                    .transition(.opacity)
                            }

                            Spacer(minLength: 20)
                        }
                    }

                    Group {
                        if allFilled {
                            OnboardingPrimaryButton(title: "Continue") {
                                navigateForward = true
                            }
                        } else {
                            OnboardingPrimaryButton(title: "Tap an answer to continue", isEnabled: false, onDark: false) {}
                        }
                    }
                    .padding(.horizontal, 26)
                    .background(
                        NavigationLink(
                            destination: OnboardingNotificationView(),
                            isActive: $navigateForward
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    )

                    OnboardingPageDots(current: 2, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 34))
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeOut(duration: 0.35), value: allFilled)
        .onAppear {
            if selectedBlank == nil {
                selectedBlank = blankIndices.first
            }
        }
    }

    private var verseBox: some View {
        VStack(alignment: .leading, spacing: 11) {
            OnboardingVerseFlowView(
                tokens: tokens,
                blankIndices: blankIndices,
                filled: filled,
                selectedBlank: selectedBlank,
                showWrongValidation: showingWrongState,
                isWrongBlank: isWrongBlank,
                onSelectBlank: { index in
                    if selectedBlank == index, filled[index] != nil {
                        filled[index] = nil
                        feedback = nil
                    } else {
                        selectedBlank = index
                        if !allFilled {
                            feedback = nil
                        }
                    }
                }
            )

            Text("\(OnboardingBibleVerse.reference) · \(APPNAME)")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8595AE"))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(OnboardingTheme.paperLine, lineWidth: 1)
                )
        )
    }

    private var optionsRow: some View {
        HStack(spacing: 9) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, word in
                optionChip(word)
            }
        }
    }

    private var challengeTypesPreview: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("MORE WAYS TO REMEMBER")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.3)
                .foregroundColor(Color(hex: "7488A6"))

            HStack(spacing: 6) {
                ForEach(ChallengeKind.allCases) { kind in
                    challengeTypeThumb(kind: kind)
                }
            }
        }
    }

    private func onboardingChallengeLabel(for kind: ChallengeKind) -> String {
        switch kind {
        case .quickQuiz: return "Quick\nQuiz"
        case .fillVerse: return "Fill the\nVerse"
        case .verseMatch: return "Verse\nMatch"
        case .trueFalse: return "True /\nFalse"
        case .wordSearch: return "Word\nSearch"
        }
    }

    private func challengeTypeThumb(kind: ChallengeKind) -> some View {
        let isFree = !kind.isPremium
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(hex: kind.iconBgHex))
                    .frame(height: 34)
                Image(systemName: kind.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: kind.iconTintHex))
            }
            Text(onboardingChallengeLabel(for: kind))
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isFree ? Color(hex: "1F4C9E") : Color(hex: "5A6D8C"))
                .multilineTextAlignment(.center)
                .lineSpacing(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isFree ? Color(hex: "F4F9FF") : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFree ? Color(hex: "B9D4F5") : OnboardingTheme.paperLine, lineWidth: 1)
                )
        )
    }

    private func optionChip(_ word: String) -> some View {
        let usedElsewhere = filled.contains { index, value in
            index != selectedBlank && value.caseInsensitiveCompare(word) == .orderedSame
        }
        return Button(action: { pick(word) }) {
            Text(word)
                .font(.system(size: 14.5, weight: .bold))
                .foregroundColor(usedElsewhere ? Color(hex: "31456A").opacity(0.42) : Color(hex: "31456A"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(OnboardingTheme.paperLine, lineWidth: 1.5)
                )
                .cornerRadius(13)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(usedElsewhere)
        .opacity(usedElsewhere ? 0.42 : 1)
    }

    private func pick(_ word: String) {
        let target = selectedBlank ?? blankIndices.first(where: { filled[$0] == nil })
        guard let target else { return }
        filled[target] = word
        selectedBlank = blankIndices.first(where: { filled[$0] == nil })
        if blankIndices.allSatisfy({ filled[$0] != nil }) {
            feedback = isAnswerCorrect
                ? "Great! Keep going and remember His Word today."
                : "Not quite — try different words, or continue."
        } else {
            feedback = nil
        }
    }

    private func clearAnswers() {
        filled = [:]
        selectedBlank = blankIndices.first
        feedback = nil
    }

    /// Same idea as Memory Challenge hint — fills one blank with the correct word.
    private func revealHint() {
        guard let idx = blankIndices.first(where: { filled[$0] == nil }) ?? blankIndices.first else { return }
        let answer = stripPunctuation(tokens[idx])
        let word = options.first {
            stripPunctuation($0).caseInsensitiveCompare(answer) == .orderedSame
        } ?? answer
        filled[idx] = word
        selectedBlank = blankIndices.first(where: { filled[$0] == nil })
        if blankIndices.allSatisfy({ filled[$0] != nil }) {
            feedback = isAnswerCorrect
                ? "Great! Keep going and remember His Word today."
                : "Not quite — try different words, or continue."
        } else {
            feedback = nil
        }
    }

    private func isWrongBlank(_ index: Int) -> Bool {
        guard showingWrongState, filled[index] != nil else { return false }
        return stripPunctuation(filled[index] ?? "").caseInsensitiveCompare(stripPunctuation(tokens[index])) != .orderedSame
    }

    private func stripPunctuation(_ value: String) -> String {
        value.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
}

/// Flows words like a real verse (not a rigid grid).
struct OnboardingVerseFlowView: View {
    let tokens: [String]
    let blankIndices: [Int]
    let filled: [Int: String]
    let selectedBlank: Int?
    var showWrongValidation: Bool = false
    var isWrongBlank: (Int) -> Bool = { _ in false }
    let onSelectBlank: (Int) -> Void

    var body: some View {
        OnboardingWrappingLayout(spacing: 6, lineSpacing: 8) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                if blankIndices.contains(index) {
                    let wrong = showWrongValidation && isWrongBlank(index)
                    Button(action: { onSelectBlank(index) }) {
                        Text(filled[index] ?? "______")
                            .font(.system(size: filled[index] == nil ? 19 : 17, weight: filled[index] == nil ? .regular : .semibold, design: filled[index] == nil ? .serif : .default))
                            .foregroundColor(
                                filled[index] == nil
                                    ? Color.black.opacity(0.35)
                                    : (wrong ? Color(hex: "D70015") : OnboardingTheme.grow)
                            )
                            .underline(
                                filled[index] == nil,
                                color: selectedBlank == index ? OnboardingTheme.primaryBlue : OnboardingTheme.primaryBlue.opacity(0.6)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text(token)
                        .font(.system(size: 19, weight: .regular, design: .serif))
                        .foregroundColor(OnboardingTheme.paperInk)
                }
            }
        }
    }
}

/// Simple left-to-right wrapping layout for verse words.
private struct OnboardingWrappingLayout<Content: View>: View {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 8
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 16.0, *) {
            OnboardingFlowLayout(spacing: spacing, lineSpacing: lineSpacing) {
                content()
            }
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 28), spacing: spacing, alignment: .leading)], alignment: .leading, spacing: lineSpacing) {
                content()
            }
        }
    }
}

@available(iOS 16.0, *)
private struct OnboardingFlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            maxX = max(maxX, x + size.width)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : maxX, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

#Preview {
    Onboarding3()
}
