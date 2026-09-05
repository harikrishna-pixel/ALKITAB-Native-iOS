//
//  DailyVerseFullscreenViewController.swift
//  NKJV Bible
//

import UIKit

final class DailyVerseFullscreenViewController: UIViewController {

    var onClose: (() -> Void)?
    var onForward: (() -> Void)?
    var onContinue: (() -> Void)?

    private var verse: DailyVerseSnapshot

    private let backgroundImageView = UIImageView()
    private let gradientView = UIView()
    private let closeButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let ctaButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let referenceLabel = UILabel()
    private let referenceUnderline = UIView()
    private let verseLabel = UILabel()
    private let dotsStack = UIStackView()

    init(verse: DailyVerseSnapshot) {
        self.verse = verse
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

        // Next — rounded pill, top-right (mockup)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)), for: .normal)
        nextButton.semanticContentAttribute = .forceRightToLeft
        nextButton.tintColor = .white
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nextButton.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        nextButton.layer.cornerRadius = 18
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 12)
        nextButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)

        // Reference — top center, uppercase + underline (mockup)
        referenceLabel.translatesAutoresizingMaskIntoConstraints = false
        referenceLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        referenceLabel.textColor = .white
        referenceLabel.textAlignment = .center
        referenceLabel.numberOfLines = 2
        view.addSubview(referenceLabel)

        referenceUnderline.translatesAutoresizingMaskIntoConstraints = false
        referenceUnderline.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        view.addSubview(referenceUnderline)

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
        view.addSubview(ctaButton)

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
        scrollView.addSubview(verseLabel)

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

            nextButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 36),

            referenceLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor, constant: -4),
            referenceLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 12),
            referenceLabel.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -12),

            referenceUnderline.topAnchor.constraint(equalTo: referenceLabel.bottomAnchor, constant: 6),
            referenceUnderline.centerXAnchor.constraint(equalTo: referenceLabel.centerXAnchor),
            referenceUnderline.widthAnchor.constraint(equalToConstant: 28),
            referenceUnderline.heightAnchor.constraint(equalToConstant: 1.5),

            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            dotsStack.heightAnchor.constraint(equalToConstant: 8),

            ctaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            ctaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            ctaButton.bottomAnchor.constraint(equalTo: dotsStack.topAnchor, constant: -18),
            ctaButton.heightAnchor.constraint(equalToConstant: 54),

            scrollView.topAnchor.constraint(equalTo: referenceUnderline.bottomAnchor, constant: 28),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -24),

            verseLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 36),
            verseLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 28),
            verseLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -28),
            verseLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            verseLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -56)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        // Soft dim so wallpaper stays visible; text stays readable (mockup style).
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.28).cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor,
            UIColor.black.withAlphaComponent(0.45).cgColor
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
            ctaButton.setTitle("Today's Journey Complete", for: .normal)
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
}
