//
//  AIChatViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift
import IQKeyboardManager

struct AIChatLaunchContext {
    let isChapterSummary: Bool
    let title: String
    let verseText: String?
    let sourceText: String
}

private struct AIChatMessage {
    enum Role {
        case user
        case assistant
    }

    let role: Role
    let text: String
    var answer: AIChatAnswer? = nil
    var followUps: [String] = []
}

/// Structured assistant reply: lead sentence, one passage, short points.
private struct AIChatAnswer {
    let lead: String
    let reference: String?
    var verse: String?
    let points: [String]

    private static let labels = ["LEAD", "REF", "VERSE", "POINT", "NEXT"]

    static func parse(_ reply: String) -> (answer: AIChatAnswer?, followUps: [String], plainText: String) {
        var lead = ""
        var reference: String?
        var verse: String?
        var points: [String] = []
        var followUps: [String] = []
        var plainLines: [String] = []

        for rawLine in reply.components(separatedBy: .newlines) {
            let line = rawLine.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces)
            guard let colon = line.firstIndex(of: ":"),
                  case let label = line[..<colon].trimmingCharacters(in: .whitespaces).uppercased(),
                  labels.contains(label) else {
                plainLines.append(line)
                continue
            }
            let value = line[line.index(after: colon)...].trimmingCharacters(in: CharacterSet(charactersIn: "-•· "))
            let isEmptyValue = value.isEmpty || value.uppercased() == "NONE"
            switch label {
            case "LEAD":
                if !isEmptyValue { lead = value }
            case "REF":
                if !isEmptyValue { reference = value }
            case "VERSE":
                if !isEmptyValue { verse = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”")) }
            case "POINT":
                if !isEmptyValue { points.append(value) }
            default:
                if !isEmptyValue { followUps.append(value) }
            }
            if label != "NEXT", label != "REF", !isEmptyValue {
                plainLines.append(value)
            }
        }

        let plain = plainLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lead.isEmpty, !points.isEmpty else {
            return (nil, Array(followUps.prefix(2)), plain.isEmpty ? reply : plain)
        }
        let answer = AIChatAnswer(lead: lead, reference: reference, verse: verse, points: Array(points.prefix(3)))
        return (answer, Array(followUps.prefix(2)), answer.plainText)
    }

    var plainText: String {
        var parts = [lead]
        if let verse = verse, !verse.isEmpty {
            parts.append("\"\(verse)\"" + (reference.map { "\n— \($0)" } ?? ""))
        }
        parts.append(points.map { "• \($0)" }.joined(separator: "\n"))
        return parts.joined(separator: "\n\n")
    }
}

/// Reads verse text from the Bible installed in the app (Documents/<SelectedLanguage>).
private enum AIChatScripture {
    private static let lock = NSLock()
    private static var cachedFolder: String?
    private static var cachedChapters: [String: [String]] = [:]

    private static func folderURL() -> (name: String, url: URL)? {
        guard let folder = UserDefaults.standard.string(forKey: "SelectedLanguage"), !folder.isEmpty,
              let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return (folder, documents.appendingPathComponent(folder))
    }

    static func books() -> [(name: String, chapters: Int)] {
        guard let url = folderURL()?.url.appendingPathComponent("fullchapters.plist"),
              let data = try? Data(contentsOf: url),
              let list = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String] else { return [] }
        return list.map { entry in
            guard let dash = entry.lastIndex(of: "-"),
                  let count = Int(entry[entry.index(after: dash)...]) else { return (entry, 0) }
            return (String(entry[..<dash]).trimmingCharacters(in: .whitespaces), count)
        }
    }

    /// "Book 3:16" or "Book 3:16-18" (up to 4 verses). Nil when the reference is not in the installed Bible.
    static func text(for reference: String) -> String? {
        let trimmed = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^(.+?)\s+(\d{1,3})\s*:\s*(\d{1,3})(?:\s*[-–]\s*(\d{1,3}))?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              let bookRange = Range(match.range(at: 1), in: trimmed),
              let chapterRange = Range(match.range(at: 2), in: trimmed),
              let verseRange = Range(match.range(at: 3), in: trimmed),
              let chapter = Int(trimmed[chapterRange]),
              let firstVerse = Int(trimmed[verseRange]) else { return nil }
        var lastVerse = firstVerse
        if let endRange = Range(match.range(at: 4), in: trimmed), let end = Int(trimmed[endRange]), end >= firstVerse {
            lastVerse = min(end, firstVerse + 3)
        }

        let bookName = String(trimmed[bookRange]).replacingOccurrences(of: ".", with: "")
        let list = books()
        guard let bookIndex = list.firstIndex(where: { $0.name.caseInsensitiveCompare(bookName) == .orderedSame }),
              chapter >= 1, chapter <= list[bookIndex].chapters,
              let chapters = chapterTexts(bookNumber: bookIndex + 1),
              chapter <= chapters.count else { return nil }

        var chapterText = chapters[chapter - 1].withoutHtmlTags()
        chapterText = chapterText.deletingPrefix("\n")
        let verses = chapterText.components(separatedBy: "@@@@").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard firstVerse >= 1, firstVerse <= verses.count else { return nil }
        let picked = verses[(firstVerse - 1)..<min(lastVerse, verses.count)].filter { !$0.isEmpty }
        return picked.isEmpty ? nil : picked.joined(separator: " ")
    }

    private static func chapterTexts(bookNumber: Int) -> [String]? {
        guard let folder = folderURL() else { return nil }
        lock.lock()
        defer { lock.unlock() }
        if cachedFolder != folder.name {
            let url = folder.url.appendingPathComponent("audio.plist")
            guard let data = try? Data(contentsOf: url),
                  let dictionary = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: [String]] else { return nil }
            cachedChapters = dictionary
            cachedFolder = folder.name
        }
        return cachedChapters[String(bookNumber)]
    }
}

final class AIChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool
    private var messages: [AIChatMessage] = []
    private var isSending = false

    private let bannerView = UIView()
    private let titleLabel = UILabel()
    private let backImageView = UIImageView()
    private let backButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = UIView()
    private let suggestionContainer = UIView()
    private let suggestionStack = UIStackView()
    private let composerContainer = UIView()
    private let inputTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let freeCountLabel = UILabel()
    private let sendButton = UIButton(type: .custom)

    private var bannerHeightConstraint: NSLayoutConstraint?
    private var composerBottomConstraint: NSLayoutConstraint?
    private var inputHeightConstraint: NSLayoutConstraint?
    private var suggestionTrailingConstraint: NSLayoutConstraint?
    private var tableAboveSuggestionsConstraint: NSLayoutConstraint?
    private var tableAboveComposerConstraint: NSLayoutConstraint?
    private var verseSuggestionFooterWidth: CGFloat = 0
    private var contextHeaderShowsGreeting: Bool?
    private var starterFooter: UIView?
    private var starterFooterWidth: CGFloat = 0
    private lazy var starterTitles: [String] = Array(starterSuggestions().prefix(3))
    private var animatedRowCount = 0
    private var showsLimitCard = false
    private var limitCardFooterWidth: CGFloat = 0
    var launchContext: AIChatLaunchContext?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(chatCreditsAdded(_:)), name: AIUsageLimiter.chatCreditsAdded, object: nil)
    }

    @objc private func chatCreditsAdded(_ note: Notification) {
        refreshSendLock()
        let amount = note.userInfo?["amount"] as? Int ?? 20
        view.makeToast("\(amount) credits added to the wallet", duration: 2.0, position: .top)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App_Protocol.delegateReader?.hideBottomMenu(Status: true)
        // AI Chat owns keyboard inset; disable global IQKeyboard so the whole screen does not shift/stack.
        IQKeyboardManager.shared().isEnabled = false
        refreshSendLock()
        restoreChatLayout()
    }

    @objc private func appDidBecomeActive() {
        guard view.window != nil, presentedViewController == nil else { return }
        restoreChatLayout()
    }

    /// Screenshot / system share UI can leave the composer off-screen and the system nav bar visible.
    private func restoreChatLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if !inputTextView.isFirstResponder {
            composerBottomConstraint?.constant = 0
        }
        if suggestionStack.arrangedSubviews.isEmpty {
            refreshFollowUpSuggestions()
        }
        emptyStateView.isHidden = true
        view.layoutIfNeeded()
    }

    private func refreshSendLock() {
        if showsLimitCard && !isOutOfFreeChatsAndCredits {
            hideLimitCard()
        }
        let sendConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: sendConfig), for: .normal)
        refreshFreeCount()
    }

    private func refreshFreeCount() {
        // Monthly / Yearly unlimited: no line under the composer (iPhone and iPad).
        if AIUsageLimiter.shared.hasUnlimitedPlan {
            freeCountLabel.attributedText = nil
            return
        }
        let left = AIUsageLimiter.shared.freeUsesLeft(.aiChat)
        let noun = left > 1 ? "messages" : "message"
        let grey = isNight ? UIColor.white.withAlphaComponent(0.55) : UIColor(white: 0.45, alpha: 1)
        let link = isNight ? UIColor.white : themeColor
        let line = NSMutableAttributedString(string: "\(left) \(noun) available today.", attributes: [
            .foregroundColor: grey,
            .font: UIFont.systemFont(ofSize: 13)
        ])
        // Lifetime / Exit already owns premium — don't offer Main Paywall again.
        if !AIUsageLimiter.shared.ownsLifetimeAccess {
            line.append(NSAttributedString(string: " ", attributes: [
                .foregroundColor: grey,
                .font: UIFont.systemFont(ofSize: 13)
            ]))
            line.append(NSAttributedString(string: "Unlimited with Premium", attributes: [
                .foregroundColor: link,
                .font: UIFont.systemFont(ofSize: 13),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]))
        }
        freeCountLabel.attributedText = line
    }

    @objc private func freeCountTapped() {
        guard !AIUsageLimiter.shared.hasUnlimitedPlan else { return }
        guard !AIUsageLimiter.shared.ownsLifetimeAccess else { return }
        view.endEditing(true)
        AIUsageLimiter.shared.presentPlansPaywall()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true
    }

    deinit {
        IQKeyboardManager.shared().isEnabled = true
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = isNight ? DarkModeColor : themeColor
        view.addSubview(bannerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Your Bible Companion"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        bannerView.addSubview(titleLabel)

        backImageView.translatesAutoresizingMaskIntoConstraints = false
        backImageView.image = UIImage(named: "BackArrow")
        backImageView.contentMode = .scaleAspectFit
        view.addSubview(backImageView)
        ImageTint.sharedInstance.imageTintcolorMethod(img: backImageView, colorVu: .white)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AIChatBubbleCell.self, forCellReuseIdentifier: AIChatBubbleCell.reuseId)
        tableView.register(AIChatWaitingCell.self, forCellReuseIdentifier: AIChatWaitingCell.reuseId)
        tableView.register(AIChatAnswerCell.self, forCellReuseIdentifier: AIChatAnswerCell.reuseId)
        view.addSubview(tableView)

        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.backgroundColor = .clear
        view.addSubview(suggestionContainer)

        suggestionStack.translatesAutoresizingMaskIntoConstraints = false
        suggestionStack.axis = .vertical
        suggestionStack.alignment = .leading
        suggestionStack.spacing = 10
        suggestionContainer.addSubview(suggestionStack)

        composerContainer.translatesAutoresizingMaskIntoConstraints = false
        composerContainer.backgroundColor = isNight ? DarkModeColor : .white
        view.addSubview(composerContainer)

        let composerLine = UIView()
        composerLine.translatesAutoresizingMaskIntoConstraints = false
        composerLine.backgroundColor = UIColor.black.withAlphaComponent(isNight ? 0.25 : 0.08)
        composerContainer.addSubview(composerLine)

        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.textColor = isNight ? .white : .black
        inputTextView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
        inputTextView.layer.cornerRadius = 20
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        inputTextView.delegate = self
        inputTextView.isScrollEnabled = false
        composerContainer.addSubview(inputTextView)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Ask about a verse..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.45) : .gray
        inputTextView.addSubview(placeholderLabel)

        freeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        freeCountLabel.font = UIFont.systemFont(ofSize: 12)
        freeCountLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.55) : UIColor(white: 0.45, alpha: 1)
        freeCountLabel.textAlignment = .center
        freeCountLabel.isUserInteractionEnabled = true
        freeCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(freeCountTapped)))
        composerContainer.addSubview(freeCountLabel)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: sendConfig), for: .normal)
        sendButton.tintColor = isNight ? .white : themeColor
        sendButton.adjustsImageWhenHighlighted = true
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.imageView?.clipsToBounds = false
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        composerContainer.addSubview(sendButton)

        setupEmptyState()

        let bannerHeight: CGFloat = StatusbarHeight > 30 ? 90 : 70
        bannerHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: bannerHeight)
        composerBottomConstraint = composerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 40)
        let tableAboveSuggestions = tableView.bottomAnchor.constraint(equalTo: suggestionContainer.topAnchor)
        tableAboveSuggestionsConstraint = tableAboveSuggestions
        let tableAboveComposer = tableView.bottomAnchor.constraint(equalTo: composerContainer.topAnchor)
        tableAboveComposer.isActive = false
        tableAboveComposerConstraint = tableAboveComposer

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerHeightConstraint!,

            titleLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: bannerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: backImageView.centerYAnchor),

            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backImageView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -15),
            backImageView.widthAnchor.constraint(equalToConstant: 20),
            backImageView.heightAnchor.constraint(equalToConstant: 20),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            composerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerBottomConstraint!,

            composerLine.topAnchor.constraint(equalTo: composerContainer.topAnchor),
            composerLine.leadingAnchor.constraint(equalTo: composerContainer.leadingAnchor),
            composerLine.trailingAnchor.constraint(equalTo: composerContainer.trailingAnchor),
            composerLine.heightAnchor.constraint(equalToConstant: 0.5),

            inputTextView.topAnchor.constraint(equalTo: composerContainer.topAnchor, constant: 10),
            inputTextView.leadingAnchor.constraint(equalTo: composerContainer.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputHeightConstraint!,

            freeCountLabel.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 6),
            freeCountLabel.leadingAnchor.constraint(equalTo: composerContainer.leadingAnchor, constant: 16),
            freeCountLabel.trailingAnchor.constraint(equalTo: composerContainer.trailingAnchor, constant: -16),
            freeCountLabel.bottomAnchor.constraint(equalTo: composerContainer.safeAreaLayoutGuide.bottomAnchor, constant: -6),

            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 16),

            sendButton.trailingAnchor.constraint(equalTo: composerContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalTo: inputTextView.heightAnchor),
            sendButton.heightAnchor.constraint(equalTo: inputTextView.heightAnchor),

            tableView.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableAboveSuggestions,

            suggestionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionContainer.bottomAnchor.constraint(equalTo: composerContainer.topAnchor),

            suggestionStack.topAnchor.constraint(equalTo: suggestionContainer.topAnchor, constant: 8),
            suggestionStack.leadingAnchor.constraint(equalTo: suggestionContainer.leadingAnchor, constant: 16),
            suggestionStack.trailingAnchor.constraint(lessThanOrEqualTo: suggestionContainer.trailingAnchor, constant: -16),
            suggestionStack.bottomAnchor.constraint(equalTo: suggestionContainer.bottomAnchor, constant: -8),
            {
                let constraint = suggestionStack.trailingAnchor.constraint(lessThanOrEqualTo: suggestionContainer.trailingAnchor, constant: -16)
                suggestionTrailingConstraint = constraint
                return constraint
            }(),
            emptyStateView.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: suggestionContainer.topAnchor)
        ])

        refreshFollowUpSuggestions()
        view.bringSubviewToFront(suggestionContainer)
        if launchContext != nil {
            suggestionTrailingConstraint?.isActive = false
            let filled = suggestionStack.trailingAnchor.constraint(equalTo: suggestionContainer.trailingAnchor, constant: -16)
            filled.isActive = true
            suggestionTrailingConstraint = filled
            suggestionStack.alignment = .fill
        }

        refreshFollowUpSuggestions()
        view.bringSubviewToFront(suggestionContainer)
        view.bringSubviewToFront(composerContainer)
        emptyStateView.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        installContextHeaderIfNeeded()
        installVerseSuggestionFooterIfNeeded()
        installStarterFooterIfNeeded()
        installLimitCardIfNeeded()
        fitEmptyStateToSpace()
    }

    /// With the keyboard up on small screens the welcome text has no room and would sit under the suggestion chips.
    private func fitEmptyStateToSpace() {
        let needed = emptyStateView.subviews.map { $0.frame.maxY }.max() ?? 0
        emptyStateView.alpha = emptyStateView.bounds.height >= needed ? 1 : 0
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        let iconView = UIImageView(image: UIImage(systemName: "sparkles"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = isNight ? .white : themeColor
        iconView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(iconView)

        let heading = UILabel()
        heading.translatesAutoresizingMaskIntoConstraints = false
        heading.text = "Bible AI Assistant"
        heading.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        heading.textColor = isNight ? .white : themeColor
        heading.textAlignment = .center
        emptyStateView.addSubview(heading)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Ask for verse meaning, context, or study help."
        subtitle.font = UIFont.systemFont(ofSize: 15)
        subtitle.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        emptyStateView.addSubview(subtitle)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 80),
            iconView.widthAnchor.constraint(equalToConstant: 42),
            iconView.heightAnchor.constraint(equalToConstant: 42),

            heading.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            heading.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 24),
            heading.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -24),

            subtitle.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 8),
            subtitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 32),
            subtitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -32)
        ])
    }

    private func makeSuggestionChip(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(isNight ? .white : themeColor, for: .normal)
        button.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : themeColor.withAlphaComponent(0.08)
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
        return button
    }

    /// Always false: Keep Ask (Explanation / Summary) suggestion rows above the composer, like Bible Companion.
    private var pinsVerseQuestionsUnderCard: Bool { false }

    /// CONTINUE chips sit above the composer (not under the answer). Starters stay in the chat footer.
    private func refreshFollowUpSuggestions() {
        clearSuggestionStack()
        let followUps = messages.last(where: { $0.role == .assistant })?.followUps ?? []
        let showContinue = !followUps.isEmpty && !isSending && !showsLimitCard
        if showContinue {
            // Match THE PASSAGE / WHY IT MATTERS title color (theme / teal), not gray body chrome.
            let titleColor = isNight ? UIColor.white.withAlphaComponent(0.85) : themeColor
            let heading = UILabel()
            heading.attributedText = NSAttributedString(
                string: usesIndonesian ? "LANJUTKAN" : "CONTINUE",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
                    .kern: 1.3,
                    .foregroundColor: titleColor
                ]
            )
            suggestionStack.addArrangedSubview(heading)
            followUps.forEach { suggestionStack.addArrangedSubview(makeSuggestionChip(title: $0)) }
            suggestionContainer.isHidden = false
            tableAboveComposerConstraint?.isActive = false
            tableAboveSuggestionsConstraint?.isActive = true
        } else {
            suggestionContainer.isHidden = true
            tableAboveSuggestionsConstraint?.isActive = false
            tableAboveComposerConstraint?.isActive = true
        }
        installStarterFooterIfNeeded()
        view.setNeedsLayout()
    }

    private func installStarterFooterIfNeeded() {
        guard !showsLimitCard else { return }
        guard messages.isEmpty, !isSending else {
            if starterFooter != nil {
                tableView.tableFooterView = nil
                starterFooter = nil
                starterFooterWidth = 0
            }
            return
        }
        let width = tableView.bounds.width
        guard width > 0 else { return }
        if abs(starterFooterWidth - width) < 1, starterFooter != nil { return }

        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(stack)

        if launchContext == nil {
            let heading = UILabel()
            heading.text = "Bible AI Assistant"
            heading.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            heading.textColor = isNight ? .white : UIColor(red: 0.086, green: 0.1, blue: 0.13, alpha: 1)
            heading.numberOfLines = 0
            stack.addArrangedSubview(heading)
            stack.setCustomSpacing(6, after: heading)

            let subtitle = UILabel()
            subtitle.text = "Ask for verse meaning, context, or study help."
            subtitle.font = UIFont.systemFont(ofSize: 14.5)
            subtitle.textColor = isNight ? UIColor.white.withAlphaComponent(0.6) : UIColor(red: 0.42, green: 0.45, blue: 0.5, alpha: 1)
            subtitle.numberOfLines = 0
            stack.addArrangedSubview(subtitle)
            stack.setCustomSpacing(18, after: subtitle)
        }
        starterTitles.forEach { stack.addArrangedSubview(makeStarterRow(title: $0)) }

        let widthConstraint = footer.widthAnchor.constraint(equalToConstant: width)
        NSLayoutConstraint.activate([
            widthConstraint,
            stack.topAnchor.constraint(equalTo: footer.topAnchor, constant: launchContext == nil ? 12 : 4),
            stack.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -8)
        ])
        let height = footer.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        widthConstraint.isActive = false
        footer.translatesAutoresizingMaskIntoConstraints = true
        footer.frame = CGRect(x: 0, y: 0, width: width, height: max(height, 1))
        starterFooter = footer
        starterFooterWidth = width
        tableView.tableFooterView = footer
    }

    private func makeStarterRow(title: String) -> UIButton {
        let row = UIButton(type: .custom)
        row.setTitle(title, for: .normal)
        row.titleLabel?.font = UIFont.systemFont(ofSize: 14.5)
        row.titleLabel?.numberOfLines = 2
        row.contentHorizontalAlignment = .left
        let ink = isNight ? UIColor.white : UIColor(red: 0.086, green: 0.1, blue: 0.13, alpha: 1)
        row.setTitleColor(ink, for: .normal)
        row.setTitleColor(isNight ? .white : themeColor, for: .highlighted)
        row.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        row.layer.cornerRadius = 14
        row.layer.borderWidth = 1
        row.layer.borderColor = (isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.91, green: 0.925, blue: 0.95, alpha: 1)).cgColor
        row.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 40)
        row.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = isNight ? UIColor.white.withAlphaComponent(0.45) : UIColor(red: 0.6, green: 0.63, blue: 0.68, alpha: 1)
        chevron.isUserInteractionEnabled = false
        row.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    /// Free chats used up and not enough credits for one more message.
    private var isOutOfFreeChatsAndCredits: Bool {
        let limiter = AIUsageLimiter.shared
        return AIDisclaimer.isAccepted
            && !limiter.hasUnlimitedPlan
            && limiter.freeUsesLeft(.aiChat) <= 0
            && ChallengeWallet.coins < AIUsageFeature.aiChat.creditCost
    }

    private func showLimitCard() {
        view.endEditing(true)
        guard !showsLimitCard else {
            scrollToLimitCard()
            return
        }
        showsLimitCard = true
        tableView.tableFooterView = nil
        starterFooter = nil
        starterFooterWidth = 0
        limitCardFooterWidth = 0
        installLimitCardIfNeeded()
        scrollToLimitCard()
    }

    private func hideLimitCard() {
        guard showsLimitCard else { return }
        showsLimitCard = false
        tableView.tableFooterView = nil
        limitCardFooterWidth = 0
        installStarterFooterIfNeeded()
    }

    private func scrollToLimitCard() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let footer = self.tableView.tableFooterView, self.showsLimitCard else { return }
            self.tableView.layoutIfNeeded()
            self.tableView.scrollRectToVisible(footer.frame, animated: true)
        }
    }

    private func installLimitCardIfNeeded() {
        guard showsLimitCard else { return }
        let width = tableView.bounds.width
        guard width > 0 else { return }
        if abs(limitCardFooterWidth - width) < 1, tableView.tableFooterView != nil { return }

        let ink = isNight ? UIColor.white : UIColor(red: 0.086, green: 0.1, blue: 0.13, alpha: 1)
        let ink3 = isNight ? UIColor.white.withAlphaComponent(0.6) : UIColor(red: 0.42, green: 0.45, blue: 0.5, alpha: 1)
        let accent = isNight ? UIColor.white : themeColor

        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        card.layer.cornerRadius = 22
        card.layer.borderWidth = 1
        card.layer.borderColor = (isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 0.91, green: 0.925, blue: 0.95, alpha: 1)).cgColor
        footer.addSubview(card)

        let iconBox = UIView()
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.backgroundColor = accent.withAlphaComponent(isNight ? 0.14 : 0.1)
        iconBox.layer.cornerRadius = 14
        let icon = UIImageView(image: UIImage(systemName: "sparkle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        iconBox.addSubview(icon)

        let title = UILabel()
        title.text = "That’s today’s free messages"
        title.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        title.textColor = ink
        title.textAlignment = .center
        title.numberOfLines = 0

        let message = UILabel()
        message.text = "You get \(AIUsageFeature.aiChat.dailyFreeLimit) free messages a day. Premium removes the limit on chat, verse explanations and chapter summaries."
        message.font = UIFont.systemFont(ofSize: 14.5)
        message.textColor = ink3
        message.textAlignment = .center
        message.numberOfLines = 0

        let later = UIButton(type: .system)
        later.setTitle("Maybe tomorrow", for: .normal)
        later.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        later.setTitleColor(ink3, for: .normal)
        later.translatesAutoresizingMaskIntoConstraints = false
        later.heightAnchor.constraint(equalToConstant: 40).isActive = true
        later.addTarget(self, action: #selector(limitCardLaterTapped), for: .touchUpInside)

        // Lifetime / Exit already owns premium — don't offer Main Paywall again.
        var arranged: [UIView] = [iconBox, title, message]
        var unlimitedButton: UIButton?
        if !AIUsageLimiter.shared.ownsLifetimeAccess {
            let unlimited = UIButton(type: .system)
            unlimited.setTitle("Go unlimited", for: .normal)
            unlimited.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            unlimited.setTitleColor(isNight ? BGNightMode : .white, for: .normal)
            unlimited.backgroundColor = accent
            unlimited.layer.cornerRadius = 14
            unlimited.translatesAutoresizingMaskIntoConstraints = false
            unlimited.heightAnchor.constraint(equalToConstant: 50).isActive = true
            unlimited.addTarget(self, action: #selector(limitCardUnlimitedTapped), for: .touchUpInside)
            unlimitedButton = unlimited
            arranged.append(unlimited)
        }
        arranged.append(later)

        let stack = UIStackView(arrangedSubviews: arranged)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(16, after: iconBox)
        stack.setCustomSpacing(22, after: message)
        if let unlimited = unlimitedButton {
            stack.setCustomSpacing(6, after: unlimited)
        }
        card.addSubview(stack)

        let widthConstraint = footer.widthAnchor.constraint(equalToConstant: width)
        NSLayoutConstraint.activate([
            widthConstraint,
            card.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -12),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),

            iconBox.widthAnchor.constraint(equalToConstant: 46),
            iconBox.heightAnchor.constraint(equalToConstant: 46),
            icon.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),

            title.widthAnchor.constraint(equalTo: stack.widthAnchor),
            message.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        if let unlimited = unlimitedButton {
            unlimited.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
        let height = footer.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        widthConstraint.isActive = false
        footer.translatesAutoresizingMaskIntoConstraints = true
        footer.frame = CGRect(x: 0, y: 0, width: width, height: max(height, 1))
        limitCardFooterWidth = width
        tableView.tableFooterView = footer
    }

    @objc private func limitCardUnlimitedTapped() {
        AIUsageLimiter.shared.presentPlansPaywall()
    }

    @objc private func limitCardLaterTapped() {
        hideLimitCard()
    }

    private func refreshSendButtonState() {
        sendButton.isEnabled = !isSending
        sendButton.alpha = isSending ? 0.35 : 1
    }

    private func clearSuggestionStack() {
        suggestionStack.arrangedSubviews.forEach {
            suggestionStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func installVerseSuggestionFooterIfNeeded() {
        guard pinsVerseQuestionsUnderCard else { return }
        let width = tableView.bounds.width
        guard width > 0, let context = launchContext else { return }
        if abs(verseSuggestionFooterWidth - width) < 1, tableView.tableFooterView != nil {
            return
        }

        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(stack)
        contextSuggestions(for: context).forEach {
            stack.addArrangedSubview(makeContextSuggestionRow(title: $0))
        }
        let widthConstraint = footer.widthAnchor.constraint(equalToConstant: width)
        NSLayoutConstraint.activate([
            widthConstraint,
            stack.topAnchor.constraint(equalTo: footer.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -8)
        ])
        let height = footer.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        widthConstraint.isActive = false
        footer.translatesAutoresizingMaskIntoConstraints = true
        footer.frame = CGRect(x: 0, y: 0, width: width, height: max(height, 1))
        verseSuggestionFooterWidth = width
        tableView.tableFooterView = footer
    }

    private var usesIndonesian: Bool {
        let code = (UserDefaults.standard.string(forKey: "language_code") ?? language_code).lowercased()
        let name = (UserDefaults.standard.string(forKey: "language_name") ?? language_name).lowercased()
        if code.hasPrefix("id") || code == "in" || name.contains("indones") { return true }
        return code.isEmpty && name.isEmpty
    }

    private func passageName(from title: String) -> String {
        title.replacingOccurrences(of: " Summary", with: "")
    }

    private func contextPlaceholder() -> String {
        guard let context = launchContext else { return "Ask about a verse..." }
        if context.isChapterSummary {
            return usesIndonesian ? "Ketik pertanyaan Anda..." : "Type your question..."
        }
        return usesIndonesian ? "Tanyakan tentang \(context.title)..." : "Ask about \(context.title)..."
    }

    private func contextSuggestions(for context: AIChatLaunchContext) -> [String] {
        let name = passageName(from: context.title)
        if usesIndonesian {
            if context.isChapterSummary {
                return [
                    "Apa pesan utama dari \(name)?",
                    "Apa yang terjadi dalam \(name)?",
                    "Siapa yang berperan penting dalam \(name)?",
                    "Apa makna bagian utama dalam \(name)?",
                    "Bagaimana \(name) dapat diterapkan dalam kehidupan saya?"
                ]
            }
            return [
                "Apa arti \(context.title)?",
                "Mengapa ayat ini penting?",
                "Apa yang dimaksud dalam ayat ini?",
                "Bagaimana ayat ini dapat diterapkan?",
                "Apa yang dapat saya pelajari dari \(context.title)?"
            ]
        }
        if context.isChapterSummary {
            return [
                "What is the main message of \(name)?",
                "What happens in \(name)?",
                "Who is important in \(name)?",
                "What does the key part of \(name) mean?",
                "How can \(name) apply to my life?"
            ]
        }
        return [
            "What does \(context.title) mean?",
            "Why is this verse important?",
            "What is this verse saying?",
            "How can this verse be applied?",
            "What can I learn from \(context.title)?"
        ]
    }

    private func makeContextSuggestionRow(title: String) -> UIButton {
        let row = UIButton(type: .system)
        row.setTitle(title, for: .normal)
        row.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        row.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        row.titleLabel?.numberOfLines = 2
        row.titleLabel?.textAlignment = .left
        row.contentHorizontalAlignment = .left
        row.setTitleColor(isNight ? .white : themeColor, for: .normal)
        row.tintColor = isNight ? .white : themeColor
        row.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : themeColor.withAlphaComponent(0.08)
        row.layer.cornerRadius = 16
        row.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 36)
        row.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        row.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = isNight ? UIColor.white.withAlphaComponent(0.7) : themeColor
        chevron.isUserInteractionEnabled = false
        row.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func installContextHeaderIfNeeded() {
        guard let context = launchContext, view.bounds.width > 0 else { return }
        // Chapter Summary greeting is first-open only; drop it once chat has started / answer exists.
        let showGreeting = context.isChapterSummary && messages.isEmpty
        if tableView.tableHeaderView != nil, contextHeaderShowsGreeting == showGreeting {
            return
        }
        contextHeaderShowsGreeting = showGreeting
        tableView.tableHeaderView = nil
        let header = makeContextHeader(context)
        let width = view.bounds.width
        let widthConstraint = header.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.isActive = true
        let height = header.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        widthConstraint.isActive = false
        header.translatesAutoresizingMaskIntoConstraints = true
        header.frame = CGRect(x: 0, y: 0, width: width, height: max(height, 1))
        tableView.tableHeaderView = header
    }

    private func makeContextHeader(_ context: AIChatLaunchContext) -> UIView {
        let header = UIView()
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        card.layer.cornerRadius = context.isChapterSummary ? 22 : 16
        header.addSubview(card)

        let iconHolder = UIView()
        iconHolder.translatesAutoresizingMaskIntoConstraints = false
        iconHolder.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.12) : themeColor.withAlphaComponent(0.12)
        iconHolder.layer.cornerRadius = 16
        card.addSubview(iconHolder)

        let icon = UIImageView(image: UIImage(systemName: "book.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = isNight ? .white : themeColor
        icon.contentMode = .scaleAspectFit
        iconHolder.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = context.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = isNight ? .white : themeColor
        titleLabel.numberOfLines = 2
        card.addSubview(titleLabel)

        if context.isChapterSummary {
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
                card.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(lessThanOrEqualTo: header.trailingAnchor, constant: -16),

                iconHolder.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
                iconHolder.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
                iconHolder.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
                iconHolder.widthAnchor.constraint(equalToConstant: 32),
                iconHolder.heightAnchor.constraint(equalToConstant: 32),

                icon.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                titleLabel.leadingAnchor.constraint(equalTo: iconHolder.trailingAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])

            if contextHeaderShowsGreeting == true {
                let avatar = UIView()
                avatar.translatesAutoresizingMaskIntoConstraints = false
                avatar.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.12) : themeColor.withAlphaComponent(0.12)
                avatar.layer.cornerRadius = 16
                header.addSubview(avatar)

                let spark = UIImageView(image: UIImage(systemName: "sparkles"))
                spark.translatesAutoresizingMaskIntoConstraints = false
                spark.tintColor = isNight ? .white : themeColor
                avatar.addSubview(spark)

                let bubble = UIView()
                bubble.translatesAutoresizingMaskIntoConstraints = false
                bubble.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.1) : .white
                bubble.layer.cornerRadius = 16
                header.addSubview(bubble)

                let greeting = UILabel()
                greeting.translatesAutoresizingMaskIntoConstraints = false
                let name = passageName(from: context.title)
                greeting.text = usesIndonesian
                    ? "Saya siap membantu Anda memahami \(name).\nApa yang ingin Anda ketahui?"
                    : "I'm ready to help you understand \(name).\nWhat would you like to know?"
                greeting.numberOfLines = 0
                greeting.font = UIFont.systemFont(ofSize: 16)
                greeting.textColor = isNight ? .white : .black
                bubble.addSubview(greeting)

                NSLayoutConstraint.activate([
                    avatar.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
                    avatar.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 16),
                    avatar.widthAnchor.constraint(equalToConstant: 32),
                    avatar.heightAnchor.constraint(equalToConstant: 32),

                    spark.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
                    spark.centerYAnchor.constraint(equalTo: avatar.centerYAnchor),
                    spark.widthAnchor.constraint(equalToConstant: 16),
                    spark.heightAnchor.constraint(equalToConstant: 16),

                    bubble.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
                    bubble.topAnchor.constraint(equalTo: avatar.topAnchor),
                    bubble.trailingAnchor.constraint(lessThanOrEqualTo: header.trailingAnchor, constant: -24),
                    bubble.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),

                    greeting.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
                    greeting.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
                    greeting.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14),
                    greeting.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12)
                ])
            } else {
                card.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8).isActive = true
            }
        } else {
            let subtitle = UILabel()
            subtitle.translatesAutoresizingMaskIntoConstraints = false
            subtitle.text = "Verse Explanation"
            subtitle.font = UIFont.systemFont(ofSize: 13)
            subtitle.textColor = isNight ? UIColor.white.withAlphaComponent(0.6) : UIColor.darkGray
            card.addSubview(subtitle)

            let quote = UILabel()
            quote.translatesAutoresizingMaskIntoConstraints = false
            quote.text = context.verseText
            quote.numberOfLines = 0
            quote.font = UIFont.systemFont(ofSize: 16)
            quote.textColor = isNight ? UIColor.white.withAlphaComponent(0.92) : UIColor(red: 0.16, green: 0.2, blue: 0.32, alpha: 1)
            card.addSubview(quote)

            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = isNight ? .white : themeColor
            bar.layer.cornerRadius = 2
            card.addSubview(bar)

            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
                card.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),

                iconHolder.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                iconHolder.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                iconHolder.widthAnchor.constraint(equalToConstant: 32),
                iconHolder.heightAnchor.constraint(equalToConstant: 32),

                icon.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                titleLabel.leadingAnchor.constraint(equalTo: iconHolder.trailingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                titleLabel.topAnchor.constraint(equalTo: iconHolder.topAnchor, constant: -2),

                subtitle.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitle.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

                bar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                bar.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 12),
                bar.bottomAnchor.constraint(equalTo: quote.bottomAnchor),
                bar.widthAnchor.constraint(equalToConstant: 4),

                quote.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
                quote.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                quote.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 12),
                quote.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

                card.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
            ])
        }

        return header
    }

    private func starterSuggestions() -> [String] {
        if let context = launchContext {
            return contextSuggestions(for: context)
        }
        let pool = usesIndonesian
            ? [
                "Jelaskan Yohanes 3:16",
                "Apa itu kasih karunia?",
                "Bantu saya mempelajari Mazmur",
                "Bagaimana saya bisa bertumbuh dalam iman?",
                "Apa arti Roma 8:28?",
                "Sarankan ayat untuk kecemasan"
            ]
            : [
                "Explain John 3:16",
                "What is grace?",
                "Help me study Psalms",
                "How can I grow in faith?",
                "What does Romans 8:28 mean?",
                "Suggest a verse for anxiety"
            ]
        return Array(pool.shuffled().prefix(3))
    }

    private func makeFollowUpSuggestions(userText: String, assistantText: String) -> [String] {
        let combined = userText + "\n" + assistantText
        let lowered = combined.lowercased()
        let id = usesIndonesian
        var pool: [String] = []

        if let verse = firstVerseReference(in: combined) {
            pool.append(contentsOf: id
                ? [
                    "Jelaskan \(verse) dengan kata-kata sederhana",
                    "Apa pesan utama dari \(verse)?",
                    "Tunjukkan ayat-ayat terkait \(verse)",
                    "Bagaimana \(verse) diterapkan dalam kehidupan sehari-hari?",
                    "Siapa yang berbicara dalam \(verse)?"
                ]
                : [
                    "Explain \(verse) in simple words",
                    "What is the main message of \(verse)?",
                    "Show verses related to \(verse)",
                    "How does \(verse) apply to daily life?",
                    "Who is speaking in \(verse)?"
                ])
        }

        if lowered.contains("grace") || lowered.contains("kasih karunia") {
            pool.append(contentsOf: id
                ? [
                    "Di mana lagi kasih karunia diajarkan?",
                    "Apa bedanya kasih karunia dan belas kasihan?",
                    "Berikan doa singkat tentang kasih karunia"
                ]
                : [
                    "Where else is grace taught?",
                    "How is grace different from mercy?",
                    "Give a short prayer about grace"
                ])
        }

        if lowered.contains("psalm") || lowered.contains("mazmur") {
            pool.append(contentsOf: id
                ? [
                    "Bantu saya mempelajari Mazmur 23",
                    "Apa yang membuat Mazmur istimewa?",
                    "Sarankan Mazmur yang menghibur"
                ]
                : [
                    "Help me study Psalm 23",
                    "What makes Psalms special?",
                    "Suggest a comforting Psalm"
                ])
        }

        if lowered.contains("pray") || lowered.contains("prayer") || lowered.contains("doa") {
            pool.append(contentsOf: id
                ? [
                    "Tuliskan doa singkat dari ini",
                    "Bagaimana saya berdoa tentang ini?",
                    "Berikan doa untuk hari ini"
                ]
                : [
                    "Write a short prayer from this",
                    "How should I pray about this?",
                    "Give me a prayer for today"
                ])
        }

        if lowered.contains("faith") || lowered.contains("iman") {
            pool.append(contentsOf: id
                ? [
                    "Bagaimana saya memperkuat iman saya?",
                    "Tunjukkan ayat tentang percaya kepada Tuhan",
                    "Seperti apa iman dalam praktik sehari-hari?"
                ]
                : [
                    "How can I strengthen my faith?",
                    "Show verses about trusting God",
                    "What does faith look like in practice?"
                ])
        }

        if lowered.contains("love") || lowered.contains("kasih") {
            pool.append(contentsOf: id
                ? [
                    "Di mana Alkitab mendefinisikan kasih?",
                    "Bagaimana saya bisa lebih mengasihi orang lain?",
                    "Tunjukkan ayat tentang kasih Tuhan"
                ]
                : [
                    "Where does the Bible define love?",
                    "How can I love others better?",
                    "Show verses about God's love"
                ])
        }

        pool.append(contentsOf: id
            ? [
                "Sampaikan ini dengan kata-kata yang lebih sederhana",
                "Berikan ayat Alkitab yang terkait",
                "Bagaimana saya dapat menerapkannya hari ini?",
                "Apa poin utamanya di sini?",
                "Bandingkan ini dengan bagian lain",
                "Bantu saya mengingat gagasan utamanya"
            ]
            : [
                "Put this in simpler words",
                "Give related Bible verses",
                "How can I apply this today?",
                "What is the key takeaway here?",
                "Compare this with another passage",
                "Help me memorize the main idea"
            ])

        var unique: [String] = []
        for chip in pool.shuffled() {
            if !unique.contains(where: { $0.caseInsensitiveCompare(chip) == .orderedSame }) {
                unique.append(chip)
            }
            if unique.count == 3 { break }
        }
        return unique
    }

    private func firstVerseReference(in text: String) -> String? {
        // Strip common prompt verbs so "Explain John 3:16" / "Jelaskan Yohanes 3:16" does not become the verse string.
        let cleaned = text.replacingOccurrences(
            of: #"(?i)\b(explain|show|help|tell|give|about|study|jelaskan|tunjukkan|bantu|beri|tentang|pelajari|apa|arti)\b"#,
            with: " ",
            options: .regularExpression
        )
        let pattern = #"\b(?:[1-3]\s)?[A-Za-zÀ-ÿ]+(?:\s[A-Za-zÀ-ÿ]+)?\s+\d{1,3}:\d{1,3}\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(cleaned.startIndex..., in: cleaned)
        guard let match = regex.firstMatch(in: cleaned, range: range),
              let swiftRange = Range(match.range, in: cleaned) else {
            return nil
        }
        return String(cleaned[swiftRange])
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        // Ignore keyboard churn while share sheet (or any modal) is up — avoids stack/jump on return.
        guard presentedViewController == nil else { return }

        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let converted = view.convert(frame, from: nil)
        // Keyboards from the screenshot editor / share extensions must not move the chat composer.
        let ownsKeyboard = inputTextView.isFirstResponder && UIApplication.shared.applicationState == .active
        let overlap = ownsKeyboard ? min(max(0, view.bounds.maxY - converted.minY), view.bounds.height / 2 + 100) : 0
        composerBottomConstraint?.constant = -overlap

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom(animated: false)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        inputTextView.text = title
        placeholderLabel.isHidden = true
        sendTapped()
    }

    @objc private func sendTapped() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        if !NetworkManager.sharedInstance.isConnectedToInternet() {
            // Bottom toasts sit behind the keyboard and show only as a gray box.
            view.makeToast("No internet connection", duration: 2.0, position: .top)
            return
        }

        if isOutOfFreeChatsAndCredits {
            showLimitCard()
            return
        }

        AIUsageLimiter.shared.requestAccess(.aiChat, from: self) { [weak self] in
            self?.sendMessage(text)
        }
    }

    private func sendMessage(_ text: String) {
        guard !isSending else { return }
        messages.append(AIChatMessage(role: .user, text: text))
        inputTextView.text = ""
        placeholderLabel.isHidden = false
        refreshInputHeight()
        emptyStateView.isHidden = true
        isSending = true
        refreshSendButtonState()
        refreshFollowUpSuggestions()
        reloadChatAndScrollToBottom(animated: true)
        // Keep keyboard/composer frame stable while the reply loads (avoids screen jump).

        let payload = buildInput(for: text)
        OpenAIChatService.shared.send(input: payload) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let reply):
                AIUsageLimiter.shared.commit(.aiChat)
                self.refreshSendLock()
                self.appendAssistantReply(reply, userText: text)
            case .failure(let error):
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .top)
                self.finishSending()
            }
        }
    }

    private func appendAssistantReply(_ reply: String, userText: String) {
        let parsed = AIChatAnswer.parse(reply)
        var followUps = parsed.followUps
        if followUps.isEmpty {
            followUps = Array(makeFollowUpSuggestions(userText: userText, assistantText: parsed.plainText).prefix(2))
        }

        guard var answer = parsed.answer, let reference = answer.reference else {
            messages.append(AIChatMessage(role: .assistant, text: parsed.plainText, answer: parsed.answer, followUps: followUps))
            finishSending()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let bibleText = AIChatScripture.text(for: reference)
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let bibleText = bibleText {
                    answer.verse = bibleText
                }
                self.messages.append(AIChatMessage(role: .assistant, text: answer.plainText, answer: answer, followUps: followUps))
                self.finishSending()
            }
        }
    }

    private func finishSending() {
        isSending = false
        refreshSendButtonState()
        tableView.reloadData()
        refreshFollowUpSuggestions()
        scrollToBottom(animated: true)
    }

    private func ask(_ question: String) {
        inputTextView.text = question
        placeholderLabel.isHidden = true
        sendTapped()
    }

    private func copyText(_ text: String) {
        UIPasteboard.general.string = text
        view.makeToast("Copied", duration: 1.5, position: .top)
    }

    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            // Re-apply composer inset after share dismiss without IQKeyboard fighting the layout.
            guard let self = self else { return }
            self.composerBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
        present(activityVC, animated: true, completion: nil)
    }

    private func reloadChatAndScrollToBottom(animated: Bool) {
        installContextHeaderIfNeeded()
        tableView.reloadData()
        scrollToBottom(animated: animated)
    }

    private func buildInput(for latestUserText: String) -> String {
        var lines: [String] = [
            "You are a helpful Bible study assistant in the \(APPNAME) app. Give clear, faithful, and concise answers. Do not use markdown or asterisks."
        ]

        let bookNames = AIChatScripture.books().map { $0.name }
        let bookRule = bookNames.isEmpty ? "" : " Use one of these book names exactly: \(bookNames.joined(separator: ", "))."
        lines.append("""
        Reply only with these labeled lines, each on its own line:
        LEAD: one short sentence that directly answers the question.
        REF: one Bible reference that best supports the answer, written as Book chapter:verse or Book chapter:verse-verse (at most 4 verses).\(bookRule)
        VERSE: the text of that passage.
        POINT: one short sentence on why it matters.
        POINT: one short sentence on why it matters.
        POINT: one short sentence on why it matters.
        NEXT: a short follow-up question the user may ask next (at most 8 words).
        NEXT: another short follow-up question (at most 8 words).
        Keep the labels LEAD, REF, VERSE, POINT and NEXT in English. Write the text after each label in the same language as the user's question.
        """)

        let history = messages.dropLast()
        if !history.isEmpty {
        if let context = launchContext {
            let kind = context.isChapterSummary ? "chapter summary" : "verse explanation"
            lines.append("The user opened chat from the \(kind) for \(context.title).")
            if let verse = context.verseText, !verse.isEmpty {
                lines.append("Verse text: \(verse)")
            }
            if !context.sourceText.isEmpty {
                lines.append("Text already shown to the user:\n\(context.sourceText)")
            }
            lines.append("Stay on this passage. Answer in the same language as the user's question.")
        }

            lines.append("Conversation so far:")
            for message in history.suffix(8) {
                let speaker = message.role == .user ? "User" : "Assistant"
                lines.append("\(speaker): \(message.text)")
            }
        }

        lines.append("User: \(latestUserText)")
        return lines.joined(separator: "\n")
    }

    private func refreshInputHeight() {
        let size = inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let height = min(max(size.height, 40), 110)
        inputHeightConstraint?.constant = height
        inputTextView.isScrollEnabled = size.height > 110
    }

    private func scrollToBottom(animated: Bool) {
        let performScroll = { [weak self] (shouldAnimate: Bool) in
            guard let self = self else { return }
            let rowCount = self.tableView.numberOfRows(inSection: 0)
            guard rowCount > 0 else { return }

            // Layout only the table so the chat shell/background does not reflow/jump.
            self.tableView.layoutIfNeeded()

            let indexPath = IndexPath(row: rowCount - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: shouldAnimate)
        }

        performScroll(animated)
        DispatchQueue.main.async {
            performScroll(false)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        refreshInputHeight()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (isSending ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= messages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AIChatWaitingCell.reuseId, for: indexPath) as! AIChatWaitingCell
            cell.configure(isNight: isNight, themeColor: themeColor, indonesian: false)
            return cell
        }

        let message = messages[indexPath.row]
        if message.role == .assistant {
            let cell = tableView.dequeueReusableCell(withIdentifier: AIChatAnswerCell.reuseId, for: indexPath) as! AIChatAnswerCell
            cell.configure(message: message, isNight: isNight, themeColor: themeColor, indonesian: false)
            cell.onCopy = { [weak self] text in self?.copyText(text) }
            cell.onShare = { [weak self] text in self?.shareText(text) }
            cell.onAsk = { [weak self] question in self?.ask(question) }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: AIChatBubbleCell.reuseId, for: indexPath) as! AIChatBubbleCell
        cell.configure(message: message, isNight: isNight, themeColor: themeColor)
        cell.onCopy = { [weak self] text in self?.copyText(text) }
        cell.onShare = { [weak self] text in self?.shareText(text) }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < messages.count, indexPath.row >= animatedRowCount else { return }
        animatedRowCount = indexPath.row + 1
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        cell.contentView.alpha = 0
        cell.contentView.transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.34, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            cell.contentView.alpha = 1
            cell.contentView.transform = .identity
        }
    }
}

/// "Exploring Scripture..." label with a dot, shared by the waiting row and the answer.
private func makeAIChatTag(accent: UIColor, indonesian: Bool) -> UIView {
    let dot = UIView()
    dot.translatesAutoresizingMaskIntoConstraints = false
    dot.backgroundColor = accent
    dot.layer.cornerRadius = 3
    let label = UILabel()
    label.attributedText = NSAttributedString(string: indonesian ? "Menjelajahi Kitab Suci..." : "Exploring Scripture...", attributes: [
        .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
        .kern: 1.4,
        .foregroundColor: accent
    ])
    let row = UIStackView(arrangedSubviews: [dot, label])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 7
    NSLayoutConstraint.activate([
        dot.widthAnchor.constraint(equalToConstant: 6),
        dot.heightAnchor.constraint(equalToConstant: 6)
    ])
    return row
}

/// "Exploring Scripture..." label with three bouncing dots while a reply loads.
private final class AIChatWaitingCell: UITableViewCell {
    static let reuseId = "AIChatWaitingCell"

    private let stack = UIStackView()
    private let dotsStack = UIStackView()
    private var dots: [UIView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        contentView.addSubview(stack)

        dotsStack.axis = .horizontal
        dotsStack.spacing = 5
        for _ in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 3.5
            dot.widthAnchor.constraint(equalToConstant: 7).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 7).isActive = true
            dots.append(dot)
            dotsStack.addArrangedSubview(dot)
        }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isNight: Bool, themeColor: UIColor, indonesian: Bool) {
        let accent = isNight ? UIColor.white : themeColor
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stack.addArrangedSubview(makeAIChatTag(accent: accent, indonesian: indonesian))
        stack.addArrangedSubview(dotsStack)
        dots.forEach { $0.backgroundColor = accent }
        startBouncing()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { startBouncing() }
    }

    private func startBouncing() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            dots.forEach { $0.alpha = 0.6 }
            return
        }
        for (index, dot) in dots.enumerated() {
            dot.layer.removeAllAnimations()
            let move = CAKeyframeAnimation(keyPath: "transform.translation.y")
            move.values = [0, -4, 0, 0]
            let fade = CAKeyframeAnimation(keyPath: "opacity")
            fade.values = [0.35, 1, 0.35, 0.35]
            let group = CAAnimationGroup()
            group.animations = [move, fade]
            [move, fade].forEach { $0.keyTimes = [0, 0.3, 0.6, 1] }
            group.duration = 1.2
            group.repeatCount = .infinity
            group.beginTime = CACurrentMediaTime() + Double(index) * 0.15
            dot.layer.add(group, forKey: "bounce")
        }
    }
}

/// Assistant answer laid out as: tag, lead, the passage, why it matters, Copy/Share, continue chips.
private final class AIChatAnswerCell: UITableViewCell {
    static let reuseId = "AIChatAnswerCell"

    var onCopy: ((String) -> Void)?
    var onShare: ((String) -> Void)?
    var onAsk: ((String) -> Void)?

    private let stack = UIStackView()
    private var messageText = ""
    private var accent = UIColor.black
    private var hair = UIColor.lightGray
    private var ink = UIColor.black

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: AIChatMessage, isNight: Bool, themeColor: UIColor, indonesian: Bool) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        messageText = message.text
        accent = isNight ? .white : themeColor
        ink = isNight ? .white : UIColor(red: 0.086, green: 0.1, blue: 0.13, alpha: 1)
        let ink2 = isNight ? UIColor.white.withAlphaComponent(0.75) : UIColor(red: 0.27, green: 0.31, blue: 0.37, alpha: 1)
        let ink3 = isNight ? UIColor.white.withAlphaComponent(0.5) : UIColor(red: 0.55, green: 0.58, blue: 0.63, alpha: 1)
        hair = isNight ? UIColor.white.withAlphaComponent(0.14) : UIColor(red: 0.9, green: 0.915, blue: 0.94, alpha: 1)

        let tag = makeAIChatTag(accent: accent, indonesian: indonesian)
        let tagRow = UIStackView(arrangedSubviews: [tag, UIView()])
        stack.addArrangedSubview(tagRow)
        stack.setCustomSpacing(10, after: tagRow)

        if let answer = message.answer {
            let lead = makeLabel(answer.lead, font: .systemFont(ofSize: 17, weight: .semibold), color: ink, lineSpacing: 3)
            stack.addArrangedSubview(lead)
            stack.setCustomSpacing(20, after: lead)

            if let verse = answer.verse, !verse.isEmpty {
                let rule = makeRule(indonesian ? "AYAT" : "THE PASSAGE", color: accent)
                stack.addArrangedSubview(rule)
                stack.setCustomSpacing(12, after: rule)
                let quote = makeQuote(verse: verse, reference: answer.reference, citeColor: ink3)
                stack.addArrangedSubview(quote)
                stack.setCustomSpacing(20, after: quote)
            }

            let rule = makeRule(indonesian ? "MENGAPA INI PENTING" : "WHY IT MATTERS", color: accent)
            stack.addArrangedSubview(rule)
            stack.setCustomSpacing(12, after: rule)
            for (index, point) in answer.points.enumerated() {
                let row = makePoint(point, color: ink2)
                stack.addArrangedSubview(row)
                stack.setCustomSpacing(index == answer.points.count - 1 ? 16 : 10, after: row)
            }
        } else {
            let body = makeLabel(message.text, font: .systemFont(ofSize: 16), color: ink, lineSpacing: 4)
            stack.addArrangedSubview(body)
            stack.setCustomSpacing(16, after: body)
        }

        let actions = UIStackView(arrangedSubviews: [
            makeQuietButton(indonesian ? "Salin" : "Copy", symbol: "doc.on.doc", color: ink3, action: #selector(copyTapped)),
            makeQuietButton(indonesian ? "Bagikan" : "Share", symbol: "square.and.arrow.up", color: ink3, action: #selector(shareTapped)),
            UIView()
        ])
        actions.axis = .horizontal
        actions.alignment = .center
        actions.spacing = 20
        stack.addArrangedSubview(actions)
        // CONTINUE chips are shown above the composer, not under the answer.
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor, lineSpacing: CGFloat) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ])
        return label
    }

    private func makeRule(_ title: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: title, attributes: [
            .font: UIFont.systemFont(ofSize: 10.5, weight: .bold),
            .kern: 1.3,
            .foregroundColor: color
        ])
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = hair
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let row = UIStackView(arrangedSubviews: [label, line])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        return row
    }

    private func makeQuote(verse: String, reference: String?, citeColor: UIColor) -> UIView {
        let container = UIView()
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = accent
        bar.layer.cornerRadius = 1.25
        container.addSubview(bar)

        let serifDescriptor = UIFont.systemFont(ofSize: 17).fontDescriptor.withDesign(.serif)
        let serif = serifDescriptor.map { UIFont(descriptor: $0, size: 17) } ?? UIFont.systemFont(ofSize: 17)
        let verseLabel = makeLabel(verse, font: serif, color: ink, lineSpacing: 5)
        let textStack = UIStackView(arrangedSubviews: [verseLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 8
        if let reference = reference, !reference.isEmpty {
            let cite = UILabel()
            cite.numberOfLines = 0
            cite.attributedText = NSAttributedString(string: reference.uppercased(), attributes: [
                .font: UIFont.systemFont(ofSize: 10.5, weight: .semibold),
                .kern: 1.0,
                .foregroundColor: citeColor
            ])
            textStack.addArrangedSubview(cite)
        }
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            bar.widthAnchor.constraint(equalToConstant: 2.5),

            textStack.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: container.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makePoint(_ text: String, color: UIColor) -> UIView {
        let container = UIView()
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = accent.withAlphaComponent(0.55)
        dot.layer.cornerRadius = 2.5
        container.addSubview(dot)

        let label = makeLabel(text, font: .systemFont(ofSize: 15), color: color, lineSpacing: 3)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 1),
            dot.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            dot.widthAnchor.constraint(equalToConstant: 5),
            dot.heightAnchor.constraint(equalToConstant: 5),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeQuietButton(_ title: String, symbol: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        button.tintColor = color
        button.setTitleColor(color, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 6)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeChipRow(_ titles: [String], isNight: Bool) -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.spacing = 8
        scroll.addSubview(row)

        titles.forEach { title in
            let chip = UIButton(type: .custom)
            chip.setTitle(title, for: .normal)
            chip.titleLabel?.font = UIFont.systemFont(ofSize: 13.5, weight: .medium)
            chip.setTitleColor(ink, for: .normal)
            chip.setTitleColor(accent, for: .highlighted)
            chip.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
            chip.layer.cornerRadius = 19
            chip.layer.borderWidth = 1
            chip.layer.borderColor = hair.cgColor
            chip.contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)
            chip.addTarget(self, action: #selector(chipTouchDown(_:)), for: [.touchDown, .touchDragEnter])
            chip.addTarget(self, action: #selector(chipTouchEnded(_:)), for: [.touchUpOutside, .touchCancel, .touchDragExit])
            chip.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            row.addArrangedSubview(chip)
        }

        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 38)
        ])
        return scroll
    }

    @objc private func chipTouchDown(_ sender: UIButton) {
        sender.layer.borderColor = accent.cgColor
    }

    @objc private func chipTouchEnded(_ sender: UIButton) {
        sender.layer.borderColor = hair.cgColor
    }

    @objc private func chipTapped(_ sender: UIButton) {
        sender.layer.borderColor = hair.cgColor
        guard let title = sender.title(for: .normal) else { return }
        onAsk?(title)
    }

    @objc private func copyTapped() {
        onCopy?(messageText)
    }

    @objc private func shareTapped() {
        onShare?(messageText)
    }
}

private final class AIChatBubbleCell: UITableViewCell {
    static let reuseId = "AIChatBubbleCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let actionStack = UIStackView()
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var messageLabelBottomConstraint: NSLayoutConstraint?
    private var messageLabelTrailingConstraint: NSLayoutConstraint?

    var onCopy: ((String) -> Void)?
    var onShare: ((String) -> Void)?
    private var currentMessageText: String = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        bubbleView.addSubview(messageLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.tintColor = .white
        copyButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        copyButton.layer.cornerRadius = 14
        copyButton.contentEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        shareButton.layer.cornerRadius = 14
        shareButton.contentEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.spacing = 8
        actionStack.alignment = .center
        actionStack.distribution = .fill
        actionStack.addArrangedSubview(copyButton)
        actionStack.addArrangedSubview(shareButton)
        bubbleView.addSubview(actionStack)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            {
                let c = messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14)
                messageLabelTrailingConstraint = c
                return c
            }(),
            {
                let c = messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
                messageLabelBottomConstraint = c
                return c
            }(),

            actionStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            actionStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            copyButton.widthAnchor.constraint(equalToConstant: 28),
            copyButton.heightAnchor.constraint(equalToConstant: 28),
            shareButton.widthAnchor.constraint(equalToConstant: 28),
            shareButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        actionStack.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: AIChatMessage, isNight: Bool, themeColor: UIColor) {
        currentMessageText = message.text
        messageLabel.text = message.text
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false

        if message.role == .user {
            bubbleView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.12) : themeColor.withAlphaComponent(0.1)
            messageLabel.textColor = isNight ? .white : UIColor(red: 0.086, green: 0.1, blue: 0.13, alpha: 1)
            bubbleView.layer.cornerRadius = 20
            trailingConstraint?.isActive = true
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            actionStack.isHidden = true
            messageLabelBottomConstraint?.constant = -10
            messageLabelTrailingConstraint?.constant = -14
        } else {
            bubbleView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.1) : .white
            messageLabel.textColor = isNight ? .white : .black
            leadingConstraint?.isActive = true
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
            actionStack.isHidden = false
            messageLabelBottomConstraint?.constant = -42
            messageLabelTrailingConstraint?.constant = -52
        }
    }

    @objc private func copyTapped() {
        onCopy?(currentMessageText)
    }

    @objc private func shareTapped() {
        onShare?(currentMessageText)
    }
}
