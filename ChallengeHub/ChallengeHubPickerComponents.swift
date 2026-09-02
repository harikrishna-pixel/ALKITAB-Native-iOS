//
//  ChallengeHubPickerComponents.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

struct ChallengeHubPickerCard: View {
    let title: String
    let value: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.45))
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "0B1B3A"))
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.25))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChallengeQuizPickerSheet<Content: View>: View {
    let title: String
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(title: title, showBackButton: false)
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button(action: onClose) {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ChallengeQuizTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
    }
}

struct ChallengeBookListPicker: UIViewRepresentable {
    var onSelect: (BookSelection) -> Void

    struct BookSelection {
        let bookName: String
        let chapterCount: Int
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let list = BookList.fromNib(named: "BookList")
        list.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(list)
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: container.topAnchor),
            list.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        context.coordinator.attach(list: list)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject, QuizSelect {
        private let onSelect: (BookSelection) -> Void
        private weak var list: BookList?

        init(onSelect: @escaping (BookSelection) -> Void) {
            self.onSelect = onSelect
        }

        func attach(list: BookList) {
            self.list = list
            QuizProtocol.QuizSelectdelegate = self
        }

        func Selection(BookCount: String) {
            let parts = BookCount.components(separatedBy: "-")
            guard let count = Int(parts.last ?? "") else { return }
            onSelect(BookSelection(bookName: parts[0], chapterCount: count))
        }

        func ChapterSelection(Chapter: String) {}
    }
}

struct ChallengeChapterListPicker: UIViewRepresentable {
    let chapterCount: Int
    var onSelect: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let list = Chapter.fromNib(named: "Chapter")
        list.ChapterCount = chapterCount
        list.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(list)
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: container.topAnchor),
            list.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        context.coordinator.attach(list: list)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject, QuizSelect {
        private let onSelect: (String) -> Void
        private weak var list: Chapter?

        init(onSelect: @escaping (String) -> Void) {
            self.onSelect = onSelect
        }

        func attach(list: Chapter) {
            self.list = list
            QuizProtocol.QuizSelectdelegate = self
        }

        func Selection(BookCount: String) {}

        func ChapterSelection(Chapter: String) {
            onSelect(Chapter)
        }
    }
}
