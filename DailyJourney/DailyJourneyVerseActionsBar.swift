//
//  DailyJourneyVerseActionsBar.swift
//  NKJV Bible
//

import UIKit
import SwiftUI

/// UIKit share / bookmark controls with a real hit area (avoids ScrollView swallowing SwiftUI taps).
struct DailyJourneyVerseActionsBar: UIViewRepresentable {
    var onShare: () -> Void
    var onBookmark: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onShare: onShare, onBookmark: onBookmark)
    }

    func makeUIView(context: Context) -> VerseActionsContainer {
        let container = VerseActionsContainer()
        container.coordinator = context.coordinator
        return container
    }

    func updateUIView(_ uiView: VerseActionsContainer, context: Context) {
        context.coordinator.onShare = onShare
        context.coordinator.onBookmark = onBookmark
        uiView.coordinator = context.coordinator
    }

    final class Coordinator: NSObject {
        var onShare: () -> Void
        var onBookmark: () -> Void

        init(onShare: @escaping () -> Void, onBookmark: @escaping () -> Void) {
            self.onShare = onShare
            self.onBookmark = onBookmark
        }

        @objc func shareTapped() {
            onShare()
        }

        @objc func bookmarkTapped() {
            onBookmark()
        }
    }
}

final class VerseActionsContainer: UIView {
    weak var coordinator: DailyJourneyVerseActionsBar.Coordinator? {
        didSet { bindTargets() }
    }

    private let shareButton = UIButton(type: .custom)
    private let bookmarkButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        configure(shareButton, systemName: "square.and.arrow.up")
        configure(bookmarkButton, systemName: "photo.fill")
        addSubview(shareButton)
        addSubview(bookmarkButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 82, height: 36)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shareButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        bookmarkButton.frame = CGRect(x: 46, y: 0, width: 36, height: 36)
        shareButton.layer.cornerRadius = 18
        bookmarkButton.layer.cornerRadius = 18
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -6, dy: -6).contains(point)
    }

    private func configure(_ button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = UIColor(red: 28 / 255, green: 70 / 255, blue: 178 / 255, alpha: 1)
        button.backgroundColor = UIColor(red: 232 / 255, green: 238 / 255, blue: 255 / 255, alpha: 1)
        button.clipsToBounds = true
        button.isUserInteractionEnabled = true
    }

    private func bindTargets() {
        shareButton.removeTarget(nil, action: nil, for: .allEvents)
        bookmarkButton.removeTarget(nil, action: nil, for: .allEvents)
        guard let coordinator = coordinator else { return }
        shareButton.addTarget(coordinator, action: #selector(DailyJourneyVerseActionsBar.Coordinator.shareTapped), for: .touchUpInside)
        bookmarkButton.addTarget(coordinator, action: #selector(DailyJourneyVerseActionsBar.Coordinator.bookmarkTapped), for: .touchUpInside)
    }
}
