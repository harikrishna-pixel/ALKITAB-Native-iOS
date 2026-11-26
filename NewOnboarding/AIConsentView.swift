//
//  AIConsentView.swift
//  NKJV Bible
//
//  Consent sheet shown before Ask AI, explanations and summaries.
//  The two languages come from the books on the device, not from fixed names.
//

import SwiftUI

enum AIAnswerLanguage {
    struct Option: Equatable {
        let code: String
        let name: String
        var short: String { String(code.prefix(2)).uppercased() }
    }

    private static let consentKey = "AIConsentGranted"
    private static let codeKey = "AIAnswerLanguageCode"

    static var granted: Bool {
        get { UserDefaults.standard.bool(forKey: consentKey) }
        set { UserDefaults.standard.set(newValue, forKey: consentKey) }
    }

    /// The book's own language first, then the second book when it is a different language.
    static func options() -> [Option] {
        let content = DualOnboardingData.load()
        var list = [Option(code: content.nativeCode, name: endonym(content.nativeCode, fallback: content.nativeName))]
        if content.hasTwoLanguages {
            list.append(Option(code: content.secondCode, name: endonym(content.secondCode, fallback: content.secondName)))
        }
        return list
    }

    static var selected: Option {
        let list = options()
        let saved = UserDefaults.standard.string(forKey: codeKey) ?? ""
        return list.first { $0.code == saved } ?? list[0]
    }

    static func select(_ option: Option) {
        UserDefaults.standard.set(option.code, forKey: codeKey)
    }

    static var other: Option? {
        let current = selected
        return options().first { $0.code != current.code }
    }

    /// "Answers in தமிழ். Switch to English anytime." One language drops the switch sentence.
    static var statusLine: String {
        let current = selected
        if let other = other {
            return "Answers in \(current.name). Switch to \(other.name) anytime."
        }
        return "Answers in \(current.name)."
    }

    private static func endonym(_ code: String, fallback: String) -> String {
        let id = code.lowercased()
        if let name = Locale(identifier: id).localizedString(forLanguageCode: id), !name.isEmpty {
            return name
        }
        return fallback.isEmpty ? code : fallback
    }
}

enum AIConsentPresenter {
    static func confirm(from host: UIViewController, onAllow: @escaping () -> Void, onDecline: @escaping () -> Void) {
        _ = onDecline // Call-site API retained; "Not now" removed from the sheet.
        if AIAnswerLanguage.granted {
            onAllow()
            return
        }
        let root = AIConsentSheet(
            onAllow: {
                AIAnswerLanguage.granted = true
                host.dismiss(animated: true, completion: onAllow)
            }
        )
        let controller = UIHostingController(rootView: root)
        controller.view.backgroundColor = .white
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            let width = host.view.bounds.width > 0 ? host.view.bounds.width : UIScreen.main.bounds.width
            if #available(iOS 16.0, *) {
                controller.sizingOptions = .intrinsicContentSize
                let fitted = controller.sizeThatFits(in: CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)).height
                let bottom = host.view.window?.safeAreaInsets.bottom ?? host.view.safeAreaInsets.bottom
                // Hug the content, then add only the home-indicator inset so the sheet covers the bottom.
                let height = max(fitted, 1) + bottom
                sheet.detents = [.custom { _ in height }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        host.present(controller, animated: true)
    }
}

struct AIConsentSheet: View {
    var onAllow: () -> Void

    @State private var picked: String = AIAnswerLanguage.selected.code
    private var options: [AIAnswerLanguage.Option] { AIAnswerLanguage.options() }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "2F5BFF"))
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "E7EEFF")))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Before you use AI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    Text("Ask AI, explanations and summaries")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 18)

            VStack(alignment: .leading, spacing: 12) {
                bullet("AI is optional. Nothing is sent until you tap an AI button.")
                bullet("Your question and the verse or chapter text are sent to a third-party AI service. No account details are sent.")
                bullet("AI can make mistakes. Compare answers with Scripture.")
            }
            .padding(.top, 18)

            Text("ANSWER LANGUAGE")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.6)
                .foregroundColor(Color(hex: "8A93A3"))
                .padding(.top, 22)

            HStack(spacing: 0) {
                ForEach(options, id: \.code) { option in
                    Button(action: {
                        picked = option.code
                        AIAnswerLanguage.select(option)
                    }) {
                        Text(option.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(picked == option.code ? .white : Color(hex: "1A1A1A"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(picked == option.code ? Color(hex: "2F5BFF") : Color(hex: "EEF1F6"))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(Capsule().fill(Color(hex: "EEF1F6")))
            .padding(.top, 10)

            Button(action: onAllow) {
                Text("Allow AI")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color(hex: "2F5BFF")))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 22)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.white)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "2F5BFF"))
                .frame(width: 7, height: 7)
                .padding(.top, 6)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "1F2937"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
