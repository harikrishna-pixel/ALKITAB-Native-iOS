//
//  AIChatViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

private struct AIChatMessage {
    enum Role {
        case user
        case assistant
    }

    let role: Role
    let text: String
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
    private let sendButton = UIButton(type: .system)
    private let typingLabel = UILabel()

    private var bannerHeightConstraint: NSLayoutConstraint?
    private var composerBottomConstraint: NSLayoutConstraint?
    private var inputHeightConstraint: NSLayoutConstraint?

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App_Protocol.delegateReader?.hideBottomMenu(Status: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = isNight ? DarkModeColor : themeColor
        view.addSubview(bannerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "AI Chat"
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
        tableView.register(AIChatBubbleCell.self, forCellReuseIdentifier: AIChatBubbleCell.reuseId)
        tableView.register(AIChatTypingCell.self, forCellReuseIdentifier: AIChatTypingCell.reuseId)
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

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendImage = UIImage(systemName: "arrow.up.circle.fill")
        sendButton.setImage(sendImage, for: .normal)
        sendButton.tintColor = isNight ? .white : themeColor
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        composerContainer.addSubview(sendButton)

        typingLabel.translatesAutoresizingMaskIntoConstraints = false
        typingLabel.text = "AI is thinking..."
        typingLabel.font = UIFont.systemFont(ofSize: 12)
        typingLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.6) : .darkGray
        typingLabel.isHidden = true
        composerContainer.addSubview(typingLabel)

        setupEmptyState()

        let bannerHeight: CGFloat = StatusbarHeight > 30 ? 90 : 70
        bannerHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: bannerHeight)
        composerBottomConstraint = composerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 40)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerHeightConstraint!,

            titleLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -15),

            backImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
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

            typingLabel.topAnchor.constraint(equalTo: composerContainer.topAnchor, constant: 8),
            typingLabel.leadingAnchor.constraint(equalTo: composerContainer.leadingAnchor, constant: 20),

            inputTextView.topAnchor.constraint(equalTo: typingLabel.bottomAnchor, constant: 6),
            inputTextView.leadingAnchor.constraint(equalTo: composerContainer.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextView.bottomAnchor.constraint(equalTo: composerContainer.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inputHeightConstraint!,

            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 16),

            sendButton.trailingAnchor.constraint(equalTo: composerContainer.trailingAnchor, constant: -12),
            sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: suggestionContainer.topAnchor),

            suggestionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionContainer.bottomAnchor.constraint(equalTo: composerContainer.topAnchor),

            suggestionStack.topAnchor.constraint(equalTo: suggestionContainer.topAnchor, constant: 8),
            suggestionStack.leadingAnchor.constraint(equalTo: suggestionContainer.leadingAnchor, constant: 16),
            suggestionStack.trailingAnchor.constraint(lessThanOrEqualTo: suggestionContainer.trailingAnchor, constant: -16),
            suggestionStack.bottomAnchor.constraint(equalTo: suggestionContainer.bottomAnchor, constant: -8),

            emptyStateView.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: suggestionContainer.topAnchor)
        ])

        refreshFollowUpSuggestions()
        view.bringSubviewToFront(suggestionContainer)
        view.bringSubviewToFront(composerContainer)
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

    private func refreshFollowUpSuggestions() {
        suggestionStack.arrangedSubviews.forEach {
            suggestionStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !isSending else {
            suggestionContainer.isHidden = true
            return
        }

        let chips: [String]
        if let lastAssistant = messages.last(where: { $0.role == .assistant }),
           let lastUser = messages.last(where: { $0.role == .user }) {
            chips = makeFollowUpSuggestions(userText: lastUser.text, assistantText: lastAssistant.text)
        } else if messages.isEmpty {
            chips = starterSuggestions()
        } else {
            chips = []
        }

        chips.forEach { title in
            suggestionStack.addArrangedSubview(makeSuggestionChip(title: title))
        }
        suggestionContainer.isHidden = chips.isEmpty
    }

    private func starterSuggestions() -> [String] {
        let pool = [
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
        var pool: [String] = []

        if let verse = firstVerseReference(in: combined) {
            pool.append(contentsOf: [
                "Explain \(verse) in simple words",
                "What is the main message of \(verse)?",
                "Show verses related to \(verse)",
                "How does \(verse) apply to daily life?",
                "Who is speaking in \(verse)?"
            ])
        }

        if lowered.contains("grace") || lowered.contains("kasih karunia") {
            pool.append(contentsOf: [
                "Where else is grace taught?",
                "How is grace different from mercy?",
                "Give a short prayer about grace"
            ])
        }

        if lowered.contains("psalm") || lowered.contains("mazmur") {
            pool.append(contentsOf: [
                "Help me study Psalm 23",
                "What makes Psalms special?",
                "Suggest a comforting Psalm"
            ])
        }

        if lowered.contains("pray") || lowered.contains("prayer") || lowered.contains("doa") {
            pool.append(contentsOf: [
                "Write a short prayer from this",
                "How should I pray about this?",
                "Give me a prayer for today"
            ])
        }

        if lowered.contains("faith") || lowered.contains("iman") {
            pool.append(contentsOf: [
                "How can I strengthen my faith?",
                "Show verses about trusting God",
                "What does faith look like in practice?"
            ])
        }

        if lowered.contains("love") || lowered.contains("kasih") {
            pool.append(contentsOf: [
                "Where does the Bible define love?",
                "How can I love others better?",
                "Show verses about God's love"
            ])
        }

        pool.append(contentsOf: [
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
        // Strip common prompt verbs so "Explain John 3:16" does not become the verse string.
        let cleaned = text.replacingOccurrences(
            of: #"(?i)\b(explain|show|help|tell|give|about|study)\b"#,
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
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let converted = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - converted.minY)
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
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }

        messages.append(AIChatMessage(role: .user, text: text))
        inputTextView.text = ""
        placeholderLabel.isHidden = false
        refreshInputHeight()
        emptyStateView.isHidden = true
        isSending = true
        typingLabel.isHidden = false
        refreshFollowUpSuggestions()
        tableView.reloadData()
        scrollToBottom(animated: true)
        view.endEditing(false)

        let payload = buildInput(for: text)
        OpenAIChatService.shared.send(input: payload) { [weak self] result in
            guard let self = self else { return }
            self.isSending = false
            self.typingLabel.isHidden = true

            switch result {
            case .success(let reply):
                self.messages.append(AIChatMessage(role: .assistant, text: reply))
            case .failure(let error):
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
            }
            self.tableView.reloadData()
            self.refreshFollowUpSuggestions()
            self.scrollToBottom(animated: true)
        }
    }

    private func buildInput(for latestUserText: String) -> String {
        var lines: [String] = [
            "You are a helpful Bible study assistant in the \(APPNAME) app. Give clear, faithful, and concise answers. Do not use markdown or asterisks."
        ]

        let history = messages.dropLast()
        if !history.isEmpty {
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
        let rowCount = tableView.numberOfRows(inSection: 0)
        guard rowCount > 0 else { return }
        let indexPath = IndexPath(row: rowCount - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: AIChatTypingCell.reuseId, for: indexPath) as! AIChatTypingCell
            cell.configure(isNight: isNight, themeColor: themeColor)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: AIChatBubbleCell.reuseId, for: indexPath) as! AIChatBubbleCell
        cell.configure(message: messages[indexPath.row], isNight: isNight, themeColor: themeColor)
        cell.onCopy = { [weak self] text in
            guard let self = self else { return }
            UIPasteboard.general.string = text
            self.view.makeToast("Copied", duration: 1.5, position: .bottom)
        }
        cell.onShare = { [weak self] text in
            guard let self = self else { return }
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            self.present(activityVC, animated: true, completion: nil)
        }
        return cell
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
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.78),

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
            bubbleView.backgroundColor = isNight ? DarkModeColor : themeColor
            messageLabel.textColor = .white
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

private final class AIChatTypingCell: UITableViewCell {
    static let reuseId = "AIChatTypingCell"

    private let bubbleView = UIView()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        contentView.addSubview(bubbleView)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Typing..."
        label.font = UIFont.italicSystemFont(ofSize: 14)
        bubbleView.addSubview(label)

        NSLayoutConstraint.activate([
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isNight: Bool, themeColor: UIColor) {
        bubbleView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.1) : .white
        label.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .gray
    }
}
