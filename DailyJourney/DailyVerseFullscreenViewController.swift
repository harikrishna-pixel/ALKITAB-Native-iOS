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

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        closeButton.layer.cornerRadius = 22
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.semanticContentAttribute = .forceRightToLeft
        nextButton.tintColor = .white
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nextButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        nextButton.layer.cornerRadius = 20
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 12)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(nextButton)

        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle("Start Memory Challenge", for: .normal)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        ctaButton.backgroundColor = UIColor(red: 0.11, green: 0.27, blue: 0.70, alpha: 1)
        ctaButton.layer.cornerRadius = 27
        ctaButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(ctaButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        let textStack = UIStackView(arrangedSubviews: [referenceLabel, verseLabel])
        textStack.axis = .vertical
        textStack.spacing = 14
        textStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textStack)

        referenceLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        referenceLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        referenceLabel.numberOfLines = 0

        verseLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        verseLabel.textColor = .white
        verseLabel.numberOfLines = 0

        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        dotsStack.axis = .horizontal
        dotsStack.spacing = 7
        dotsStack.alignment = .center
        dotsStack.distribution = .equalSpacing
        view.addSubview(dotsStack)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            nextButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 40),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),

            ctaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            ctaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            ctaButton.bottomAnchor.constraint(equalTo: dotsStack.topAnchor, constant: -16),
            ctaButton.heightAnchor.constraint(equalToConstant: 54),

            textStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            textStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            textStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            textStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),

            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            dotsStack.heightAnchor.constraint(equalToConstant: 10)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradientView.layer.addSublayer(gradient)
    }

    private func setupSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
    }

    private func applyVerse() {
        backgroundImageView.image = UIImage(named: verse.imageName)
        referenceLabel.text = verse.reference
        verseLabel.text = verse.text
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
            ctaButton.backgroundColor = UIColor(red: 0.11, green: 0.27, blue: 0.70, alpha: 1)
        } else {
            ctaButton.setTitle("Start Memory Challenge", for: .normal)
            ctaButton.backgroundColor = UIColor(red: 0.11, green: 0.27, blue: 0.70, alpha: 1)
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
