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
    private var fetchTask: URLSessionTask?
    private var fetchGeneration = 0
    /// True when the latest result came from cache (do not consume another free use).
    private var lastResultFromCache = false
    /// When true, `didMoveToSuperview` only shows loading — caller starts the fetch after chapter text is ready.
    var deferInitialFetch = false

    private let dimButton = UIButton(type: .custom)
    private let cardView = UIView()
    private let grabHandle = UIView()
    private let grabButton = UIButton(type: .custom)
    private var isDismissingSheet = false
    private let contentContainer = UIView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .custom)
    private let footerContainer = UIView()
    private let footerDivider = UIView()
    private let askPrimaryButton = UIButton(type: .system)
    private let actionStack = UIStackView()
    private var footerIconHolders: [UIView] = []
    private var footerImageViews: [UIImageView] = []
    private var footerLabels: [UILabel] = []
    private var cardBottomConstraint: NSLayoutConstraint?

    /// HTML sheet sits on the home indicator, not above the old tab bar.
    private let sheetBottomInset: CGFloat = 8

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
        // Block dim taps briefly so a leftover Continue/menu finger-up cannot close the sheet instantly.
        dimButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.dimButton.isEnabled = true
        }
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
        // Use layer corners (not a one-shot bounds mask). roundCorners on zero bounds hid the whole card and left only the dim.
        cardView.layer.cornerRadius = 24
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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

        grabButton.translatesAutoresizingMaskIntoConstraints = false
        grabButton.addTarget(self, action: #selector(grabHandleTapped), for: .touchUpInside)
        let grabPan = UIPanGestureRecognizer(target: self, action: #selector(handleGrabPan(_:)))
        grabButton.addGestureRecognizer(grabPan)
        cardView.addSubview(grabButton)

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

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = .clear
        cardView.addSubview(contentContainer)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = themeColor == BGNightMode ? .white : .default
        scrollView.contentInsetAdjustmentBehavior = .never
        contentContainer.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = themeColor == BGNightMode ? .white : themeColor
        cardView.addSubview(loadingIndicator)

        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.7) : UIColor(red: 0.45, green: 0.5, blue: 0.58, alpha: 1)
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = true
        cardView.addSubview(loadingLabel)

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
        actionStack.spacing = 8
        actionStack.isHidden = false

        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.backgroundColor = themeColor == BGNightMode ? BGNightMode : .white
        cardView.addSubview(footerContainer)

        footerDivider.translatesAutoresizingMaskIntoConstraints = false
        footerDivider.backgroundColor = themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.1)
            : UIColor.black.withAlphaComponent(0.08)
        footerContainer.addSubview(footerDivider)

        askPrimaryButton.translatesAutoresizingMaskIntoConstraints = false
        askPrimaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        askPrimaryButton.layer.cornerRadius = 14
        askPrimaryButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        askPrimaryButton.addTarget(self, action: #selector(askTapped), for: .touchUpInside)
        askPrimaryButton.isHidden = !usesOldOnboarding
        footerContainer.addSubview(askPrimaryButton)

        let copyAction = makeActionButton(title: "Copy", imageName: "CopyNewImg", action: #selector(copyTapped))
        let shareAction = makeActionButton(title: "Share", imageName: "shareVerse", action: #selector(shareTapped))
        let saveAction = makeActionButton(title: "Save", imageName: "save", action: #selector(saveTapped))
        actionStack.addArrangedSubview(copyAction)
        actionStack.addArrangedSubview(shareAction)
        actionStack.addArrangedSubview(saveAction)
        footerContainer.addSubview(actionStack)
        setActionsEnabled(false)
        refreshAskPrimaryTitle()

        cardBottomConstraint = cardView.bottomAnchor.constraint(equalTo: bottomAnchor)

        // HTML `.sheet { top: 92px; bottom: 0 }` with `.sbody { flex:1; overflow-y:auto }`.
        NSLayoutConstraint.activate([
            dimButton.topAnchor.constraint(equalTo: topAnchor),
            dimButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            cardBottomConstraint!,

            grabHandle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 9),
            grabHandle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            grabHandle.widthAnchor.constraint(equalToConstant: 38),
            grabHandle.heightAnchor.constraint(equalToConstant: 4.5),

            grabButton.topAnchor.constraint(equalTo: cardView.topAnchor),
            grabButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            grabButton.widthAnchor.constraint(equalToConstant: 88),
            grabButton.heightAnchor.constraint(equalToConstant: 24),

            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            contentContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 18),
            contentContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            contentContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            contentContainer.bottomAnchor.constraint(equalTo: footerContainer.topAnchor),

            scrollView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),

            errorLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            footerContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            footerContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            footerDivider.topAnchor.constraint(equalTo: footerContainer.topAnchor),
            footerDivider.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 22),
            footerDivider.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -22),
            footerDivider.heightAnchor.constraint(equalToConstant: 1),

            askPrimaryButton.topAnchor.constraint(equalTo: footerDivider.bottomAnchor, constant: 14),
            askPrimaryButton.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 22),
            askPrimaryButton.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -22),

            actionStack.topAnchor.constraint(equalTo: askPrimaryButton.bottomAnchor, constant: usesOldOnboarding ? 6 : 14),
            actionStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 8),
            actionStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -8),
            actionStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -sheetBottomInset),
            actionStack.heightAnchor.constraint(equalToConstant: 68)
        ])

        if !usesOldOnboarding {
            askPrimaryButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }

    private func refreshAskPrimaryTitle() {
        let title = isSummaryContent ? "Ask about this chapter" : "Ask about this verse"
        askPrimaryButton.setTitle(title, for: .normal)
        let night = themeColor == BGNightMode
        askPrimaryButton.backgroundColor = night
            ? UIColor.white.withAlphaComponent(0.12)
            : themeColor.withAlphaComponent(0.12)
        askPrimaryButton.setTitleColor(night ? .white : themeColor, for: .normal)
    }

    private func makeActionButton(title: String, imageName: String, systemName: String? = nil, action: Selector) -> UIView {
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

        let imageView = UIImageView(image: systemName.flatMap {
            UIImage(systemName: $0, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular))
        } ?? UIImage(named: imageName))
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
        footerIconHolders.append(iconHolder)
        footerImageViews.append(imageView)
        footerLabels.append(label)

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

    private var actionActiveColor: UIColor {
        themeColor == BGNightMode ? .white : themeColor
    }

    private var actionMildColor: UIColor {
        themeColor == BGNightMode
            ? UIColor.white.withAlphaComponent(0.35)
            : UIColor.black.withAlphaComponent(0.28)
    }

    private func setActionsEnabled(_ enabled: Bool) {
        actionStack.isUserInteractionEnabled = enabled
        askPrimaryButton.isEnabled = enabled
        askPrimaryButton.alpha = enabled ? 1 : 0.45
        let tint = enabled ? actionActiveColor : actionMildColor
        let holderColor = enabled
            ? (themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.1) : themeColor.withAlphaComponent(0.1))
            : (themeColor == BGNightMode ? UIColor.white.withAlphaComponent(0.06) : UIColor.black.withAlphaComponent(0.06))
        for holder in footerIconHolders {
            holder.backgroundColor = holderColor
        }
        for imageView in footerImageViews {
            ImageTint.sharedInstance.imageTintcolorMethod(img: imageView, colorVu: tint)
        }
        for label in footerLabels {
            label.textColor = tint
        }
    }

    private func clearContentStack() {
        contentStack.arrangedSubviews.forEach {
            contentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
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

        refreshAskPrimaryTitle()

        switch displayMode {
        case .saved:
            showSuccess(explanationText)
        case .fetchNew, .chapterSummary:
            showLoading()
            if deferInitialFetch { return }
            // Let the sheet paint first — heavy chapter/prompt work was freezing before it appeared.
            DispatchQueue.main.async { [weak self] in
                self?.startFetchForCurrentMode()
            }
        }
    }

    /// Used when chapter text is built off the main thread after the sheet is already visible.
    func startDeferredFetch() {
        deferInitialFetch = false
        guard superview != nil else { return }
        startFetchForCurrentMode()
    }

    private func startFetchForCurrentMode() {
        guard superview != nil else { return }
        switch displayMode {
        case .fetchNew:
            requestExplanation()
        case .chapterSummary:
            requestChapterSummary()
        case .saved:
            break
        }
    }

    private func requestExplanation() {
        guard !isLoading else { return }
        guard !verseText.isEmpty else {
            showError("Please try again")
            return
        }
        isLoading = true
        lastResultFromCache = false
        showLoading()

        fetchGeneration += 1
        let generation = fetchGeneration
        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code
        fetchTask?.cancel()
        let task = OpenAIExplanationService.shared.fetchExplanation(
            verseReference: verseReference,
            verseText: verseText,
            bibleVersion: bibleVersion,
            responseLanguageCode: languageCode
        ) { [weak self] result in
            guard let self = self, generation == self.fetchGeneration else { return }
            self.fetchTask = nil
            self.isLoading = false
            switch result {
            case .success(let text):
                if !self.lastResultFromCache {
                    AIUsageLimiter.shared.commit(.explanation)
                }
                self.explanationText = text
                self.showSuccess(text)
            case .failure(.networkError):
                // Keep the sheet open — auto-dismiss looked like Get Explanation never opened.
                let message = getConnection.shared.networkBlockMessage() ?? "No internet connection."
                self.showError(message)
                self.makeToast("Check your internet connection", duration: 2.0, position: .top)
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
        fetchTask = task
        // Nil task means cache hit (completion already queued on main).
        lastResultFromCache = (task == nil)
        stopIfTooSlow(generation: generation, after: 25)
    }

    /// A weak network can hold the request for 60s. Give up earlier and offer Retry.
    private func stopIfTooSlow(generation: Int, after seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self = self, self.isLoading, generation == self.fetchGeneration else { return }
            self.fetchGeneration += 1
            self.fetchTask?.cancel()
            self.fetchTask = nil
            self.isLoading = false
            self.showError("This is taking too long. Please check your internet and tap Retry.")
            self.makeToast("Check your internet connection", duration: 2.0, position: .top)
        }
    }

    private func requestChapterSummary() {
        guard !isLoading else { return }
        guard !verseText.isEmpty else {
            showError("Please try again")
            return
        }
        isLoading = true
        lastResultFromCache = false
        showLoading()

        fetchGeneration += 1
        let generation = fetchGeneration
        let languageCode = UserDefaults.standard.string(forKey: "language_code") ?? language_code
        fetchTask?.cancel()
        let task = OpenAIExplanationService.shared.fetchChapterSummary(
            chapterReference: screenTitle ?? verseReference.replacingOccurrences(of: "-", with: " "),
            chapterText: verseText,
            bibleVersion: bibleVersion,
            responseLanguageCode: languageCode
        ) { [weak self] result in
            guard let self = self, generation == self.fetchGeneration else { return }
            self.fetchTask = nil
            self.isLoading = false
            switch result {
            case .success(let text):
                if !self.lastResultFromCache {
                    AIUsageLimiter.shared.commit(.chapterSummary)
                }
                self.explanationText = text
                self.showSuccess(text)
            case .failure(.networkError):
                // Keep the sheet open — auto-dismiss looked like the summary never opened.
                let message = getConnection.shared.networkBlockMessage() ?? "No internet connection."
                self.showError(message)
                self.makeToast("Check your internet connection", duration: 2.0, position: .top)
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
        fetchTask = task
        lastResultFromCache = (task == nil)
        stopIfTooSlow(generation: generation, after: 40)
    }

    private func showLoading() {
        clearContentStack()
        scrollView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
        actionStack.isHidden = false
        footerDivider.isHidden = false
        footerContainer.isHidden = false
        setActionsEnabled(false)
        loadingIndicator.startAnimating()
        loadingLabel.text = displayMode == .chapterSummary ? "Getting chapter summary…" : "Getting explanation…"
        loadingLabel.isHidden = false
    }

    private func showSuccess(_ text: String) {
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
        scrollView.isHidden = false
        errorLabel.isHidden = true
        retryButton.isHidden = true
        actionStack.isHidden = false
        footerDivider.isHidden = false
        footerContainer.isHidden = false
        setActionsEnabled(true)
        renderStructuredContent(text)
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.contentOffset = .zero
        setNeedsLayout()
        layoutIfNeeded()
        // After layout, content height is known — keep the HTML body scrollable.
        scrollView.layoutIfNeeded()
        contentStack.layoutIfNeeded()
    }

    private func renderStructuredContent(_ text: String) {
        clearContentStack()
        let colors = VerseExplanationSheetLayout.colors(theme: themeColor)
        let split = VerseExplanationSheetLayout.splitAIText(text)
        let isSummary = isSummaryContent

        if !isSummary, !verseText.isEmpty {
            let quote = VerseExplanationSheetLayout.makeScriptureQuote(verseText, colors: colors)
            contentStack.addArrangedSubview(quote)
            contentStack.setCustomSpacing(24, after: quote)
        }

        if isSummary {
            renderChapterSummaryContent(text, colors: colors, fallback: split)
            return
        }

        let parsed = VerseExplanationSheetLayout.parseVerseExplanation(text)
        if parsed.isStructured {
            if !parsed.lead.isEmpty {
                let lead = VerseExplanationSheetLayout.makeLead(parsed.lead, colors: colors)
                contentStack.addArrangedSubview(lead)
                contentStack.setCustomSpacing(24, after: lead)
            }
            if !parsed.context.isEmpty {
                let rule = VerseExplanationSheetLayout.makeSectionRule("In context", colors: colors)
                contentStack.addArrangedSubview(rule)
                contentStack.setCustomSpacing(11, after: rule)
                let body = VerseExplanationSheetLayout.makeBody(parsed.context, colors: colors)
                contentStack.addArrangedSubview(body)
                contentStack.setCustomSpacing(24, after: body)
            }
            if !parsed.today.isEmpty {
                let rule = VerseExplanationSheetLayout.makeSectionRule("What it means today", colors: colors)
                contentStack.addArrangedSubview(rule)
                contentStack.setCustomSpacing(11, after: rule)
                let body = VerseExplanationSheetLayout.makeBody(parsed.today, colors: colors)
                contentStack.addArrangedSubview(body)
                contentStack.setCustomSpacing(24, after: body)
            }
            if !parsed.related.isEmpty {
                let rule = VerseExplanationSheetLayout.makeSectionRule("Related verses", colors: colors)
                contentStack.addArrangedSubview(rule)
                contentStack.setCustomSpacing(11, after: rule)
                let tags = VerseExplanationSheetLayout.makeRefTags(
                    parsed.related,
                    colors: colors,
                    target: self,
                    action: #selector(relatedRefTapped(_:))
                )
                contentStack.addArrangedSubview(tags)
            }
            return
        }

        // Fallback for older freeform replies still in cache / library.
        if !split.lead.isEmpty {
            let lead = VerseExplanationSheetLayout.makeLead(split.lead, colors: colors)
            contentStack.addArrangedSubview(lead)
            contentStack.setCustomSpacing(24, after: lead)
        }

        let contextText = split.bodies.first
        let applyText = split.bodies.dropFirst().joined(separator: "\n\n")
        if let contextText = contextText, !contextText.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("In context", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(11, after: rule)
            let body = VerseExplanationSheetLayout.makeBody(contextText, colors: colors)
            contentStack.addArrangedSubview(body)
            contentStack.setCustomSpacing(24, after: body)
        }
        if !applyText.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("What it means today", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(11, after: rule)
            let body = VerseExplanationSheetLayout.makeBody(applyText, colors: colors)
            contentStack.addArrangedSubview(body)
            contentStack.setCustomSpacing(24, after: body)
        }

        let refs = VerseExplanationSheetLayout.relatedReferences(
            in: text,
            excluding: verseReference.replacingOccurrences(of: "-", with: " ")
        )
        if !refs.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Related verses", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(11, after: rule)
            let tags = VerseExplanationSheetLayout.makeRefTags(
                refs,
                colors: colors,
                target: self,
                action: #selector(relatedRefTapped(_:))
            )
            contentStack.addArrangedSubview(tags)
        }
    }

    private func renderChapterSummaryContent(
        _ text: String,
        colors: VerseExplanationSheetLayout.Colors,
        fallback: (lead: String, bodies: [String])
    ) {
        let parsed = VerseExplanationSheetLayout.parseChapterSummary(text)
        if parsed.isStructured {
            // HTML summary: lead 24 → part 11 → beats 24 → key tags 24 → themes (+ 8 bottom).
            clearContentStack()
            let lead = VerseExplanationSheetLayout.makeLead(parsed.lead, colors: colors)
            contentStack.addArrangedSubview(lead)
            contentStack.setCustomSpacing(24, after: lead)

            let moveRule = VerseExplanationSheetLayout.makeSectionRule(
                "\(parsed.movements.count) movements",
                colors: colors
            )
            contentStack.addArrangedSubview(moveRule)
            contentStack.setCustomSpacing(11, after: moveRule)

            let beats = UIStackView()
            beats.axis = .vertical
            beats.alignment = .fill
            beats.spacing = 0
            for (index, move) in parsed.movements.enumerated() {
                beats.addArrangedSubview(
                    VerseExplanationSheetLayout.makeMovementRow(
                        index: index + 1,
                        title: move.title,
                        detail: move.detail,
                        colors: colors,
                        showDivider: index < parsed.movements.count - 1
                    )
                )
            }
            contentStack.addArrangedSubview(beats)
            contentStack.setCustomSpacing(24, after: beats)

            if !parsed.keys.isEmpty {
                let rule = VerseExplanationSheetLayout.makeSectionRule("Key verses", colors: colors)
                contentStack.addArrangedSubview(rule)
                contentStack.setCustomSpacing(11, after: rule)
                let tags = VerseExplanationSheetLayout.makeRefTags(
                    parsed.keys,
                    colors: colors,
                    target: self,
                    action: #selector(relatedRefTapped(_:))
                )
                contentStack.addArrangedSubview(tags)
                contentStack.setCustomSpacing(24, after: tags)
            }

            if !parsed.themes.isEmpty {
                let rule = VerseExplanationSheetLayout.makeSectionRule("Themes", colors: colors)
                contentStack.addArrangedSubview(rule)
                contentStack.setCustomSpacing(11, after: rule)
                let tags = VerseExplanationSheetLayout.makeThemeTags(parsed.themes, colors: colors)
                contentStack.addArrangedSubview(tags)
                contentStack.setCustomSpacing(8, after: tags)
            } else {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
                contentStack.addArrangedSubview(spacer)
            }
            return
        }

        if !fallback.lead.isEmpty {
            let lead = VerseExplanationSheetLayout.makeLead(fallback.lead, colors: colors)
            contentStack.addArrangedSubview(lead)
            contentStack.setCustomSpacing(24, after: lead)
        }
        if let body = fallback.bodies.first, !body.isEmpty {
            let rule = VerseExplanationSheetLayout.makeSectionRule("Overview", colors: colors)
            contentStack.addArrangedSubview(rule)
            contentStack.setCustomSpacing(11, after: rule)
            let bodyLabel = VerseExplanationSheetLayout.makeBody(body, colors: colors)
            contentStack.addArrangedSubview(bodyLabel)
        }
    }

    private var displaySummaryText: String {
        let parsed = VerseExplanationSheetLayout.parseChapterSummary(explanationText)
        return parsed.isStructured ? parsed.plainText : explanationText
    }

    private var displayExplanationText: String {
        let parsed = VerseExplanationSheetLayout.parseVerseExplanation(explanationText)
        return parsed.isStructured ? parsed.plainText : explanationText
    }

    @objc private func relatedRefTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), !title.isEmpty else { return }
        inputAskAbout(title)
    }

    private func inputAskAbout(_ reference: String) {
        guard !explanationText.isEmpty else { return }
        let context = AIChatLaunchContext(
            isChapterSummary: false,
            title: reference,
            verseText: nil,
            sourceText: explanationText
        )
        let host = App_Protocol.delegateReader as? UIViewController
        closeTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            let chat = AIChatViewController()
            chat.launchContext = context
            if let nav = host?.navigationController {
                nav.pushViewController(chat, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: chat)
                nav.modalPresentationStyle = .fullScreen
                host?.present(nav, animated: true)
            }
        }
    }

    private func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
        clearContentStack()
        scrollView.isHidden = true
        errorLabel.isHidden = false
        errorLabel.text = message
        retryButton.isHidden = false
        actionStack.isHidden = false
        footerDivider.isHidden = false
        footerContainer.isHidden = false
        setActionsEnabled(false)
    }

    @objc private func retryTapped() {
        if displayMode == .chapterSummary {
            requestChapterSummary()
        } else {
            requestExplanation()
        }
    }

    @objc private func grabHandleTapped() {
        dismissSheetDownward()
    }

    @objc private func handleGrabPan(_ pan: UIPanGestureRecognizer) {
        let translation = max(0, pan.translation(in: self).y)
        switch pan.state {
        case .changed:
            cardBottomConstraint?.constant = translation
            layoutIfNeeded()
        case .ended, .cancelled:
            let velocity = pan.velocity(in: self).y
            if translation > 80 || velocity > 800 {
                dismissSheetDownward()
            } else {
                cardBottomConstraint?.constant = 0
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                    self.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    private func dismissSheetDownward() {
        guard !isDismissingSheet else { return }
        isDismissingSheet = true
        cardBottomConstraint?.constant = max(cardView.bounds.height, bounds.height)
        UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseIn) {
            self.backgroundColor = .clear
            self.layoutIfNeeded()
        } completion: { _ in
            self.closeTapped()
        }
    }

    @objc private func closeTapped() {
        fetchGeneration += 1
        fetchTask?.cancel()
        fetchTask = nil
        isLoading = false
        onDismiss?()
        removeFromSuperview()
        superview?.removeFromSuperview()
    }

    /// Chapter summaries (new or reopened from My Library) keep the whole numbered chapter in verseText.
    private var isSummaryContent: Bool {
        if displayMode == .chapterSummary { return true }
        return displayMode == .saved && verseText.hasPrefix("1. ") && verseText.contains("\n2. ")
    }

    /// Summary references are stored as "Book-Chapter:1"; show "Book Chapter Summary".
    private var summaryTitle: String {
        if let screenTitle = screenTitle { return screenTitle }
        var chapter = verseReference.replacingOccurrences(of: "-", with: " ")
        if chapter.hasSuffix(":1") { chapter.removeLast(2) }
        return "\(chapter) Summary"
    }

    @objc private func copyTapped() {
        guard !explanationText.isEmpty else { return }
        if isSummaryContent {
            // verseText holds the whole chapter here — copy only the summary.
            UIPasteboard.general.string = "\(summaryTitle)\n\n\(displaySummaryText)\n\n\(APP_LINK)"
            makeToast("Copied successfully", duration: 2.0, position: .top)
            return
        }
        UIPasteboard.general.string = "\(displayExplanationText)\n\n\(verseText)\n\n\(verseReference.replacingOccurrences(of: "-", with: " "))\n\n\(APP_LINK)"
        makeToast("Copied successfully", duration: 2.0, position: .top)
    }

    @objc private func saveTapped() {
        guard !explanationText.isEmpty else { return }
        CoreDataModel.sharedInstance.saveVerseExplanation(
            bookVerse: verseReference,
            bibleVersion: bibleVersion,
            explanationText: explanationText,
            verse: verseText
        )
        makeToast("Saved to My Library", duration: 2.0, position: .top)
    }

    @objc private func askTapped() {
        guard !explanationText.isEmpty else { return }
        let isSummary = displayMode == .chapterSummary
        let title = screenTitle ?? verseReference.replacingOccurrences(of: "-", with: " ")
        let context = AIChatLaunchContext(
            isChapterSummary: isSummary,
            title: title,
            verseText: isSummary ? nil : verseText,
            sourceText: explanationText
        )
        let host = App_Protocol.delegateReader as? UIViewController
        closeTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            let chat = AIChatViewController()
            chat.launchContext = context
            if let nav = host?.navigationController {
                nav.pushViewController(chat, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: chat)
                nav.modalPresentationStyle = .fullScreen
                host?.present(nav, animated: true)
            }
        }
    }

    @objc private func readTapped() {
        guard !explanationText.isEmpty else { return }
        let readReference = verseReference.replacingOccurrences(of: "-", with: " ")
        UserDefaults.standard.set(readReference, forKey: "readdata")
        App_Protocol.delegateReader?.CloseMenu()
        closeTapped()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
    }

    @objc private func shareTapped() {
        guard !explanationText.isEmpty else { return }
        // Display order only: verse + reference, then "Explanation", then explanation text.
        // Uses the same shared(VerseStr:Bookname:) path — no share/fetch logic changes.
        let reference = verseReference.replacingOccurrences(of: "-", with: " ")
        if isSummaryContent {
            // Share only the summary, never the full chapter text.
            App_Protocol.delegateReader?.shared(
                VerseStr: summaryTitle,
                Bookname: "Summary\n\n\(displaySummaryText)"
            )
            return
        }
        App_Protocol.delegateReader?.shared(
            VerseStr: "\(verseText)\n\n\(reference)",
            Bookname: "Explanation\n\n\(displayExplanationText)"
        )
    }
}
