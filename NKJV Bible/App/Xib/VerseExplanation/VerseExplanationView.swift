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
    private let grabHandle = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let verseContainer = UIView()
    private let verseAccent = UIView()
    private let verseLabel = UILabel()
    private let sectionLabel = UILabel()
    private let contentContainer = UIView()
    private let scrollView = UIScrollView()
    private let contentLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .custom)
    private let footerContainer = UIView()
    private let footerDivider = UIView()
    private let actionStack = UIStackView()
    private var cardBottomConstraint: NSLayoutConstraint?
    private var verseContainerHeightConstraint: NSLayoutConstraint?

    private let tabBarOverlap: CGFloat = 96

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
        cardView.clipsToBounds = true
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 18
        cardView.layer.shadowOffset = CGSize(width: 0, height: -4)
        addSubview(cardView)

        grabHandle.translatesAutoresizingMaskIntoConstraints = false
        grabHandle.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.25)
            : UIColor.black.withAlphaComponent(0.12)
        grabHandle.layer.cornerRadius = 2.5
        cardView.addSubview(grabHandle)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.85) : UIColor(red: 0.35, green: 0.38, blue: 0.45, alpha: 1)
        closeButton.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
        closeButton.layer.cornerRadius = 16
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = themeColor == BGNightMode ? .white : themeColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        subtitleLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.55) : UIColor(red: 0.45, green: 0.5, blue: 0.58, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "VERSE EXPLANATION"
        cardView.addSubview(subtitleLabel)

        verseContainer.translatesAutoresizingMaskIntoConstraints = false
        verseContainer.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1)
        verseContainer.layer.cornerRadius = 14
        verseContainer.layer.borderWidth = 1
        verseContainer.layer.borderColor = (themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.1)
            : themeColor.withAlphaComponent(0.12)).cgColor
        verseContainer.clipsToBounds = true
        cardView.addSubview(verseContainer)

        verseAccent.translatesAutoresizingMaskIntoConstraints = false
        verseAccent.backgroundColor = themeColor == BGNightMode ? DarkModeColor : themeColor
        verseAccent.layer.cornerRadius = 2
        verseContainer.addSubview(verseAccent)

        verseLabel.translatesAutoresizingMaskIntoConstraints = false
        if let serif = UIFont(name: "Georgia", size: 16) {
            verseLabel.font = serif
        } else {
            verseLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        verseLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.92) : UIColor(red: 0.16, green: 0.2, blue: 0.32, alpha: 1)
        verseLabel.numberOfLines = 0
        verseContainer.addSubview(verseLabel)

        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        sectionLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.5) : UIColor(red: 0.5, green: 0.54, blue: 0.62, alpha: 1)
        sectionLabel.text = "EXPLANATION"
        sectionLabel.isHidden = true
        cardView.addSubview(sectionLabel)

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.05)
            : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1)
        contentContainer.layer.cornerRadius = 14
        contentContainer.layer.borderWidth = 1
        contentContainer.layer.borderColor = (themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)).cgColor
        cardView.addSubview(contentContainer)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        contentContainer.addSubview(scrollView)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.92) : UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)
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
        actionStack.spacing = 16
        actionStack.isHidden = true

        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.backgroundColor = themeColor == BGNightMode ? BGNightMode : .white
        cardView.addSubview(footerContainer)

        footerDivider.translatesAutoresizingMaskIntoConstraints = false
        footerDivider.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.1)
            : UIColor.black.withAlphaComponent(0.08)
        footerContainer.addSubview(footerDivider)

        let copyAction = makeActionButton(title: "Copy", imageName: "CopyNewImg", action: #selector(copyTapped))
        let readAction = makeActionButton(title: "Read", imageName: "reloadVerse", action: #selector(readTapped))
        let shareAction = makeActionButton(title: "Share", imageName: "shareVerse", action: #selector(shareTapped))
        actionStack.addArrangedSubview(copyAction)
        actionStack.addArrangedSubview(readAction)
        actionStack.addArrangedSubview(shareAction)
        footerContainer.addSubview(actionStack)

        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            dimButton.topAnchor.constraint(equalTo: topAnchor),
            dimButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardBottomConstraint!,
            cardView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -40),

            grabHandle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            grabHandle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            grabHandle.widthAnchor.constraint(equalToConstant: 40),
            grabHandle.heightAnchor.constraint(equalToConstant: 5),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: grabHandle.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 48),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -48),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            verseContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            verseContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            verseContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            verseAccent.topAnchor.constraint(equalTo: verseContainer.topAnchor, constant: 12),
            verseAccent.leadingAnchor.constraint(equalTo: verseContainer.leadingAnchor, constant: 12),
            verseAccent.bottomAnchor.constraint(equalTo: verseContainer.bottomAnchor, constant: -12),
            verseAccent.widthAnchor.constraint(equalToConstant: 4),

            verseLabel.topAnchor.constraint(equalTo: verseContainer.topAnchor, constant: 12),
            verseLabel.leadingAnchor.constraint(equalTo: verseAccent.trailingAnchor, constant: 12),
            verseLabel.trailingAnchor.constraint(equalTo: verseContainer.trailingAnchor, constant: -14),
            verseLabel.bottomAnchor.constraint(equalTo: verseContainer.bottomAnchor, constant: -12),

            contentContainer.topAnchor.constraint(equalTo: verseContainer.bottomAnchor, constant: 10),
            contentContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentContainer.bottomAnchor.constraint(equalTo: footerContainer.topAnchor, constant: -12),

            sectionLabel.topAnchor.constraint(equalTo: verseContainer.bottomAnchor, constant: 0),
            sectionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            sectionLabel.heightAnchor.constraint(equalToConstant: 0),

            scrollView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -10),

            contentLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            loadingIndicator.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),

            errorLabel.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            footerContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            footerContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            footerDivider.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 4),
            footerDivider.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 20),
            footerDivider.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -20),
            footerDivider.heightAnchor.constraint(equalToConstant: 1),

            actionStack.topAnchor.constraint(equalTo: footerDivider.bottomAnchor, constant: 10),
            actionStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 28),
            actionStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -28),
            actionStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -tabBarOverlap),
            actionStack.heightAnchor.constraint(equalToConstant: 68)
        ])

        verseContainerHeightConstraint = verseContainer.heightAnchor.constraint(equalToConstant: 0)
        verseContainerHeightConstraint?.isActive = false

        DispatchQueue.main.async {
            self.cardView.roundCorners(corners: [.topLeft, .topRight], radius: 24)
        }
    }

    private func makeActionButton(title: String, imageName: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconHolder = UIView()
        iconHolder.translatesAutoresizingMaskIntoConstraints = false
        iconHolder.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.1)
            : themeColor.withAlphaComponent(0.1)
        iconHolder.layer.cornerRadius = 22
        iconHolder.clipsToBounds = true
        container.addSubview(iconHolder)

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        iconHolder.addSubview(imageView)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.textColor = themeColor == BGNightMode ? .white : themeColor
        container.addSubview(label)

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        container.addSubview(button)

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

            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            label.topAnchor.constraint(equalTo: iconHolder.bottomAnchor, constant: 8),
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
            verseLabel.text = nil
            verseLabel.isHidden = true
            verseContainer.isHidden = true
            verseContainerHeightConstraint?.isActive = true
        } else {
            verseLabel.text = verseText
            verseLabel.isHidden = false
            verseContainer.isHidden = false
            verseContainerHeightConstraint?.isActive = false
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
        footerDivider.isHidden = true
        footerContainer.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func showSuccess(_ text: String) {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = false
        contentLabel.isHidden = false
        contentLabel.attributedText = styledExplanationText(text)
        errorLabel.isHidden = true
        retryButton.isHidden = true
        actionStack.isHidden = false
        footerDivider.isHidden = false
        footerContainer.isHidden = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.contentOffset = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func styledExplanationText(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8
        paragraph.paragraphSpacing = 12

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.92) : UIColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 1),
            .paragraphStyle: paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }

    private func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        scrollView.isHidden = true
        contentLabel.isHidden = true
        errorLabel.isHidden = false
        errorLabel.text = message
        retryButton.isHidden = false
        actionStack.isHidden = true
        footerDivider.isHidden = true
        footerContainer.isHidden = true
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
        // Display order only: verse + reference, then "Explanation", then explanation text.
        // Uses the same shared(VerseStr:Bookname:) path — no share/fetch logic changes.
        let reference = verseReference.replacingOccurrences(of: "-", with: " ")
        App_Protocol.delegateReader?.shared(
            VerseStr: "\(verseText)\n\n\(reference)",
            Bookname: "Explanation\n\n\(explanationText)"
        )
    }
}
