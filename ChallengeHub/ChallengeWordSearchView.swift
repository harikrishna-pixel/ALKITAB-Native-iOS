//
//  ChallengeWordSearchView.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct ChallengeWordSearchView: View {
    let verse: ChallengeVerseContext
    var onClose: () -> Void

    private let size = 7

    @State private var words: [String] = []
    @State private var grid: [[Character]] = []
    @State private var found: Set<String> = []
    @State private var foundPaths: [String: [GridPos]] = [:]
    @State private var wordColors: [String: Color] = [:]
    @State private var wordHex: [String: String] = [:]

    private let palette: [Color] = [
        Color(hex: "34C759"),
        Color(hex: "1C46B2"),
        Color(hex: "F5A623"),
        Color(hex: "7B61FF"),
        Color(hex: "E85D4C")
    ]
    private let paletteHex = ["34C759", "1C46B2", "F5A623", "7B61FF", "E85D4C"]

    var body: some View {
        VStack(spacing: 0) {
            header("Word Search")

            Text("Find the words below")
                .font(.system(size: 14))
                .foregroundColor(Color.black.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(words, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(found.contains(word) ? .white : Color(hex: "0B1B3A"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(found.contains(word) ? (wordColors[word] ?? Color(hex: "1C46B2")) : Color(hex: "EEF2F8"))
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 48)
            .padding(.vertical, 8)

            WordSearchBoardRepresentable(
                letters: grid,
                foundPaths: foundPaths,
                colors: foundUIColors,
                onFinishedPath: commitPath
            )
            .frame(maxWidth: .infinity)
            .frame(height: boardHeight)
            .padding(.horizontal, 16)

            if found.count == words.count && !words.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "34C759"))
                    Text("Great job! 🎉")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1B7A3D"))
                }
                .padding(.top, 16)
            }

            Spacer(minLength: 8)

            Button(action: onClose) {
                Text(found.count == words.count && !words.isEmpty ? "Done" : "Close")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "1C46B2"))
                    .cornerRadius(27)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear(perform: build)
        .modifier(WordSearchSheetLock())
    }

    private var boardHeight: CGFloat {
        // 7 rows × ~40pt + padding — keep the full A–Z grid on screen
        CGFloat(size) * 42 + 24
    }

    private var foundUIColors: [String: UIColor] {
        var map: [String: UIColor] = [:]
        for (word, hex) in wordHex {
            map[word] = UIColor(rgbHex: hex)
        }
        return map
    }

    private func build() {
        let all = ChallengeGameFactory.wordSearchWords(from: verse)
        words = all.filter { $0.count <= size }
        if words.isEmpty {
            words = ["FAITH", "GRACE", "LOVE", "PEACE", "HOPE"].filter { $0.count <= size }
        }
        var built: (grid: [[Character]], placements: [String: [GridPos]])
        var attempt = 0
        repeat {
            built = WordSearchBuilder.buildWithPaths(size: size, words: words)
            attempt += 1
        } while built.placements.count < words.count && attempt < 50

        words = words.filter { built.placements[$0] != nil }
        if words.isEmpty {
            words = ["FAITH", "GRACE", "LOVE", "PEACE", "HOPE"].filter { $0.count <= size }
            built = WordSearchBuilder.buildWithPaths(size: size, words: words)
            words = words.filter { built.placements[$0] != nil }
        }
        for (i, w) in words.enumerated() {
            wordColors[w] = palette[i % palette.count]
            wordHex[w] = paletteHex[i % paletteHex.count]
        }
        grid = built.grid
        found = []
        foundPaths = [:]
        WordSearchBuilder.lastPlacements = built.placements
    }

    private func commitPath(_ path: [GridPos]) {
        guard path.count >= 2 else { return }
        let forward = String(path.compactMap { pos -> Character? in
            guard grid.indices.contains(pos.r), grid[pos.r].indices.contains(pos.c) else { return nil }
            return grid[pos.r][pos.c]
        })
        let reverse = String(forward.reversed())
        if words.contains(forward), !found.contains(forward) {
            found.insert(forward)
            foundPaths[forward] = path
        } else if words.contains(reverse), !found.contains(reverse) {
            found.insert(reverse)
            foundPaths[reverse] = Array(path.reversed())
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

private struct WordSearchSheetLock: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.interactiveDismissDisabled(true)
        } else {
            content
        }
    }
}

// MARK: - UIKit board (finger draw)

private struct WordSearchBoardRepresentable: UIViewRepresentable {
    var letters: [[Character]]
    var foundPaths: [String: [GridPos]]
    var colors: [String: UIColor]
    var onFinishedPath: ([GridPos]) -> Void

    func makeUIView(context: Context) -> WordSearchBoardUIView {
        let view = WordSearchBoardUIView()
        view.onFinishedPath = onFinishedPath
        return view
    }

    func updateUIView(_ uiView: WordSearchBoardUIView, context: Context) {
        uiView.onFinishedPath = onFinishedPath
        uiView.apply(letters: letters, foundPaths: foundPaths, colors: colors)
    }
}

final class WordSearchBoardUIView: UIView {
    var onFinishedPath: (([GridPos]) -> Void)?

    private let gridCount = 7
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 3
    private var letters: [[Character]] = []
    private var foundPaths: [String: [GridPos]] = [:]
    private var colors: [String: UIColor] = [:]
    private var labels: [UILabel] = []
    private var selecting: [GridPos] = []
    private let foundShape = CAShapeLayer()
    private let selectShape = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 247/255, green: 248/255, blue: 252/255, alpha: 1)
        layer.cornerRadius = 14
        clipsToBounds = true
        isMultipleTouchEnabled = false
        isExclusiveTouch = true
        isUserInteractionEnabled = true

        foundShape.fillColor = nil
        foundShape.lineCap = .round
        foundShape.lineJoin = .round
        layer.addSublayer(foundShape)

        selectShape.fillColor = nil
        selectShape.strokeColor = UIColor(red: 28/255, green: 70/255, blue: 178/255, alpha: 0.4).cgColor
        selectShape.lineCap = .round
        selectShape.lineJoin = .round
        layer.addSublayer(selectShape)

        for _ in 0..<(gridCount * gridCount) {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.textColor = UIColor(red: 11/255, green: 27/255, blue: 58/255, alpha: 1)
            label.isUserInteractionEnabled = false
            addSubview(label)
            labels.append(label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(letters: [[Character]], foundPaths: [String: [GridPos]], colors: [String: UIColor]) {
        self.letters = letters
        self.foundPaths = foundPaths
        self.colors = colors
        refreshLetters()
        setNeedsLayout()
        layoutIfNeeded()
        redrawFound()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        foundShape.frame = bounds
        selectShape.frame = bounds
        let cell = cellSize()
        selectShape.lineWidth = cell * 0.78
        for r in 0..<gridCount {
            for c in 0..<gridCount {
                labels[r * gridCount + c].frame = cellFrame(r: r, c: c)
            }
        }
        refreshLetters()
        redrawFound()
        redrawSelecting()
    }

    private func refreshLetters() {
        for r in 0..<gridCount {
            for c in 0..<gridCount {
                let ch: String
                if letters.indices.contains(r), letters[r].indices.contains(c) {
                    ch = String(letters[r][c])
                } else {
                    ch = ""
                }
                labels[r * gridCount + c].text = ch
            }
        }
    }

    private func cellSize() -> CGFloat {
        let innerW = bounds.width - padding * 2 - spacing * CGFloat(gridCount - 1)
        let innerH = bounds.height - padding * 2 - spacing * CGFloat(gridCount - 1)
        return max(1, min(innerW, innerH) / CGFloat(gridCount))
    }

    private func cellFrame(r: Int, c: Int) -> CGRect {
        let s = cellSize()
        let total = CGFloat(gridCount) * s + CGFloat(gridCount - 1) * spacing
        let originX = (bounds.width - total) / 2
        let originY = (bounds.height - total) / 2
        return CGRect(
            x: originX + CGFloat(c) * (s + spacing),
            y: originY + CGFloat(r) * (s + spacing),
            width: s,
            height: s
        )
    }

    private func cell(at point: CGPoint) -> GridPos? {
        for r in 0..<gridCount {
            for c in 0..<gridCount {
                if cellFrame(r: r, c: c).insetBy(dx: -spacing, dy: -spacing).contains(point) {
                    return GridPos(r: r, c: c)
                }
            }
        }
        return nil
    }

    private func straightLine(from start: GridPos, to end: GridPos) -> [GridPos] {
        let dr = end.r - start.r
        let dc = end.c - start.c
        if dr == 0 && dc == 0 { return [start] }

        let absR = abs(dr)
        let absC = abs(dc)
        var er = end.r
        var ec = end.c
        if !(absR == 0 || absC == 0 || absR == absC) {
            if absR > absC {
                ec = start.c
            } else {
                er = start.r
            }
        }

        let fdr = er - start.r
        let fdc = ec - start.c
        let steps = max(abs(fdr), abs(fdc))
        guard steps > 0, fdr == 0 || fdc == 0 || abs(fdr) == abs(fdc) else { return [start] }
        let sr = fdr == 0 ? 0 : fdr / abs(fdr)
        let sc = fdc == 0 ? 0 : fdc / abs(fdc)
        var path: [GridPos] = []
        for i in 0...steps {
            let nr = start.r + sr * i
            let nc = start.c + sc * i
            guard (0..<gridCount).contains(nr), (0..<gridCount).contains(nc) else { break }
            path.append(GridPos(r: nr, c: nc))
        }
        return path
    }

    private func center(of pos: GridPos) -> CGPoint {
        let f = cellFrame(r: pos.r, c: pos.c)
        return CGPoint(x: f.midX, y: f.midY)
    }

    private func path(for cells: [GridPos]) -> UIBezierPath {
        let p = UIBezierPath()
        guard let first = cells.first else { return p }
        p.move(to: center(of: first))
        if cells.count == 1 { return p }
        p.addLine(to: center(of: cells.last!))
        return p
    }

    private func redrawFound() {
        let combined = UIBezierPath()
        // Draw each found word as its own stroke via sublayers kept simple: one path per word
        foundShape.sublayers?.forEach { $0.removeFromSuperlayer() }
        for (word, cells) in foundPaths where cells.count >= 2 {
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.fillColor = nil
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.lineWidth = cellSize() * 0.78
            let color = colors[word] ?? UIColor(red: 28/255, green: 70/255, blue: 178/255, alpha: 1)
            layer.strokeColor = color.withAlphaComponent(0.55).cgColor
            layer.path = path(for: cells).cgPath
            foundShape.addSublayer(layer)
        }
        _ = combined
    }

    private func redrawSelecting() {
        if selecting.count >= 2 {
            selectShape.path = path(for: selecting).cgPath
        } else if selecting.count == 1 {
            let c = center(of: selecting[0])
            let p = UIBezierPath(ovalIn: CGRect(x: c.x - 12, y: c.y - 12, width: 24, height: 24))
            selectShape.path = p.cgPath
        } else {
            selectShape.path = nil
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), let cell = cell(at: point) else { return }
        selecting = [cell]
        redrawSelecting()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let pos = cell(at: point) ?? nearestCell(to: point)
        guard let pos = pos, let start = selecting.first else { return }
        selecting = straightLine(from: start, to: pos)
        redrawSelecting()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishSelection()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishSelection()
    }

    private func nearestCell(to point: CGPoint) -> GridPos? {
        var best: (GridPos, CGFloat)?
        for r in 0..<gridCount {
            for c in 0..<gridCount {
                let f = cellFrame(r: r, c: c)
                let d = hypot(f.midX - point.x, f.midY - point.y)
                if best == nil || d < best!.1 {
                    best = (GridPos(r: r, c: c), d)
                }
            }
        }
        return best?.0
    }

    private func finishSelection() {
        let path = selecting
        selecting = []
        redrawSelecting()
        onFinishedPath?(path)
    }
}

private extension UIColor {
    convenience init(rgbHex: String) {
        let hex = rgbHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: CGFloat((int >> 16) & 0xFF) / 255,
            green: CGFloat((int >> 8) & 0xFF) / 255,
            blue: CGFloat(int & 0xFF) / 255,
            alpha: 1
        )
    }
}

struct GridPos: Hashable {
    let r: Int
    let c: Int
}

enum WordSearchBuilder {
    static var lastPlacements: [String: [GridPos]] = [:]

    static func build(size: Int, words: [String]) -> [[Character]] {
        buildWithPaths(size: size, words: words).grid
    }

    static func buildWithPaths(size: Int, words: [String]) -> (grid: [[Character]], placements: [String: [GridPos]]) {
        var grid = Array(repeating: Array(repeating: Character(" "), count: size), count: size)
        var placements: [String: [GridPos]] = [:]
        let dirs = [(0, 1), (1, 0), (1, 1), (0, -1), (-1, 0), (-1, -1), (1, -1), (-1, 1)]

        for word in words where word.count <= size {
            let chars = Array(word)
            var placed = false
            for _ in 0..<200 {
                let dir = dirs.randomElement()!
                let r0 = Int.random(in: 0..<size)
                let c0 = Int.random(in: 0..<size)
                let rEnd = r0 + dir.0 * (chars.count - 1)
                let cEnd = c0 + dir.1 * (chars.count - 1)
                guard (0..<size).contains(rEnd), (0..<size).contains(cEnd) else { continue }

                var fits = true
                for i in 0..<chars.count {
                    let r = r0 + dir.0 * i
                    let c = c0 + dir.1 * i
                    let existing = grid[r][c]
                    if existing != " " && existing != chars[i] {
                        fits = false
                        break
                    }
                }
                guard fits else { continue }

                var path: [GridPos] = []
                for i in 0..<chars.count {
                    let r = r0 + dir.0 * i
                    let c = c0 + dir.1 * i
                    grid[r][c] = chars[i]
                    path.append(GridPos(r: r, c: c))
                }
                placements[word] = path
                placed = true
                break
            }
            _ = placed
        }

        var fillBag = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").shuffled()
        var fillIndex = 0
        for r in 0..<size {
            for c in 0..<size {
                if grid[r][c] == " " {
                    if fillIndex >= fillBag.count {
                        fillBag = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").shuffled()
                        fillIndex = 0
                    }
                    grid[r][c] = fillBag[fillIndex]
                    fillIndex += 1
                }
            }
        }
        return (grid, placements)
    }
}
