//
//  OpenChatViewController.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

private struct OpenChatMessage {
    enum Role {
        case user
        case assistant
    }

    let role: Role
    let text: String
}

final class OpenChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private let isNight: Bool
    private var messages: [OpenChatMessage] = []
    private var models: [OpenChatModel] = []
    private var selectedModelId: String?
    private var isSending = false

    private let bannerView = UIView()
    private let titleLabel = UILabel()
    private let backImageView = UIImageView()
    private let backButton = UIButton(type: .system)

    private let modelBar = UIView()
    private let modelTitleLabel = UILabel()
    private let modelButton = UIButton(type: .system)

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = UIView()
    private let composerContainer = UIView()
    private let inputTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let sendButton = UIButton(type: .custom)
    private let typingLabel = UILabel()

    private var bannerHeightConstraint: NSLayoutConstraint?
    private var composerBottomConstraint: NSLayoutConstraint?
    private var inputHeightConstraint: NSLayoutConstraint?

    private var modelPickerContainer: UIView?
    private var modelPicker: UIPickerView?

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
        loadModels()
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
        titleLabel.text = "Open Chat"
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

        modelBar.translatesAutoresizingMaskIntoConstraints = false
        modelBar.backgroundColor = isNight ? DarkModeColor : .white
        view.addSubview(modelBar)

        let modelBarLine = UIView()
        modelBarLine.translatesAutoresizingMaskIntoConstraints = false
        modelBarLine.backgroundColor = UIColor.black.withAlphaComponent(isNight ? 0.25 : 0.08)
        modelBar.addSubview(modelBarLine)

        modelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        modelTitleLabel.text = "Model"
        modelTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        modelTitleLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.7) : .darkGray
        modelBar.addSubview(modelTitleLabel)

        modelButton.translatesAutoresizingMaskIntoConstraints = false
        modelButton.contentHorizontalAlignment = .left
        modelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        modelButton.titleLabel?.lineBreakMode = .byTruncatingMiddle
        modelButton.setTitleColor(isNight ? .white : .black, for: .normal)
        modelButton.backgroundColor = isNight ? UIColor.white.withAlphaComponent(0.08) : UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
        modelButton.layer.cornerRadius = 10
        modelButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        modelButton.setTitle("Loading models...", for: .normal)
        modelButton.addTarget(self, action: #selector(modelButtonTapped), for: .touchUpInside)
        modelBar.addSubview(modelButton)

        if let chevron = UIImage(systemName: "chevron.down") {
            modelButton.setImage(chevron, for: .normal)
            modelButton.tintColor = isNight ? .white : themeColor
            modelButton.semanticContentAttribute = .forceRightToLeft
            modelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 12, right: 0)
        tableView.register(OpenChatBubbleCell.self, forCellReuseIdentifier: OpenChatBubbleCell.reuseId)
        tableView.register(OpenChatTypingCell.self, forCellReuseIdentifier: OpenChatTypingCell.reuseId)
        view.addSubview(tableView)

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
        placeholderLabel.text = "Type a message..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = isNight ? UIColor.white.withAlphaComponent(0.45) : .gray
        inputTextView.addSubview(placeholderLabel)

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

            modelBar.topAnchor.constraint(equalTo: bannerView.bottomAnchor),
            modelBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modelBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            modelTitleLabel.topAnchor.constraint(equalTo: modelBar.topAnchor, constant: 10),
            modelTitleLabel.leadingAnchor.constraint(equalTo: modelBar.leadingAnchor, constant: 16),

            modelButton.topAnchor.constraint(equalTo: modelTitleLabel.bottomAnchor, constant: 6),
            modelButton.leadingAnchor.constraint(equalTo: modelBar.leadingAnchor, constant: 16),
            modelButton.trailingAnchor.constraint(equalTo: modelBar.trailingAnchor, constant: -16),
            modelButton.heightAnchor.constraint(equalToConstant: 40),
            modelButton.bottomAnchor.constraint(equalTo: modelBar.bottomAnchor, constant: -12),

            modelBarLine.leadingAnchor.constraint(equalTo: modelBar.leadingAnchor),
            modelBarLine.trailingAnchor.constraint(equalTo: modelBar.trailingAnchor),
            modelBarLine.bottomAnchor.constraint(equalTo: modelBar.bottomAnchor),
            modelBarLine.heightAnchor.constraint(equalToConstant: 0.5),

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
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalTo: inputTextView.heightAnchor),
            sendButton.heightAnchor.constraint(equalTo: inputTextView.heightAnchor),

            tableView.topAnchor.constraint(equalTo: modelBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: composerContainer.topAnchor),

            emptyStateView.topAnchor.constraint(equalTo: modelBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: composerContainer.topAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        let icon = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = isNight ? UIColor.white.withAlphaComponent(0.35) : themeColor.withAlphaComponent(0.45)
        icon.contentMode = .scaleAspectFit
        emptyStateView.addSubview(icon)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Choose a model, then start chatting."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = isNight ? UIColor.white.withAlphaComponent(0.55) : .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        emptyStateView.addSubview(label)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -24),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -32)
        ])
    }

    private func loadModels() {
        modelButton.isEnabled = false
        modelButton.setTitle("Loading models...", for: .normal)

        OpenChatService.shared.fetchModels { [weak self] result in
            guard let self = self else { return }
            self.modelButton.isEnabled = true

            switch result {
            case .success(let models):
                self.models = models
                if self.selectedModelId == nil || !models.contains(where: { $0.id == self.selectedModelId }) {
                    self.selectedModelId = models.first?.id
                }
                self.refreshModelButtonTitle()
            case .failure(let error):
                self.modelButton.setTitle("Tap to retry loading models", for: .normal)
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
            }
        }
    }

    private func refreshModelButtonTitle() {
        if let id = selectedModelId {
            modelButton.setTitle(id, for: .normal)
        } else {
            modelButton.setTitle("Select a model", for: .normal)
        }
    }

    @objc private func modelButtonTapped() {
        view.endEditing(true)

        if models.isEmpty {
            loadModels()
            return
        }

        if modelPickerContainer != nil {
            dismissModelPicker()
            return
        }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = isNight ? DarkModeColor : .white
        view.addSubview(container)

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = isNight ? .black : .default
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissModelPicker))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(confirmModelPicker))
        toolbar.items = [cancel, flex, done]

        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        if let selected = selectedModelId,
           let index = models.firstIndex(where: { $0.id == selected }) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }

        container.addSubview(toolbar)
        container.addSubview(picker)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            toolbar.topAnchor.constraint(equalTo: container.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),

            picker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 180)
        ])

        modelPickerContainer = container
        modelPicker = picker
    }

    @objc private func dismissModelPicker() {
        modelPickerContainer?.removeFromSuperview()
        modelPickerContainer = nil
        modelPicker = nil
    }

    @objc private func confirmModelPicker() {
        guard let picker = modelPicker, !models.isEmpty else {
            dismissModelPicker()
            return
        }
        let row = picker.selectedRow(inComponent: 0)
        selectedModelId = models[row].id
        refreshModelButtonTitle()
        dismissModelPicker()
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

    @objc private func sendTapped() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        guard let modelId = selectedModelId, !modelId.isEmpty else {
            view.makeToast("Select a model first", duration: 2.0, position: .bottom)
            return
        }

        if !NetworkManager.sharedInstance.isConnectedToInternet() {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
            return
        }

        dismissModelPicker()

        messages.append(OpenChatMessage(role: .user, text: text))
        inputTextView.text = ""
        placeholderLabel.isHidden = false
        refreshInputHeight()
        emptyStateView.isHidden = true
        isSending = true
        typingLabel.isHidden = false
        tableView.reloadData()
        scrollToBottom(animated: true)
        view.endEditing(false)

        OpenChatService.shared.send(input: text, model: modelId) { [weak self] result in
            guard let self = self else { return }
            self.isSending = false
            self.typingLabel.isHidden = true

            switch result {
            case .success(let reply):
                self.messages.append(OpenChatMessage(role: .assistant, text: reply))
            case .failure(let error):
                self.view.makeToast(error.localizedDescription, duration: 2.5, position: .bottom)
            }
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
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

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        models.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        models[row].id
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count + (isSending ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= messages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: OpenChatTypingCell.reuseId, for: indexPath) as! OpenChatTypingCell
            cell.configure(isNight: isNight, themeColor: themeColor)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: OpenChatBubbleCell.reuseId, for: indexPath) as! OpenChatBubbleCell
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

private final class OpenChatBubbleCell: UITableViewCell {
    static let reuseId = "OpenChatBubbleCell"

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

    func configure(message: OpenChatMessage, isNight: Bool, themeColor: UIColor) {
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

private final class OpenChatTypingCell: UITableViewCell {
    static let reuseId = "OpenChatTypingCell"

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
