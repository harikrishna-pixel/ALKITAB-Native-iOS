//
//  VerseExplanationView.swift
//  NKJV Bible
//

import UIKit
import Toast_Swift

@available(iOS 13.4, *)
final class VerseExplanationView: UIView {

    enum DisplayMode {
        case fetchNew
        case saved
        case chapterSummary
    }

    var displayMode: DisplayMode = .fetchNew
    var verseReference: String = ""
    var verseText: String = ""
    var bibleVersion: String = APPNAME
    var savedRecordString: String = ""
    var explanationText: String = ""
    var screenTitle: String?
    var onDismiss: (() -> Void)?

    private let themeColor: UIColor = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
    private var isLoading = false

    private let dimButton = UIButton(type: .custom)
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let verseLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .custom)
    private let actionStack = UIStackView()
    private var cardBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        applyContent()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        dimButton.translatesAutoresizingMaskIntoConstraints = false
        dimButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(dimButton)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = themeColor == BGNightMode ? BGNightMode : .white
        addSubview(cardView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = UIColor.gray
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = themeColor == BGNightMode ? .white : themeColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        verseLabel.translatesAutoresizingMaskIntoConstraints = false
        verseLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        verseLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.75) : UIColor.darkGray
        verseLabel.numberOfLines = 0
        cardView.addSubview(verseLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        cardView.addSubview(scrollView)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        contentLabel.textColor = themeColor == BGNightMode ? .white : .black
        contentLabel.numberOfLines = 0
        scrollView.addSubview(contentLabel)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = themeColor == BGNightMode ? .white : themeColor
        cardView.addSubview(loadingIndicator)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.textColor = themeColor == BGNightMode ? .white : .darkGray
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        cardView.addSubview(errorLabel)

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.backgroundColor = themeColor == BGNightMode ? DarkModeColor : themeColor
        retryButton.layer.cornerRadius = 8
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        cardView.addSubview(retryButton)

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.distribution = .fillEqually
        actionStack.spacing = 12
        actionStack.isHidden = true
        cardView.addSubview(actionStack)

        let copyAction = makeActionButton(title: "Copy", imageName: "CopyNewImg", action: #selector(copyTapped))
        let readAction = makeActionButton(title: "Read", imageName: "reloadVerse", action: #selector(readTapped))
        let shareAction = makeActionButton(title: "Share", imageName: "shareVerse", action: #selector(shareTapped))
        actionStack.addArrangedSubview(copyAction)
        actionStack.addArrangedSubview(readAction)
        actionStack.addArrangedSubview(shareAction)

        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            dimButton.topAnchor.constraint(equalTo: topAnchor),
            dimButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardBottomConstraint!,
            cardView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.75),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 48),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -48),

            verseLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            verseLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            verseLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            scrollView.topAnchor.constraint(equalTo: verseLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),

            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),

            errorLabel.topAnchor.constraint(equalTo: verseLabel.bottomAnchor, constant: 24),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            actionStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 18),
            actionStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 32),
            actionStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            actionStack.bottomAnchor.constraint(equalTo: cardView.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            actionStack.heightAnchor.constraint(equalToConstant: 72)
        ])

        DispatchQueue.main.async {
            self.cardView.roundCorners(corners: [.topLeft, .topRight], radius: 24)
        }
    }

    private func makeActionButton(title: String, imageName: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconHolder = UIView()
        iconHolder.translatesAutoresizingMaskIntoConstraints = false
        iconHolder.backgroundColor = themeColor == BGNightMode ? BGNightMode : .white
        iconHolder.layer.cornerRadius = 10
        iconHolder.layer.borderWidth = 1.5
        iconHolder.layer.borderColor = (themeColor == BGNightMode ? UIColor.white : themeColor).cgColor
        iconHolder.clipsToBounds = true
        container.addSubview(iconHolder)

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        iconHolder.addSubview(imageView)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = themeColor == BGNightMode ? .white : themeColor
        container.addSubview(label)

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        iconHolder.addSubview(button)

        let tint = themeColor == BGNightMode ? UIColor.white : themeColor
        ImageTint.sharedInstance.imageTintcolorMethod(img: imageView, colorVu: tint)

        NSLayoutConstraint.activate([
            iconHolder.topAnchor.constraint(equalTo: container.topAnchor),
            iconHolder.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconHolder.widthAnchor.constraint(equalToConstant: 44),
            iconHolder.heightAnchor.constraint(equalToConstant: 44),

            imageView.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22),

            button.topAnchor.constraint(equalTo: iconHolder.topAnchor),
            button.leadingAnchor.constraint(equalTo: iconHolder.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: iconHolder.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: iconHolder.bottomAnchor),

            label.topAnchor.constraint(equalTo: iconHolder.bottomAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func applyContent() {
        if displayMode == .saved {
            let parts = savedRecordString.components(separatedBy: ExplanationRecordDelimiter)
            guard parts.count >= 5 else { return }
            verseReference = parts[0]
            bibleVersion = parts[1]
            explanationText = parts[2]
            verseText = parts[3]
        }

        titleLabel.text = screenTitle ?? verseReference.replacingOccurrences(of: "-", with: " ")

        if displayMode == .chapterSummary {
            // Keep full chapter text in `verseText` for the API, but do not show it in the header.
            // A hidden UILabel still keeps its intrinsic height, which caused the empty top gap.
            verseLabel.text = nil
            verseLabel.isHidden = true
        } else {
            verseLabel.text = verseText
            verseLabel.isHidden = false
        }

        switch displayMode {
        case .saved:
            showSuccess(explanationText)
        case .fetchNew:
            requestExplanation()
        case .chapterSummary:
            requestChapterSummary()
        }
    }

    private func requestExplanation() {
        guard !isLoading else { return }
        isLoading = true
        showLoading()

        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code
        OpenAIExplanationService.shared.fetchExplanation(
            verseReference: verseReference,
            verseText: verseText,
            bibleVersion: bibleVersion,
            responseLanguageCode: languageCode
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let text):
                self.explanationText = text
                CoreDataModel.sharedInstance.saveVerseExplanation(
                    bookVerse: self.verseReference,
                    bibleVersion: self.bibleVersion,
                    explanationText: text,
                    verse: self.verseText
                )
                self.showSuccess(text)
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func requestChapterSummary() {
        guard !isLoading else { return }
        isLoading = true
        showLoading()

        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code
        OpenAIExplanationService.shared.fetchChapterSummary(
            chapterReference: screenTitle ?? verseReference.replacingOccurrences(of: "-", with: " "),
            chapterText: verseText,
            bibleVersion: bibleVersion,
            responseLanguageCode: languageCode
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let text):
                self.explanationText = text
                self.showSuccess(text)
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func showLoading() {
        scrollView.isHidden = false
        contentLabel.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        actionStack.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func showSuccess(_ text: String) {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
        contentLabel.isHidden = false
        contentLabel.text = text
        errorLabel.isHidden = true
        retryButton.isHidden = true
        actionStack.isHidden = false
    }

    private func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = true
        contentLabel.isHidden = true
        errorLabel.isHidden = false
        errorLabel.text = message
        retryButton.isHidden = false
        actionStack.isHidden = true
    }

    @objc private func retryTapped() {
        if displayMode == .chapterSummary {
            requestChapterSummary()
        } else {
            requestExplanation()
        }
    }

    @objc private func closeTapped() {
        onDismiss?()
        removeFromSuperview()
        superview?.removeFromSuperview()
    }

    @objc private func copyTapped() {
        UIPasteboard.general.string = "\(explanationText)\n\n\(verseText)\n\n\(verseReference.replacingOccurrences(of: "-", with: " "))\n\n\(APP_LINK)"
        makeToast("Copied successfully", duration: 2.0, position: .center)
    }

    @objc private func readTapped() {
        let readReference = verseReference.replacingOccurrences(of: "-", with: " ")
        UserDefaults.standard.set(readReference, forKey: "readdata")
        App_Protocol.delegateReader?.CloseMenu()
        closeTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
    }

    @objc private func shareTapped() {
        App_Protocol.delegateReader?.shared(VerseStr: explanationText, Bookname: "\(verseText)\n\n\(verseReference.replacingOccurrences(of: "-", with: " "))")
    }
}
