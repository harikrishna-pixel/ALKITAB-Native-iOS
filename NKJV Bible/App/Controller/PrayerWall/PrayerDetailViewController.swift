//
//  PrayerDetailViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

final class PrayerDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var onUpdated: (() -> Void)?

    private let prayer: PrayerWallItem
    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool

    private var comments: [PrayerWallComment] = []
    private var likeCount = 0
    private var isLiked = false
    private var isSubmittingComment = false

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private let blockButton = UIButton(type: .system)
    private let commentsTitleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let commentField = UITextField()
    private let sendCommentButton = UIButton(type: .system)
    private var tableHeightConstraint: NSLayoutConstraint?
    private var isBlocking = false

    init(prayer: PrayerWallItem) {
        self.prayer = prayer
        self.isNight = (UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor) == BGNightMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Prayer"
        view.backgroundColor = isNight ? BGNightMode : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        setupNavigation()
        setupUI()
        populatePrayer()
        loadEngagement()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = isNight ? .white : themeColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = isNight ? DarkModeColor : themeColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        contentView.addSubview(cardView)

        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)

        [categoryLabel, titleLabel, descriptionLabel, authorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.layer.cornerRadius = 10
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        cardView.addSubview(likeButton)

        blockButton.translatesAutoresizingMaskIntoConstraints = false
        blockButton.layer.cornerRadius = 10
        blockButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        blockButton.addTarget(self, action: #selector(blockTapped), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            blockButton.setImage(UIImage(systemName: "hand.raised.fill"), for: .normal)
        }
        cardView.addSubview(blockButton)

        commentsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsTitleLabel.text = "Comments"
        commentsTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        commentsTitleLabel.textColor = isNight ? .white : .black
        contentView.addSubview(commentsTitleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PrayerCommentCell.self, forCellReuseIdentifier: PrayerCommentCell.reuseId)
        contentView.addSubview(tableView)

        commentField.translatesAutoresizingMaskIntoConstraints = false
        commentField.placeholder = "Write a comment..."
        commentField.borderStyle = .roundedRect
        commentField.delegate = self
        commentField.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        commentField.textColor = isNight ? .white : .black
        contentView.addSubview(commentField)

        sendCommentButton.translatesAutoresizingMaskIntoConstraints = false
        sendCommentButton.setTitle("Send", for: .normal)
        sendCommentButton.setTitleColor(.white, for: .normal)
        sendCommentButton.backgroundColor = isNight ? DarkModeColor : themeColor
        sendCommentButton.layer.cornerRadius = 10
        sendCommentButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
        contentView.addSubview(sendCommentButton)

        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 80)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            likeButton.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            likeButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            likeButton.trailingAnchor.constraint(equalTo: blockButton.leadingAnchor, constant: -10),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            blockButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            blockButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            blockButton.widthAnchor.constraint(equalToConstant: 110),
            blockButton.heightAnchor.constraint(equalToConstant: 44),

            commentsTitleLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            commentsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: commentsTitleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableHeightConstraint!,

            commentField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12),
            commentField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentField.trailingAnchor.constraint(equalTo: sendCommentButton.leadingAnchor, constant: -8),
            commentField.heightAnchor.constraint(equalToConstant: 44),

            sendCommentButton.centerYAnchor.constraint(equalTo: commentField.centerYAnchor),
            sendCommentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sendCommentButton.widthAnchor.constraint(equalToConstant: 72),
            sendCommentButton.heightAnchor.constraint(equalToConstant: 44),
            sendCommentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func populatePrayer() {
        categoryLabel.text = prayer.category.uppercased()
        categoryLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.75) : themeColor
        titleLabel.text = prayer.title
        titleLabel.textColor = isNight ? .white : .black
        descriptionLabel.text = prayer.description
        descriptionLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.9) : .darkGray
        let author = prayer.isAnonymous || prayer.userName.isEmpty ? "Anonymous" : prayer.userName
        authorLabel.text = "Shared by \(author)"
        authorLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.65) : .gray
        updateLikeButton()
        updateBlockButton()
    }

    private func updateBlockButton() {
        let blocked = PrayerWallService.shared.isUserBlocked(prayer.blockTargetId)
        let title = blocked ? " Unblock" : " Block"
        blockButton.setTitle(title, for: .normal)
        if blocked {
            blockButton.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.15) : UIColor.systemOrange.withAlphaComponent(0.15)
            blockButton.setTitleColor(isNight ? .white : .systemOrange, for: .normal)
            blockButton.tintColor = isNight ? .white : .systemOrange
        } else {
            blockButton.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.12) : UIColor.systemRed.withAlphaComponent(0.12)
            blockButton.setTitleColor(isNight ? .white : .systemRed, for: .normal)
            blockButton.tintColor = isNight ? .white : .systemRed
        }
    }

    private func loadEngagement() {
        isLiked = PrayerWallService.shared.isPrayerLiked(prayer.id)
        updateLikeButton()

        PrayerWallService.shared.fetchLikes(prayerId: prayer.id) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.likeCount = response.count ?? response.likes?.count ?? 0
                self.updateLikeButton()
            }
        }

        PrayerWallService.shared.fetchComments(prayerId: prayer.id) { [weak self] result in
            guard let self = self else { return }
            if case .success(let items) = result {
                self.comments = items
                self.tableView.reloadData()
                self.updateTableHeight()
            }
        }
    }

    private func updateLikeButton() {
        let title = isLiked ? "Praying (\(likeCount))" : "Pray (\(likeCount))"
        likeButton.setTitle(title, for: .normal)
        likeButton.backgroundColor = isLiked ? (isNight ? UIColor.white.withAlphaComponent(0.2) : themeColor) : (isNight ? DarkModeColor : themeColor.withAlphaComponent(0.15))
        likeButton.setTitleColor(isLiked ? .white : (isNight ? .white : themeColor), for: .normal)
    }

    private func updateTableHeight() {
        tableView.layoutIfNeeded()
        let height = max(60, tableView.contentSize.height)
        tableHeightConstraint?.constant = height
    }

    @objc private func likeTapped() {
        PrayerWallLoginGate.requireLogin(from: self) { [weak self] in
            guard let self = self else { return }
            if !NetworkManager.sharedInstance.isConnectedToInternet() {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                return
            }

            self.likeButton.isEnabled = false
            if self.isLiked {
                PrayerWallService.shared.deleteLike(prayerId: self.prayer.id) { [weak self] result in
                    self?.handleLikeResult(result, liked: false)
                }
            } else {
                PrayerWallService.shared.createLike(prayerId: self.prayer.id) { [weak self] result in
                    self?.handleLikeResult(result, liked: true)
                }
            }
        }
    }

    private func handleLikeResult(_ result: Result<Void, PrayerWallError>, liked: Bool) {
        likeButton.isEnabled = true
        switch result {
        case .success:
            isLiked = liked
            likeCount = max(0, likeCount + (liked ? 1 : -1))
            updateLikeButton()
            onUpdated?()
        case .failure(let error):
            view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
        }
    }

    @objc private func blockTapped() {
        PrayerWallLoginGate.requireLogin(from: self) { [weak self] in
            guard let self = self else { return }
            if !NetworkManager.sharedInstance.isConnectedToInternet() {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                return
            }
            guard !self.isBlocking else { return }

            let targetId = self.prayer.blockTargetId
            guard !targetId.isEmpty else {
                self.view.makeToast("Unable to block this prayer.", duration: 2.0, position: .bottom)
                return
            }
            if let me = PrayerWallService.shared.currentBlockerUserId(), me == targetId {
                self.view.makeToast("You can't block your own prayer.", duration: 2.0, position: .bottom)
                return
            }

            let alreadyBlocked = PrayerWallService.shared.isUserBlocked(targetId)
            let title = alreadyBlocked ? "Unblock" : "Block"
            let message = alreadyBlocked
                ? "Unblock this user so you can see their prayers again?"
                : "Block this user? Their prayers will be hidden from your Prayer Wall."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: title, style: alreadyBlocked ? .default : .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                if !alreadyBlocked {
                    let author = self.prayer.isAnonymous || self.prayer.userName.isEmpty ? "Anonymous" : self.prayer.userName
                    PrayerWallService.shared.rememberBlockedUserDisplayName(author, for: targetId)
                }
                self.performBlockToggle(alreadyBlocked: alreadyBlocked, targetId: targetId)
            }))
            self.present(alert, animated: true)
        }
    }

    private func performBlockToggle(alreadyBlocked: Bool, targetId: String) {
        isBlocking = true
        blockButton.isEnabled = false
        if alreadyBlocked {
            PrayerWallService.shared.unblockUser(blockedUserId: targetId) { [weak self] result in
                self?.handleBlockResult(result, blocked: false)
            }
        } else {
            PrayerWallService.shared.blockUser(blockedUserId: targetId) { [weak self] result in
                self?.handleBlockResult(result, blocked: true)
            }
        }
    }

    private func handleBlockResult(_ result: Result<Void, PrayerWallError>, blocked: Bool) {
        isBlocking = false
        blockButton.isEnabled = true
        switch result {
        case .success:
            updateBlockButton()
            view.makeToast(blocked ? "User blocked" : "User unblocked", duration: 2.0, position: .bottom)
            onUpdated?()
            if blocked {
                navigationController?.popViewController(animated: true)
            }
        case .failure(let error):
            view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
        }
    }

    @objc private func sendCommentTapped() {
        let text = (commentField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.count <= 1000 else {
            view.makeToast("Enter a comment up to 1000 characters.", duration: 2.0, position: .bottom)
            return
        }
        guard !isSubmittingComment else { return }

        PrayerWallLoginGate.requireLogin(from: self) { [weak self] in
            guard let self = self else { return }
            if !NetworkManager.sharedInstance.isConnectedToInternet() {
                self.view.makeToast("No internet connection", duration: 2.0, position: .bottom)
                return
            }

            self.isSubmittingComment = true
            self.sendCommentButton.isEnabled = false

            PrayerWallService.shared.createComment(prayerId: self.prayer.id, text: text, isAnonymous: true) { [weak self] result in
                guard let self = self else { return }
                self.isSubmittingComment = false
                self.sendCommentButton.isEnabled = true
                switch result {
                case .success(let comment):
                    self.commentField.text = ""
                    self.comments.insert(comment, at: 0)
                    self.tableView.reloadData()
                    self.updateTableHeight()
                    self.onUpdated?()
                case .failure(let error):
                    self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(comments.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments.isEmpty {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.textLabel?.text = "No comments yet. Be the first to encourage."
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 14)
            cell.textLabel?.textColor = isNight ? UIColor.white.withAlphaComponent(0.6) : .gray
            cell.textLabel?.numberOfLines = 0
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: PrayerCommentCell.reuseId, for: indexPath) as! PrayerCommentCell
        cell.configure(comment: comments[indexPath.row], isNight: isNight, themeColor: themeColor)
        return cell
    }
}

private final class PrayerCommentCell: UITableViewCell {
    static let reuseId = "PrayerCommentCell"

    private let bubbleView = UIView()
    private let textLabelCustom = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 12
        contentView.addSubview(bubbleView)

        textLabelCustom.translatesAutoresizingMaskIntoConstraints = false
        textLabelCustom.numberOfLines = 0
        textLabelCustom.font = UIFont.systemFont(ofSize: 15)
        bubbleView.addSubview(textLabelCustom)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            textLabelCustom.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            textLabelCustom.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            textLabelCustom.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            textLabelCustom.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(comment: PrayerWallComment, isNight: Bool, themeColor: UIColor) {
        bubbleView.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : .white
        let author = comment.isAnonymous ? "Anonymous" : "Friend"
        textLabelCustom.text = "\(author)\n\(comment.text)"
        textLabelCustom.textColor = isNight ? .white : .black
    }
}
