//
//  Onboarding3.swift
//  NKJV Bible
//

import SwiftUI

struct Onboarding3: View {
    @State private var filled: [Int: String] = [:]
    @State private var selectedBlank: Int?
    @State private var feedback: String?

    private let tokens = OnboardingBibleVerse.tokens
    private let blankIndices = OnboardingBibleVerse.blankIndices
    private let options = OnboardingBibleVerse.options

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(OnboardingTheme.primaryBlue.opacity(0.1))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 30))
                                    .foregroundColor(OnboardingTheme.primaryBlue)
                            }
                            .padding(.top, 16)

                            VStack(spacing: 6) {
                                Text("Remember What You Read")
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 28)

                                Text("Simple fill-in-the-blank challenges help Scripture stay with you.")
                                    .font(.system(size: 15))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(OnboardingTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 36)
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                OnboardingVerseFlowView(
                                    tokens: tokens,
                                    blankIndices: blankIndices,
                                    filled: filled,
                                    selectedBlank: selectedBlank,
                                    onSelectBlank: { index in
                                        selectedBlank = index
                                        feedback = nil
                                    }
                                )

                                Text(OnboardingBibleVerse.reference)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(OnboardingTheme.textSecondary)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(Array(options.enumerated()), id: \.offset) { _, word in
                                        optionChip(word)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                            .padding(.horizontal, 24)

                            if let feedback = feedback {
                                Text(feedback)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(OnboardingTheme.primaryBlue)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 12)
                            }
                        }
                    }

                    OnboardingPrimaryLink(title: "Try It Now", destination: OnboardingNotificationView())
                        .padding(.horizontal, 24)

                    OnboardingPageDots(current: 2, total: 5)
                        .padding(.top, 14)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if selectedBlank == nil {
                selectedBlank = blankIndices.first
            }
        }
    }

    private func optionChip(_ word: String) -> some View {
        let used = filled.values.contains(where: { $0.caseInsensitiveCompare(word) == .orderedSame })
        return Button(action: { pick(word) }) {
            Text(word)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(used ? Color.white.opacity(0.7) : OnboardingTheme.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(used ? OnboardingTheme.primaryBlue.opacity(0.45) : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(OnboardingTheme.primaryBlue.opacity(used ? 0 : 0.35), lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(used)
    }

    private func pick(_ word: String) {
        let target = selectedBlank ?? blankIndices.first(where: { filled[$0] == nil })
        guard let target else { return }
        filled[target] = word
        selectedBlank = blankIndices.first(where: { filled[$0] == nil })
        if blankIndices.allSatisfy({ filled[$0] != nil }) {
            let ok = blankIndices.allSatisfy { idx in
                let a = (filled[idx] ?? "").trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                let b = tokens[idx].trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                return a.caseInsensitiveCompare(b) == .orderedSame
            }
            feedback = ok
                ? "Great! 🥳 Keep going and remember His Word today."
                : "Not quite — try different words, or continue."
        } else {
            feedback = nil
        }
    }
}

/// Flows words like a real verse (not a rigid grid).
private struct OnboardingVerseFlowView: View {
    let tokens: [String]
    let blankIndices: [Int]
    let filled: [Int: String]
    let selectedBlank: Int?
    let onSelectBlank: (Int) -> Void

    var body: some View {
        OnboardingWrappingLayout(spacing: 6, lineSpacing: 8) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                if blankIndices.contains(index) {
                    Button(action: { onSelectBlank(index) }) {
                        Text(filled[index] ?? "______")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(filled[index] == nil ? Color.black.opacity(0.35) : OnboardingTheme.primaryBlue)
                            .underline(color: selectedBlank == index ? OnboardingTheme.primaryBlue : Color.black.opacity(0.2))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text(token)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
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
            // Fallback: still readable as wrapped text-ish HStacks via LazyVGrid of flexible items
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
