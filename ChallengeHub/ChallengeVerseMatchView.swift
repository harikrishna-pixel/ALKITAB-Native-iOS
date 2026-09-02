//
//  ChallengeVerseMatchView.swift
//  NKJV Bible
//

import SwiftUI

struct ChallengeVerseMatchView: View {
    let verse: ChallengeVerseContext
    var sessionConfig: ChallengeSessionConfig? = nil
    var onClose: () -> Void

    @State private var pairs: [VerseMatchPair] = []
    @State private var leftOrder: [UUID] = []
    @State private var rightOrder: [UUID] = []
    @State private var matches: [UUID: UUID] = [:] // leftId -> rightId
    @State private var anchors: [String: CGRect] = [:]
    @State private var dragStartLeft: UUID?
    @State private var dragPoint: CGPoint?
    @State private var feedback: String?
    @State private var solved = false
    @State private var lives = 3
    @State private var usedHint = false
    @State private var walletTick = 0
    @State private var toast: String?

    private let colors: [Color] = [Color(hex: "1C46B2"), Color(hex: "34C759"), Color(hex: "F5A623")]

    private var boardHeight: CGFloat {
        let rows = CGFloat(max(pairs.count, 1))
        let rowHeight: CGFloat = 72
        let rowSpacing: CGFloat = 12
        return rows * rowHeight + max(0, rows - 1) * rowSpacing
    }

    var body: some View {
        ChallengeOldStyleShell(
            screenTitle: ChallengeKind.verseMatch.title,
            onBack: onClose,
            lives: lives,
            questionNumber: 1,
            questionTotal: 1,
            caption: "Match the verses / people / events.",
            primaryTitle: solved ? "Done" : "Check Answer",
            primaryEnabled: true,
            onPrimary: check,
            fiftyFiftyEnabled: false,
            hintEnabled: !usedHint && !solved,
            skipEnabled: !solved,
            onLifeline: handleLifeline,
            walletTick: walletTick,
            contentScrollDisabled: true
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ChallengeQuizContentHeader(
                    reference: verse.reference,
                    instruction: "Match the verse with the correct reference."
                )

                ZStack(alignment: .top) {
                    HStack(alignment: .top, spacing: 18) {
                        VStack(spacing: 12) {
                            ForEach(leftOrder, id: \.self) { id in
                                if let pair = pairs.first(where: { $0.id == id }) {
                                    leftCard(pair)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 12) {
                            ForEach(rightOrder, id: \.self) { id in
                                if let pair = pairs.first(where: { $0.id == id }) {
                                    rightCard(pair)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    MatchLinesOverlay(
                        matches: matches,
                        anchors: anchors,
                        dragStartLeft: dragStartLeft,
                        dragPoint: dragPoint,
                        pairs: pairs,
                        colors: colors
                    )
                    .allowsHitTesting(false)
                }
                .coordinateSpace(name: "matchBoard")
                .onPreferenceChange(MatchAnchorKey.self) { anchors = $0 }
                .frame(maxWidth: .infinity)
                .frame(height: boardHeight, alignment: .top)

                if let feedback = feedback {
                    Text(feedback)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(solved ? Color(hex: "1B7A3D") : Color(hex: "D70015"))
                }
                if let toast = toast {
                    Text(toast)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "D70015"))
                }
            }
        }
        .onAppear {
            pairs = ChallengeGameFactory.matchPairs(from: verse, config: sessionConfig)
            leftOrder = pairs.map { $0.id }.shuffled()
            rightOrder = pairs.map { $0.id }.shuffled()
        }
    }

    private func leftCard(_ pair: VerseMatchPair) -> some View {
        let color = connectedColor(leftId: pair.id)
        return HStack(spacing: 8) {
            Text(pair.verse)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "0B1B3A"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(color ?? Color.black.opacity(0.18))
                .frame(width: 14, height: 14)
                .overlay(
                    GeometryReader { g in
                        Color.clear.preference(
                            key: MatchAnchorKey.self,
                            value: ["L-\(pair.id.uuidString)": g.frame(in: .named("matchBoard"))]
                        )
                    }
                )
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color ?? Color.black.opacity(0.1), lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .gesture(drawGesture(fromLeft: pair.id))
    }

    private func rightCard(_ pair: VerseMatchPair) -> some View {
        let color = connectedColor(rightId: pair.id)
        return HStack(spacing: 8) {
            Circle()
                .fill(color ?? Color.black.opacity(0.18))
                .frame(width: 14, height: 14)
                .overlay(
                    GeometryReader { g in
                        Color.clear.preference(
                            key: MatchAnchorKey.self,
                            value: ["R-\(pair.id.uuidString)": g.frame(in: .named("matchBoard"))]
                        )
                    }
                )

            Text(pair.reference)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "0B1B3A"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color ?? Color.black.opacity(0.08), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard !solved else { return }
            // Tap reference to clear any line attached to it
            if let left = matches.first(where: { $0.value == pair.id })?.key {
                var next = matches
                next.removeValue(forKey: left)
                matches = next
                feedback = nil
            }
        }
    }

    private func drawGesture(fromLeft leftId: UUID) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .named("matchBoard"))
            .onChanged { value in
                guard !solved else { return }
                feedback = nil
                if dragStartLeft != leftId {
                    // Starting a new draw: detach previous line from this verse
                    var next = matches
                    next.removeValue(forKey: leftId)
                    matches = next
                }
                dragStartLeft = leftId
                dragPoint = value.location
            }
            .onEnded { value in
                guard !solved else { return }
                defer {
                    dragStartLeft = nil
                    dragPoint = nil
                }
                if let rightId = nearestRight(at: value.location) {
                    var next = matches.filter { $0.key != leftId && $0.value != rightId }
                    next[leftId] = rightId
                    matches = next
                    feedback = nil
                }
                // If released away from any reference, match stays cleared (removed on drag start)
            }
    }

    private func nearestRight(at point: CGPoint) -> UUID? {
        var best: (UUID, CGFloat)?
        for pair in pairs {
            let key = "R-\(pair.id.uuidString)"
            guard let rect = anchors[key] else { continue }
            // Prefer whole right card hit area if available; fall back to expanded dot
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let dist = hypot(center.x - point.x, center.y - point.y)
            if dist <= 72 {
                if best == nil || dist < best!.1 {
                    best = (pair.id, dist)
                }
            }
        }
        // Also accept release over the right-hand column by Y alignment
        if best == nil {
            for pair in pairs {
                let key = "R-\(pair.id.uuidString)"
                guard let rect = anchors[key] else { continue }
                let expanded = CGRect(x: rect.minX - 40, y: rect.minY - 28, width: rect.width + 120, height: rect.height + 56)
                if expanded.contains(point) {
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    let dist = hypot(center.x - point.x, center.y - point.y)
                    if best == nil || dist < best!.1 {
                        best = (pair.id, dist)
                    }
                }
            }
        }
        return best?.0
    }

    private func connectedColor(leftId: UUID) -> Color? {
        guard matches[leftId] != nil else { return nil }
        return lineColor(forLeft: leftId)
    }

    private func connectedColor(rightId: UUID) -> Color? {
        guard let left = matches.first(where: { $0.value == rightId })?.key else { return nil }
        return lineColor(forLeft: left)
    }

    private func lineColor(forLeft leftId: UUID) -> Color {
        let idx = pairs.firstIndex(where: { $0.id == leftId }) ?? 0
        return colors[idx % colors.count]
    }

    private func check() {
        if solved {
            onClose()
            return
        }
        guard matches.count == pairs.count else {
            feedback = "Draw lines to match all verses."
            return
        }
        let ok = matches.allSatisfy { $0.key == $0.value }
        solved = ok
        feedback = ok ? "Perfect match!" : "Some matches are incorrect — try again."
        if !ok {
            lives = max(0, lives - 1)
        }
    }

    private func handleLifeline(_ kind: ChallengeLifelineKind) {
        switch kind {
        case .fiftyFifty:
            toast = "50/50 is not available for Verse Match."
        case .hint:
            guard ChallengeWallet.spend(ChallengeWallet.hintCost) else {
                toast = "Not enough coins for Hint."
                return
            }
            walletTick += 1
            usedHint = true
            if let pair = pairs.first(where: { matches[$0.id] != $0.id }) {
                var next = matches.filter { $0.key != pair.id && $0.value != pair.id }
                next[pair.id] = pair.id
                matches = next
            }
            toast = nil
        case .skip:
            guard ChallengeWallet.spend(ChallengeWallet.skipCost) else {
                toast = "Not enough coins for Skip."
                return
            }
            walletTick += 1
            onClose()
        }
    }
}

private struct MatchLinesOverlay: View {
    let matches: [UUID: UUID]
    let anchors: [String: CGRect]
    let dragStartLeft: UUID?
    let dragPoint: CGPoint?
    let pairs: [VerseMatchPair]
    let colors: [Color]

    var body: some View {
        ZStack {
            ForEach(Array(matches.keys), id: \.self) { leftId in
                // Hide committed line while this left is being redrawn
                if leftId != dragStartLeft,
                   let rightId = matches[leftId],
                   let a = anchors["L-\(leftId.uuidString)"],
                   let b = anchors["R-\(rightId.uuidString)"] {
                    Path { path in
                        path.move(to: CGPoint(x: a.midX, y: a.midY))
                        path.addLine(to: CGPoint(x: b.midX, y: b.midY))
                    }
                    .stroke(color(for: leftId), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }

            if let leftId = dragStartLeft,
               let start = anchors["L-\(leftId.uuidString)"],
               let end = dragPoint {
                Path { path in
                    path.move(to: CGPoint(x: start.midX, y: start.midY))
                    path.addLine(to: end)
                }
                .stroke(Color(hex: "1C46B2").opacity(0.7), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
        }
    }

    private func color(for leftId: UUID) -> Color {
        let idx = pairs.firstIndex(where: { $0.id == leftId }) ?? 0
        return colors[idx % colors.count]
    }
}

private struct MatchAnchorKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
