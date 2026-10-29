//
//  DailyVerseFullscreenViewController.swift
//  NKJV Bible
//

import UIKit

final class DailyVerseFullscreenViewController: UIViewController {

    var onClose: (() -> Void)?
    var onForward: (() -> Void)?
    var onContinue: (() -> Void)?
    var onShare: (() -> Void)?
    var onSave: (() -> Void)?

    private var verse: DailyVerseSnapshot
    private let shareButton = UIButton(type: .custom)
    private let saveButton = UIButton(type: .custom)

    private let backgroundImageView = UIImageView()
    private let gradientView = UIView()
    private let closeButton = UIButton(type: .system)
    private let ctaButton = UIButton(type: .system)
    private let watermarkLabel = UILabel()
    private let scrollView = UIScrollView()
    private let referenceLabel = UILabel()
    private let referenceUnderline = UIView()
    private let verseLabel = UILabel()
    private let dotsStack = UIStackView()
    private let showsCTA: Bool

    init(verse: DailyVerseSnapshot, showsCTA: Bool = false) {
        self.verse = verse
        self.showsCTA = showsCTA
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyVerse()
        setupSwipeGesture()
    }

    func update(with verse: DailyVerseSnapshot) {
        self.verse = verse
        applyVerse()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.11, green: 0.18, blue: 0.42, alpha: 1)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        view.addSubview(gradientView)

        // Close — circular, top-left (mockup)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        // Share / Save — top-right, same style as the other verse image screens.
        let accent = UIColor(red: 28 / 255, green: 70 / 255, blue: 178 / 255, alpha: 1)
        [shareButton, saveButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            button.tintColor = accent
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            view.addSubview(button)
        }
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)), for: .normal)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        saveButton.setImage(UIImage(named: "SaveBlue")?.withRenderingMode(.alwaysTemplate), for: .normal)
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // Reference sits with the verse, just above the text.
        referenceLabel.translatesAutoresizingMaskIntoConstraints = false
        referenceLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        referenceLabel.textColor = .white
        referenceLabel.textAlignment = .center
        referenceLabel.numberOfLines = 2

        referenceUnderline.translatesAutoresizingMaskIntoConstraints = false
        referenceUnderline.backgroundColor = UIColor.white.withAlphaComponent(0.85)

        // CTA — bottom primary button (mockup)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle("Start Memory Challenge", for: .normal)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        ctaButton.backgroundColor = UIColor(red: 0.15, green: 0.39, blue: 0.92, alpha: 1)
        ctaButton.layer.cornerRadius = 16
        ctaButton.layer.shadowColor = UIColor.black.cgColor
        ctaButton.layer.shadowOpacity = 0.28
        ctaButton.layer.shadowRadius = 10
        ctaButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        ctaButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        ctaButton.isHidden = !showsCTA
        view.addSubview(ctaButton)

        watermarkLabel.translatesAutoresizingMaskIntoConstraints = false
        watermarkLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        watermarkLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        watermarkLabel.textAlignment = .right
        watermarkLabel.text = todaysVerseAppName()
        watermarkLabel.layer.shadowColor = UIColor.black.cgColor
        watermarkLabel.layer.shadowOpacity = 0.45
        watermarkLabel.layer.shadowRadius = 3
        watermarkLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.addSubview(watermarkLabel)

        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        dotsStack.axis = .horizontal
        dotsStack.spacing = 8
        dotsStack.alignment = .center
        dotsStack.distribution = .equalSpacing
        view.addSubview(dotsStack)

        // Verse body — centered serif text in the middle band (mockup)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        verseLabel.translatesAutoresizingMaskIntoConstraints = false
        verseLabel.font = UIFont(name: "Georgia", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular)
        // Prefer design serif if available in the app
        if let playfair = UIFont(name: "PlayfairDisplay-Regular", size: 22)
            ?? UIFont(name: "PlayfairDisplay-Medium", size: 22) {
            verseLabel.font = playfair
        }
        verseLabel.textColor = .white
        verseLabel.textAlignment = .center
        verseLabel.numberOfLines = 0
        verseLabel.lineBreakMode = .byWordWrapping

        let verseBlock = UIView()
        verseBlock.translatesAutoresizingMaskIntoConstraints = false
        verseBlock.backgroundColor = .clear
        scrollView.addSubview(verseBlock)
        verseBlock.addSubview(referenceLabel)
        verseBlock.addSubview(referenceUnderline)
        verseBlock.addSubview(verseLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            saveButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            saveButton.heightAnchor.constraint(equalToConstant: 40),

            shareButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -10),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40),

            referenceLabel.topAnchor.constraint(equalTo: verseBlock.topAnchor),
            referenceLabel.centerXAnchor.constraint(equalTo: verseBlock.centerXAnchor),
            referenceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: verseBlock.leadingAnchor, constant: 28),
            referenceLabel.trailingAnchor.constraint(lessThanOrEqualTo: verseBlock.trailingAnchor, constant: -28),

            referenceUnderline.topAnchor.constraint(equalTo: referenceLabel.bottomAnchor, constant: 6),
            referenceUnderline.centerXAnchor.constraint(equalTo: referenceLabel.centerXAnchor),
            referenceUnderline.widthAnchor.constraint(equalToConstant: 28),
            referenceUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.bottomAnchor.constraint(equalTo: watermarkLabel.topAnchor, constant: -10),
            dotsStack.heightAnchor.constraint(equalToConstant: 8),

            ctaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            ctaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            ctaButton.bottomAnchor.constraint(equalTo: dotsStack.topAnchor, constant: showsCTA ? -18 : 0),
            ctaButton.heightAnchor.constraint(equalToConstant: showsCTA ? 54 : 0),

            watermarkLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            watermarkLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            watermarkLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),

            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: showsCTA ? ctaButton.topAnchor : dotsStack.topAnchor, constant: -12),

            verseBlock.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            verseBlock.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            verseBlock.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            verseBlock.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            verseBlock.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            {
                let center = verseBlock.centerYAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerYAnchor)
                center.priority = UILayoutPriority(750)
                return center
            }(),

            verseLabel.topAnchor.constraint(equalTo: referenceUnderline.bottomAnchor, constant: 56),
            verseLabel.leadingAnchor.constraint(equalTo: verseBlock.leadingAnchor, constant: 28),
            verseLabel.trailingAnchor.constraint(equalTo: verseBlock.trailingAnchor, constant: -28),
            verseLabel.bottomAnchor.constraint(equalTo: verseBlock.bottomAnchor),

            scrollView.contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        watermarkLabel.text = todaysVerseAppName()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        // Stronger black dim so verse text stays readable over bright wallpapers.
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.42).cgColor,
            UIColor.black.withAlphaComponent(0.38).cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        gradient.locations = [0, 0.45, 1]
        gradientView.layer.addSublayer(gradient)
    }

    private func setupSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
    }

    private func applyVerse() {
        backgroundImageView.image = UIImage(named: verse.imageName)
        referenceLabel.text = verse.reference.uppercased()
        verseLabel.text = verse.text
        // Comfortable serif line height like the mockup.
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 6
        paragraph.lineBreakMode = .byWordWrapping
        let font = verseLabel.font ?? UIFont.systemFont(ofSize: 22)
        verseLabel.attributedText = NSAttributedString(
            string: verse.text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]
        )
        updateDots()
        updateCTA()
    }

    private func updateCTA() {
        let store = DailyJourneyStore.shared
        store.reload()
        if store.allStepsComplete {
            ctaButton.setTitle("Continue", for: .normal)
            ctaButton.backgroundColor = UIColor(red: 0.11, green: 0.48, blue: 0.24, alpha: 1)
        } else if store.memoryCompleted {
            ctaButton.setTitle("Start Reflection", for: .normal)
            ctaButton.backgroundColor = UIColor(red: 0.15, green: 0.39, blue: 0.92, alpha: 1)
        } else {
            ctaButton.setTitle("Start Memory Challenge", for: .normal)
            ctaButton.backgroundColor = UIColor(red: 0.15, green: 0.39, blue: 0.92, alpha: 1)
        }
    }

    private func updateDots() {
        dotsStack.arrangedSubviews.forEach {
            dotsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for i in 1...8 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            let isActive = verse.imageName == "S\(i).jpg"
            dot.backgroundColor = isActive ? .white : UIColor.white.withAlphaComponent(0.35)
            dot.layer.cornerRadius = 3.5
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 7),
                dot.heightAnchor.constraint(equalToConstant: 7)
            ])
            dotsStack.addArrangedSubview(dot)
        }
    }

    @objc private func closeTapped() {
        onClose?()
    }

    @objc private func nextTapped() {
        onForward?()
    }

    @objc private func continueTapped() {
        onContinue?()
    }

    /// Full-screen verse card: wallpaper, reference, verse, and the app-name watermark. Buttons stay off the image.
    func makeShareImage() -> UIImage {
        let chrome = [closeButton, shareButton, saveButton, ctaButton, dotsStack]
        chrome.forEach { $0.isHidden = true }
        watermarkLabel.text = todaysVerseAppName()
        view.layoutIfNeeded()
        let image = view.asImage()
        chrome.forEach { $0.isHidden = false }
        ctaButton.isHidden = !showsCTA
        view.layoutIfNeeded()
        return image
    }

    @objc private func shareTapped() {
        onShare?()
    }

    @objc private func saveTapped() {
        onSave?()
    }
}

func todaysVerseAppName() -> String {
    let saved = (UserDefaults.standard.string(forKey: "app_name") ?? "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    if !saved.isEmpty { return saved }
    let splash = APPNAME_SPLASH.trimmingCharacters(in: .whitespacesAndNewlines)
    if !splash.isEmpty { return splash }
    return APPNAME.trimmingCharacters(in: .whitespacesAndNewlines)
}

extension UIImage {
    /// App name along the bottom of the shared verse image only.
    func withAppNameWatermark() -> UIImage {
        let name = todaysVerseAppName()
        guard !name.isEmpty else { return self }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))

            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.45)
            shadow.shadowOffset = CGSize(width: 0, height: 1)
            shadow.shadowBlurRadius = 3
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .shadow: shadow
            ]
            let text = name as NSString
            let textSize = text.size(withAttributes: attributes)
            let origin = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: size.height - textSize.height - 36
            )
            text.draw(at: origin, withAttributes: attributes)
        }
    }
}
