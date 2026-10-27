//
//  ReaderMoreSheet.swift
//  NKJV Bible
//
//  Bottom-bar More sheet: Profile, Bible Companion, Settings.
//

import UIKit

final class ReaderMoreSheet: UIView {

    var onProfile: (() -> Void)?
    var onCompanion: (() -> Void)?
    var onSettings: (() -> Void)?

    private weak var tabView: UIView?
    private let dimView = UIView()
    private let sheetView = UIView()
    private var isClosing = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    func show(in parent: UIView, above tab: UIView) {
        tabView = tab
        frame = parent.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(self)
        parent.bringSubviewToFront(tab)
        layoutIfNeeded()
        let travel = sheetView.bounds.height + 12
        sheetView.transform = CGAffineTransform(translationX: 0, y: travel)
        dimView.alpha = 0
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut) {
            self.sheetView.transform = .identity
            self.dimView.alpha = 1
        }
    }

    func dismissSheet() {
        guard superview != nil, !isClosing else { return }
        isClosing = true
        UIView.animate(withDuration: 0.22, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.sheetView.bounds.height + 20)
            self.dimView.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let tab = tabView, let parent = superview else { return }
        frame = parent.bounds
        let tabFrame = tab.convert(tab.bounds, to: self)
        dimView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(0, tabFrame.minY))
        let width = bounds.width
        let height: CGFloat = 235
        sheetView.bounds.size = CGSize(width: width, height: height)
        sheetView.center = CGPoint(x: width / 2, y: tabFrame.minY - height / 2)
        sheetView.layoutIfNeeded()
    }

    private func build() {
        let stored = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        let night = stored.toHexString() == BGNightMode.toHexString()
        let accent = night ? UIColor.white : stored

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimTapped)))
        addSubview(dimView)

        sheetView.backgroundColor = night ? DarkModeColor : .white
        sheetView.layer.cornerRadius = 22
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        addSubview(sheetView)

        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = UIColor(white: night ? 0.55 : 0.78, alpha: 1)
        grabber.layer.cornerRadius = 2.5

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "More"
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textColor = accent
        title.textAlignment = .center

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        // Profile commented out.
        // stack.addArrangedSubview(makeRow(title: "Profile", symbol: "person.fill", accent: accent, night: night, action: #selector(profileTapped)))
        stack.addArrangedSubview(makeRow(title: "Bible Companion", symbol: "bubble.left.and.bubble.right.fill", accent: accent, night: night, action: #selector(companionTapped)))
        stack.addArrangedSubview(makeRow(title: "Settings", symbol: "gearshape.fill", accent: accent, night: night, action: #selector(settingsTapped)))

        sheetView.addSubview(grabber)
        sheetView.addSubview(title)
        sheetView.addSubview(stack)

        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 10),
            grabber.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 5),
            title.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 14),
            title.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -18)
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sheetView.addGestureRecognizer(pan)
    }

    private func makeRow(title: String, symbol: String, accent: UIColor, night: Bool, action: Selector) -> UIControl {
        let card = UIControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = accent.withAlphaComponent(night ? 0.12 : 0.10)
        card.layer.cornerRadius = 16
        card.accessibilityLabel = title
        card.addTarget(self, action: action, for: .touchUpInside)
        card.heightAnchor.constraint(equalToConstant: 68).isActive = true

        let well = UIView()
        well.translatesAutoresizingMaskIntoConstraints = false
        well.backgroundColor = accent.withAlphaComponent(night ? 0.16 : 0.14)
        well.layer.cornerRadius = 20
        well.isUserInteractionEnabled = false

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = accent
        label.isUserInteractionEnabled = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = accent
        chevron.contentMode = .scaleAspectFit
        chevron.isUserInteractionEnabled = false

        card.addSubview(well)
        well.addSubview(icon)
        card.addSubview(label)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            well.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            well.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            well.widthAnchor.constraint(equalToConstant: 40),
            well.heightAnchor.constraint(equalToConstant: 40),
            icon.centerXAnchor.constraint(equalTo: well.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: well.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: well.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])
        return card
    }

    @objc private func dimTapped() {
        dismissSheet()
    }

    @objc private func profileTapped() {
        onProfile?()
    }

    @objc private func companionTapped() {
        onCompanion?()
    }

    @objc private func settingsTapped() {
        onSettings?()
    }

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self).y
        switch pan.state {
        case .changed:
            sheetView.transform = CGAffineTransform(translationX: 0, y: max(0, translation))
        case .ended, .cancelled:
            if translation > 70 {
                dismissSheet()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.sheetView.transform = .identity
                }
            }
        default:
            break
        }
    }
}
