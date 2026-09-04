//
//  QuizOrChallengeChooserView.swift
//  NKJV Bible
//
//  Quiz Hub after Mark as Read → Play Quiz.
//  Pick Bible Quiz or a challenge type, then book/chapter/difficulty.
//  Does not change quiz or challenge game logic.
//

import SwiftUI
import UIKit

/// Where Let's Start should go after book / chapter / difficulty selection.
enum MarkAsReadQuizDestination {
    case bibleQuiz
    case challenge(ChallengeKind)
}

struct QuizOrChallengeChooserView: View {
    let bookName: String
    let chapterLabel: String
    var onBack: () -> Void
    var onBibleQuiz: () -> Void
    var onOpenChallenge: (ChallengeKind) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ChallengeQuizHeaderBar(
                title: "Quiz Hub",
                showBackButton: true,
                onBack: onBack
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(bookName) · Chapter \(chapterLabel)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "0B1B3A"))
                        Text("Choose Bible Quiz or a challenge, then pick book, chapter, and difficulty.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.black.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)

                    Button(action: onBibleQuiz) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "EEF1F7"))
                                    .frame(width: 48, height: 48)
                                Image("Quiz")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(ChallengeQuizTheme.accent)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bible Quiz")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "0B1B3A"))
                                Text("Classic fill-in quiz for this chapter")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.black.opacity(0.45))
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            Text("Free")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(ChallengeQuizTheme.accent)
                                .clipShape(Capsule())

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.black.opacity(0.2))
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())

                    ForEach(ChallengeKind.allCases) { kind in
                        choiceCard(
                            title: kind.title,
                            subtitle: kind.subtitle,
                            icon: kind.icon,
                            tintHex: kind.iconTintHex,
                            bgHex: kind.iconBgHex,
                            isPremium: kind.isPremium,
                            action: { onOpenChallenge(kind) }
                        )
                    }
                }
                .padding(16)
            }
        }
        .background(Color(hex: "F2F3F7").ignoresSafeArea())
    }

    private func choiceCard(
        title: String,
        subtitle: String,
        icon: String,
        tintHex: String,
        bgHex: String,
        isPremium: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: bgHex))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: tintHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "0B1B3A"))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.45))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                        Text("Premium")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "C9A227"))
                } else {
                    Text("Free")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ChallengeQuizTheme.accent)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.black.opacity(0.2))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

final class QuizOrChallengeChooserViewController: UIViewController {

    var bookName: String = ""
    var chapter: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        let displayChapter: String = {
            if let value = Int(chapter) {
                return value > 0 ? "\(value)" : "\(value + 1)"
            }
            return chapter.isEmpty ? "—" : chapter
        }()

        let root = QuizOrChallengeChooserView(
            bookName: bookName.isEmpty ? (UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName) : bookName,
            chapterLabel: displayChapter,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onBibleQuiz: { [weak self] in
                self?.openSelection(destination: .bibleQuiz)
            },
            onOpenChallenge: { [weak self] kind in
                self?.openSelection(destination: .challenge(kind))
            }
        )

        let host = UIHostingController(rootView: root)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func openSelection(destination: MarkAsReadQuizDestination) {
        let book = bookName.isEmpty
            ? (UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName)
            : bookName
        let chapterValue = chapter.isEmpty
            ? (UserDefaults.standard.string(forKey: "BookChapter") ?? "0")
            : chapter

        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
        vc.BookString = book
        vc.ChapterString = chapterValue
        vc.ChapterCount = BibleContent.sharedInstance.AudioBibleListCount(selecterBookName: book)
        vc.markAsReadDestination = destination
        navigationController?.pushViewController(vc, animated: true)
    }
}

private final class QuizChooserPushedHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
