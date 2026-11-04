//
//  AIUsageExtras.swift
//  NKJV Bible
//
//  First-time AI disclaimer, "free uses remaining" lines, home banner, quiz note and the Try Now reminder.
//

import UIKit
import SwiftUI
import MessageUI
import Toast_Swift

// MARK: - Remaining text

extension AIUsageLimiter {

    /// "1 of 1 free explanation remaining today". Nil for unlimited plans.
    func remainingText(_ feature: AIUsageFeature, compact: Bool = false) -> String? {
        guard !hasUnlimitedPlan else { return nil }
        let left = freeUsesLeft(feature)
        let limit = feature.dailyFreeLimit
        switch feature {
        case .aiChat:
            return "\(left) of \(limit) daily free AI messages remaining"
        case .explanation:
            return "\(left) of \(limit) free explanation remaining today"
        case .chapterSummary:
            return compact ? "\(left) of \(limit) free summary left today" : "\(left) of \(limit) free chapter summary remaining today"
        case .quiz:
            return "\(left) of \(limit) free quiz generation remaining today"
        }
    }

    func remainingFraction(_ feature: AIUsageFeature) -> CGFloat {
        CGFloat(freeUsesLeft(feature)) / CGFloat(max(1, feature.dailyFreeLimit))
    }
}

// MARK: - Progress bar (UIKit)

final class AIUsageBarView: UIView {

    var fraction: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    var fillColor: UIColor = PrimaryColor {
        didSet {
            fill.backgroundColor = fillColor
            backgroundColor = fillColor.withAlphaComponent(0.18)
        }
    }

    private let fill = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        isUserInteractionEnabled = false
        addSubview(fill)
        fillColor = PrimaryColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        let width = bounds.width * min(max(fraction, 0), 1)
        fill.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        fill.layer.cornerRadius = bounds.height / 2
    }
}

/// Centered "X of Y remaining" text with a thin bar under it. Hidden for unlimited plans.
final class AIRemainingLineView: UIView {

    let feature: AIUsageFeature
    private let compact: Bool
    private let label = UILabel()
    private let bar = AIUsageBarView()

    init(feature: AIUsageFeature, fontSize: CGFloat, compact: Bool = false, barHeight: CGFloat = 3) {
        self.feature = feature
        self.compact = compact
        super.init(frame: .zero)
        isUserInteractionEnabled = false

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        addSubview(label)

        bar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bar)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),

            bar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: max(2, barHeight)),
            bar.centerXAnchor.constraint(equalTo: centerXAnchor),
            bar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            bar.heightAnchor.constraint(equalToConstant: barHeight)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refresh(tint: UIColor, textColor: UIColor) {
        let text = AIUsageLimiter.shared.remainingText(feature, compact: compact)
        isHidden = text == nil
        label.text = text
        label.textColor = textColor
        bar.fillColor = tint
        bar.fraction = AIUsageLimiter.shared.remainingFraction(feature)
    }
}

// MARK: - Remaining line (SwiftUI)

struct AIRemainingLine: View {
    let feature: AIUsageFeature
    var tint: Color
    var textColor: Color = Color(hex: "66758C")

    var body: some View {
        if let text = AIUsageLimiter.shared.remainingText(feature) {
            VStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(tint.opacity(0.18))
                        Capsule()
                            .fill(tint)
                            .frame(width: geo.size.width * AIUsageLimiter.shared.remainingFraction(feature))
                    }
                }
                .frame(width: 120, height: 4)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - First-time disclaimer

enum AIDisclaimer {

    private static let acceptedKey = "AIDisclaimerAccepted"
    private static weak var shown: UIViewController?
    private static var isPresenting = false
    private static var isFinishing = false
    /// Latest Continue action — kept if present is busy so Get Explanation still opens after the sheet closes.
    private static var pendingProceed: (() -> Void)?
    /// Pause after dismiss so the Continue finger-up cannot hit the new sheet's dim and close it instantly.
    private static let proceedDelay: TimeInterval = 0.45

    static var isAccepted: Bool {
        UserDefaults.standard.bool(forKey: acceptedKey)
    }

    /// Shown once before the first AI chat, explanation, summary or quiz. `onContinue` runs after "I Understand".
    static func present(onContinue: @escaping () -> Void) {
        DispatchQueue.main.async {
            // Race: accepted while we were waiting — open the feature immediately.
            if isAccepted {
                onContinue()
                return
            }
            // Disclaimer already up or mid-transition — keep the latest proceed for Continue.
            if shown != nil || isPresenting || isFinishing {
                pendingProceed = onContinue
                return
            }
            presentNow(proceed: onContinue, retry: true)
        }
    }

    private static func presentNow(proceed: @escaping () -> Void, retry: Bool) {
        if shown != nil || isPresenting || isFinishing {
            pendingProceed = proceed
            return
        }
        guard let top = OnboardingAuthManager.topViewController() else {
            toast("Please try again")
            return
        }
        // Another modal is still opening or closing — wait once, then try again.
        if top.isBeingPresented || top.isBeingDismissed || top.transitionCoordinator != nil {
            guard retry else {
                toast("Please try again")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                presentNow(proceed: proceed, retry: false)
            }
            return
        }

        isPresenting = true
        pendingProceed = nil
        let box = AIDisclaimerHostBox()
        let host = UIHostingController(rootView: AIDisclaimerView(
            onClose: {
                finish(box: box, then: nil)
            },
            onContinue: {
                UserDefaults.standard.set(true, forKey: acceptedKey)
                let next = pendingProceed ?? proceed
                pendingProceed = nil
                finish(box: box, then: next)
            }
        ))
        // Keep the reading screen underneath so dismissing does not re-run its appear work.
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .coverVertical
        host.view.backgroundColor = .white
        box.host = host
        shown = host
        top.view.endEditing(true)
        top.present(host, animated: true) {
            isPresenting = false
            // Present was refused — unlock and retry once.
            if host.presentingViewController == nil {
                clearShown()
                box.host = nil
                if retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        presentNow(proceed: proceed, retry: false)
                    }
                } else {
                    toast("Please try again")
                }
            }
        }
    }

    private static func finish(box: AIDisclaimerHostBox, then proceed: (() -> Void)?) {
        guard !isFinishing else {
            if let proceed = proceed { pendingProceed = proceed }
            return
        }
        isFinishing = true
        isPresenting = true
        clearShown()
        let host = box.host

        let runProceed = {
            isPresenting = false
            isFinishing = false
            box.host = nil
            let action = pendingProceed ?? proceed
            pendingProceed = nil
            guard let action = action else { return }
            // Let the modal finish tearing down and the Continue touch end before opening the sheet.
            DispatchQueue.main.asyncAfter(deadline: .now() + proceedDelay) {
                action()
            }
        }

        if let host = host {
            let presenter = host.presentingViewController
            if presenter != nil || host.isBeingPresented || topPresents(host) {
                // Dismiss from the presenter when possible — more reliable than host.dismiss during teardown.
                let target = presenter ?? host
                target.dismiss(animated: true) {
                    DispatchQueue.main.async(execute: runProceed)
                }
                return
            }
        }
        DispatchQueue.main.async(execute: runProceed)
    }

    private static func topPresents(_ host: UIViewController) -> Bool {
        OnboardingAuthManager.topViewController() === host
    }

    private static func clearShown() {
        shown = nil
    }

    private static func toast(_ message: String) {
        OnboardingAuthManager.topViewController()?.view.makeToast(message, duration: 2.0, position: .top)
    }
}

private final class AIDisclaimerHostBox {
    /// Strong while the disclaimer is on screen so Continue can always dismiss and continue.
    var host: UIViewController?
}

private struct AIDisclaimerView: View {
    var onClose: () -> Void
    var onContinue: () -> Void

    private var theme: Color { DailyJourneyTheme.color }
    private let ink = Color(hex: "12315C")

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ink)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 54))
                            .foregroundColor(theme)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme)
                            .offset(y: -44)
                    }
                    .frame(height: 100)
                    .padding(.top, 20)

                    Text("About AI Bible Assistance")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ink)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Our AI helps you explore Scripture through chat, verse explanations, chapter summaries and quizzes.")
                        Text("AI-generated content may contain errors, including incorrect interpretations, quiz questions, or answers.")
                        Text("Please verify important information and quiz answers against the Bible. AI is a study companion, not a replacement for Scripture.")
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "4A5568"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme)
                        Text("Use AI with discernment.\nAlways refer to the Bible.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(theme.opacity(0.1)))
                    .padding(.top, 24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            Button(action: onContinue) {
                Text("I Understand & Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 14).fill(theme))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Home banner

/// One dismissible card on Home while a free AI use is left today. Rotates between chat, explanation and summary.
struct AIHomeBanner: View {
    var onOpen: (AIUsageFeature) -> Void

    @State private var hiddenDay = UserDefaults.standard.string(forKey: AIHomeBanner.hiddenKey) ?? ""

    private static let hiddenKey = "AIHomeBannerHiddenDay"
    private static var today: String { Date().string(format: "dd-MM-yyyy") }

    private var feature: AIUsageFeature? {
        // Pro (ONBOARDING_OPTION "2") does not use AI chat — hide this home card entirely.
        guard usesOldOnboarding else { return nil }
        let limiter = AIUsageLimiter.shared
        guard hiddenDay != Self.today, !limiter.hasUnlimitedPlan else { return nil }
        let options: [AIUsageFeature] = [.aiChat, .explanation, .chapterSummary]
        let open = options.filter { limiter.freeUsesLeft($0) > 0 }
        guard !open.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return open[day % open.count]
    }

    var body: some View {
        if let feature = feature {
            let style = Self.style(for: feature)
            HStack(spacing: 12) {
                Button(action: { onOpen(feature) }) {
                    HStack(spacing: 12) {
                        Image(systemName: style.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(RoundedRectangle(cornerRadius: 10).fill(style.tint))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(style.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(hex: "12315C"))
                            Text(style.detail)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "5E6B80"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: hideForToday) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "8B95A7"))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(style.tint.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(style.tint.opacity(0.18), lineWidth: 1))
        }
    }

    private func hideForToday() {
        UserDefaults.standard.set(Self.today, forKey: Self.hiddenKey)
        hiddenDay = Self.today
    }

    private static func style(for feature: AIUsageFeature) -> (icon: String, title: String, detail: String, tint: Color) {
        switch feature {
        case .explanation:
            return ("book.fill", "Explore a verse more deeply", "Your free explanation is waiting today.", Color(hex: "1C7A3D"))
        case .chapterSummary:
            return ("doc.text.fill", "Get a chapter summary", "Your free chapter summary is available today.", Color(hex: "6B4FBB"))
        default:
            return ("bubble.left.and.bubble.right.fill", "Your free AI chat is waiting", "Ask a question about Scripture today.", DailyJourneyTheme.color)
        }
    }
}

// MARK: - Generated quiz note

struct AIQuizNote: View {
    let reference: String
    let question: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "2F6FEB"))
                Text("AI-generated quiz. Questions and answers may contain errors. Please verify with Scripture.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "3A4A63"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: { AIQuizReport.send(reference: reference, question: question) }) {
                HStack(spacing: 6) {
                    Image(systemName: "flag.fill")
                    Text("Report an Error")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "D70015"))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "EAF1FF")))
    }
}

enum AIQuizReport {

    static func send(reference: String, question: String) {
        guard let top = OnboardingAuthManager.topViewController() else { return }
        let subject = "Quiz error report"
        let body = "Verse: \(reference)\nQuestion: \(question)\n\nWhat is wrong:\n"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = SendMail.shared
            mail.setToRecipients([FEEDBACKMAIL])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            top.present(mail, animated: true)
            return
        }
        let encode: (String) -> String = { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
        guard let url = URL(string: "mailto:\(FEEDBACKMAIL)?subject=\(encode(subject))&body=\(encode(body))") else { return }
        UIApplication.shared.open(url) { opened in
            guard !opened else { return }
            top.view.makeToast("Please set up Mail to report an error", duration: 2.0, position: .top)
        }
    }
}

// MARK: - Try Now reminder

/// Small bottom card on the reading screen: "Your free explanation is waiting". At most once a day.
enum AIFeatureReminder {

    private static let dayKey = "AIExplanationReminderDay"
    private static weak var card: UIView?

    /// `host` is the reading screen's view, so the verse menu and explanation sheet open above the card.
    static func showIfNeeded(in host: UIView, below sibling: UIView? = nil, reference: String, onTry: @escaping () -> Void) {
        let limiter = AIUsageLimiter.shared
        let today = Date().string(format: "dd-MM-yyyy")
        guard card == nil,
              UserDefaults.standard.string(forKey: dayKey) != today,
              !limiter.hasUnlimitedPlan,
              limiter.freeUsesLeft(.explanation) > 0 else { return }
        UserDefaults.standard.set(today, forKey: dayKey)

        let theme = UserDefaults.standard.color(forKey: "AppThemeColor") ?? PrimaryColor
        let accent = theme == BGNightMode ? PrimaryColor : theme

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 14
        view.layer.shadowOffset = CGSize(width: 0, height: 4)

        let icon = UIImageView(image: UIImage(systemName: "book.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        icon.contentMode = .center
        icon.backgroundColor = accent.withAlphaComponent(0.12)
        icon.layer.cornerRadius = 12
        icon.clipsToBounds = true

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Your free explanation is waiting"
        title.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        title.textColor = UIColor(red: 0.07, green: 0.19, blue: 0.36, alpha: 1)
        title.numberOfLines = 0

        let detail = UILabel()
        detail.translatesAutoresizingMaskIntoConstraints = false
        detail.text = "Tap Try Now to explore \(reference) deeper."
        detail.font = UIFont.systemFont(ofSize: 13)
        detail.textColor = UIColor(white: 0.4, alpha: 1)
        detail.numberOfLines = 0

        let close = UIButton(type: .system)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = UIColor(white: 0.55, alpha: 1)

        let tryButton = UIButton(type: .system)
        tryButton.translatesAutoresizingMaskIntoConstraints = false
        tryButton.setTitle("Try Now", for: .normal)
        tryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tryButton.setTitleColor(.white, for: .normal)
        tryButton.backgroundColor = accent
        tryButton.layer.cornerRadius = 12

        [icon, title, detail, close, tryButton].forEach { view.addSubview($0) }
        if let sibling = sibling, sibling.superview === host {
            host.insertSubview(view, belowSubview: sibling)
        } else {
            host.addSubview(view)
        }

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -16),
            view.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            icon.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            icon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            icon.widthAnchor.constraint(equalToConstant: 44),
            icon.heightAnchor.constraint(equalToConstant: 44),

            close.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            close.widthAnchor.constraint(equalToConstant: 36),
            close.heightAnchor.constraint(equalToConstant: 36),

            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -4),

            detail.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            detail.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            detail.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -4),

            tryButton.topAnchor.constraint(greaterThanOrEqualTo: detail.bottomAnchor, constant: 14),
            tryButton.topAnchor.constraint(greaterThanOrEqualTo: icon.bottomAnchor, constant: 14),
            tryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tryButton.heightAnchor.constraint(equalToConstant: 46),
            tryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])

        let actions = AIFeatureReminderActions(card: view, onTry: onTry)
        close.addTarget(actions, action: #selector(AIFeatureReminderActions.closeTapped), for: .touchUpInside)
        tryButton.addTarget(actions, action: #selector(AIFeatureReminderActions.tryTapped), for: .touchUpInside)
        objc_setAssociatedObject(view, &AIFeatureReminderActions.key, actions, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        card = view

        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 40)
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
            view.transform = .identity
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak view] in
            guard let view = view else { return }
            hide(view)
        }
    }

    static func hide(_ view: UIView) {
        UIView.animate(withDuration: 0.25, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 40)
        }, completion: { _ in
            view.removeFromSuperview()
        })
    }
}

private final class AIFeatureReminderActions: NSObject {
    static var key: UInt8 = 0
    private weak var card: UIView?
    private let onTry: () -> Void

    init(card: UIView, onTry: @escaping () -> Void) {
        self.card = card
        self.onTry = onTry
    }

    @objc func closeTapped() {
        guard let card = card else { return }
        AIFeatureReminder.hide(card)
    }

    @objc func tryTapped() {
        if let card = card {
            AIFeatureReminder.hide(card)
        }
        onTry()
    }
}
