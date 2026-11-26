//
//  DualOnboarding.swift
//  NKJV Bible
//
//  Onboarding for the dual-Bible app (isDualBibleApp):
//  Splash -> Welcome -> Your goal -> Explain a verse -> Reminders -> paywall.
//  App icon, app name, verses, book names and language codes all come from the app / downloaded books.
//

import SwiftUI
import NaturalLanguage

// MARK: - Dynamic content

enum DualOnboardingData {

    struct Explanation {
        let context: String
        let today: String
    }

    struct Content {
        var nativeCode: String
        var secondCode: String
        var nativeName: String
        var secondName: String
        var psalmReference: String
        /// Book name for Psalm 23:1 from the second Bible (e.g. "Psalms 23:1").
        var psalmReferenceSecond: String
        var psalmNative: String
        var psalmSecond: String
        var philippiansReference: String
        var philippiansNative: String
        var philippiansSecond: String

        var hasTwoLanguages: Bool { nativeCode != secondCode }
    }

    /// Shown when the books are not on disk yet.
    static let fallback = Content(
        nativeCode: "EN",
        secondCode: "EN",
        nativeName: "English",
        secondName: "English",
        psalmReference: "Psalm 23:1",
        psalmReferenceSecond: "Psalm 23:1",
        psalmNative: "The Lord is my shepherd; I shall not want.",
        psalmSecond: "The Lord is my shepherd; I shall not want.",
        philippiansReference: "Philippians 4:13",
        philippiansNative: "I can do all things through Christ who strengthens me.",
        philippiansSecond: "I can do all things through Christ who strengthens me."
    )

    /// Explanation of Philippians 4:13 by language code. Other languages use English.
    private static let explanations: [String: Explanation] = [
        "EN": Explanation(
            context: "Paul wrote this from prison. In every circumstance, the strength of Christ is enough.",
            today: "Even on hard days, Christ gives the strength you need."
        ),
        "TA": Explanation(
            context: "பவுல் இதைச் சிறையிலிருந்து எழுதினார். எல்லா சூழலிலும் கிறிஸ்துவின் பெலன் போதும்.",
            today: "கடினமான நாட்களிலும் கிறிஸ்து தேவையான பெலனைத் தருவார்."
        ),
        "ID": Explanation(
            context: "Paulus menulis ini dari dalam penjara. Dalam segala keadaan, kekuatan Kristus selalu cukup.",
            today: "Bahkan di hari-hari yang sulit, Kristus memberikan kekuatan yang kita butuhkan."
        )
    ]

    static func explanation(forCode code: String) -> Explanation {
        explanations[code.uppercased()] ?? explanations["EN"]!
    }

    // MARK: Loading

    private static let psalmsIndex = 18
    private static let philippiansIndex = 49

    /// Reads both downloaded books. Never crashes: any missing file returns `fallback`.
    static func load() -> Content {
        let defaults = UserDefaults.standard
        let primary = defaults.string(forKey: "SelectedLanguage") ?? ""
        let second = defaults.string(forKey: "SecondLanguage") ?? ""
        guard !primary.isEmpty,
              let primaryBooks = bookNames(folder: primary),
              let primaryAudio = audio(folder: primary),
              psalmsIndex < primaryBooks.count, philippiansIndex < primaryBooks.count
        else { return fallback }

        let secondBooks = second.isEmpty ? nil : bookNames(folder: second)
        let secondAudio = second.isEmpty ? nil : audio(folder: second)

        let psalmNative = verse(in: primaryAudio, book: psalmsIndex, chapter: 23, verse: 1, dropShortHeading: true)
        let phNative = verse(in: primaryAudio, book: philippiansIndex, chapter: 4, verse: 13)
        guard let psalmNative, let phNative else { return fallback }

        var psalmSecond = psalmNative
        var phSecond = phNative
        if let secondAudio, let secondBooks, philippiansIndex < secondBooks.count {
            psalmSecond = verse(in: secondAudio, book: psalmsIndex, chapter: 23, verse: 1, dropShortHeading: true) ?? psalmNative
            phSecond = verse(in: secondAudio, book: philippiansIndex, chapter: 4, verse: 13) ?? phNative
        }

        let nativeCode = languageCode(of: psalmNative + " " + phNative)
        let secondCode = (secondAudio == nil) ? nativeCode : languageCode(of: psalmSecond + " " + phSecond)
        let psalmRef = "\(primaryBooks[psalmsIndex]) 23:1"
        let psalmRefSecond: String = {
            guard let secondBooks, psalmsIndex < secondBooks.count else { return psalmRef }
            return "\(secondBooks[psalmsIndex]) 23:1"
        }()

        return Content(
            nativeCode: nativeCode,
            secondCode: secondCode,
            nativeName: languageName(nativeCode),
            secondName: languageName(secondCode),
            psalmReference: psalmRef,
            psalmReferenceSecond: psalmRefSecond,
            psalmNative: psalmNative,
            psalmSecond: psalmSecond,
            philippiansReference: "\(primaryBooks[philippiansIndex]) 4:13",
            philippiansNative: phNative,
            philippiansSecond: phSecond
        )
    }

    private static func fileURL(folder: String, name: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("/\(folder)/\(name)")
    }

    private static func bookNames(folder: String) -> [String]? {
        guard let url = fileURL(folder: folder, name: "fullchapters.plist"),
              let data = try? Data(contentsOf: url),
              let list = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String]
        else { return nil }
        return list.map { $0.components(separatedBy: "-")[0] }
    }

    private static func audio(folder: String) -> [String: [String]]? {
        guard let url = fileURL(folder: folder, name: "audio.plist"),
              let data = try? Data(contentsOf: url),
              let dict = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: [String]]
        else { return nil }
        return dict
    }

    private static func verse(in audio: [String: [String]], book: Int, chapter: Int, verse: Int, dropShortHeading: Bool = false) -> String? {
        guard let chapters = audio[String(book + 1)], chapter >= 1, chapter - 1 < chapters.count, verse >= 1 else { return nil }
        let text = chapters[chapter - 1].withoutHtmlTags().deletingPrefix("\n")
        let verses = text.contains("@@@@\n") ? text.components(separatedBy: "@@@@\n") : text.components(separatedBy: "@@@@")
        guard verse - 1 < verses.count else { return nil }
        var value = verses[verse - 1]

        // Some books mark a heading with @0 and the verse text with @1.
        if let marker = value.range(of: "@1") {
            value = String(value[marker.upperBound...])
        }
        value = value.replacingOccurrences(of: "@\\d+", with: "", options: .regularExpression)
        value = value.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        value = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // Psalm 23:1 can start with the psalm title ("A psalm of David."). Remove a short title sentence.
        if dropShortHeading, let dot = value.range(of: ". ") {
            let first = String(value[..<dot.lowerBound])
            let rest = String(value[dot.upperBound...]).trimmingCharacters(in: .whitespaces)
            if first.split(separator: " ").count <= 5, rest.split(separator: " ").count >= 4 {
                value = rest
            }
        }
        return value.isEmpty ? nil : value
    }

    private static func languageCode(of sample: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(sample)
        let raw = recognizer.dominantLanguage?.rawValue ?? "en"
        let short = raw.split(separator: "-").first.map(String.init) ?? raw
        return short.uppercased()
    }

    private static func languageName(_ code: String) -> String {
        Locale(identifier: "en").localizedString(forLanguageCode: code.lowercased()) ?? code
    }
}

// MARK: - App icon

enum DualAppIcon {
    /// App icon for UI / Lock Screen Now Playing. AppIcon.appiconset is not always
    /// loadable via `UIImage(named:)`, so we also read the PNG files copied into the bundle.
    static var image: UIImage? {
        if let cached = cachedImage { return cached }
        let loaded = loadFromBundle()
        cachedImage = loaded
        return loaded
    }

    private static var cachedImage: UIImage?

    private static func loadFromBundle() -> UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String] {
            for name in files.reversed() {
                if let img = UIImage(named: name) { return img }
                for suffix in ["@3x", "@2x", ""] {
                    let fileName = suffix.isEmpty ? name : "\(name)\(suffix)"
                    if let path = Bundle.main.path(forResource: fileName, ofType: "png"),
                       let img = UIImage(contentsOfFile: path) {
                        return img
                    }
                }
            }
        }

        // Fallback: generated icon / marketing PNG shipped in the app bundle root.
        for fileName in ["AppIcon60x60@2x", "AppIcon60x60@3x", "AppIcon60x60", "Alkitab 1024"] {
            if let path = Bundle.main.path(forResource: fileName, ofType: "png"),
               let img = UIImage(contentsOfFile: path) {
                return img
            }
        }
        return nil
    }
}

// MARK: - Theme and shared pieces

enum DualTheme {
    static let gold = Color(hex: "F0C867")
    static let goldDeep = Color(hex: "E0A93A")
    static let goldInk = Color(hex: "1E1406")
    static let eyebrow = Color(hex: "EBCB84")
    static let dim = Color(hex: "AEB9DA")
    static let cream = Color(hex: "FFF8E8")
    static let creamEnd = Color(hex: "F8EBCB")
    static let creamBrown = Color(hex: "8A6414")
    static let creamInk = Color(hex: "2A2010")
    static let creamSoft = Color(hex: "6E5B34")

    static func scale(isPad: Bool, height: CGFloat) -> CGFloat {
        if isPad { return 1.3 }
        return height < 700 ? 0.88 : 1.0
    }
}

struct DualBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1D3399"), Color(hex: "142574"), Color(hex: "0C1550")],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(hex: "4262D8").opacity(0.55), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 460
            )
            RadialGradient(
                colors: [Color(hex: "3A3560").opacity(0.75), Color.clear],
                center: UnitPoint(x: 1.0, y: 1.0),
                startRadius: 0,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
    }
}

private struct DualAppIconView: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let icon = DualAppIcon.image {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(hex: "8F1A1A")
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundColor(DualTheme.gold)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }
}

private struct DualGoldButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(DualTheme.goldInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: "F8DE9A"), DualTheme.goldDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .shadow(color: DualTheme.gold.opacity(isEnabled ? 0.35 : 0.12), radius: 16, x: 0, y: 6)
        }
        .opacity(isEnabled ? 1 : 0.45)
        .disabled(!isEnabled)
    }
}

private struct DualGhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.white.opacity(0.78))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}

private struct DualDots: View {
    let current: Int
    var total: Int = 5

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? DualTheme.gold : Color.white.opacity(0.28))
                    .frame(width: index == current ? 26 : 8, height: 8)
            }
        }
    }
}

private struct DualSerifTitle: View {
    let lines: [String]
    let size: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: size, weight: .bold, design: .serif))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DualGoldToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            Capsule()
                .fill(
                    configuration.isOn
                        ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "F8DE9A"), DualTheme.goldDeep], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.18))
                )
                .frame(width: 56, height: 34)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                        .offset(x: configuration.isOn ? 11 : -11)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Cream verse card used on the Welcome and Explain screens.
private struct DualVerseCard: View {
    let reference: String
    let topText: String
    let tag: String
    let bottomText: String
    var showDivider: Bool
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(reference)
                .font(.system(size: 14 * scale, weight: .bold))
                .tracking(0.6)
                .foregroundColor(DualTheme.creamBrown)
                .padding(.bottom, 8 * scale)

            Text(topText)
                .font(.system(size: 25 * scale, weight: .medium))
                .lineSpacing(3)
                .foregroundColor(DualTheme.creamInk)
                .fixedSize(horizontal: false, vertical: true)

            if showDivider {
                Rectangle()
                    .fill(DualTheme.creamBrown.opacity(0.25))
                    .frame(height: 1)
                    .padding(.vertical, 14 * scale)
            } else {
                Spacer().frame(height: 22 * scale)
            }

            Text(tag.uppercased())
                .font(.system(size: 12 * scale, weight: .heavy))
                .tracking(0.8)
                .foregroundColor(DualTheme.creamBrown)
                .padding(.horizontal, 10 * scale)
                .padding(.vertical, 4 * scale)
                .background(Capsule().fill(Color(hex: "EBD7A6")))
                .padding(.bottom, 8 * scale)

            Text(bottomText)
                .font(.system(size: 17 * scale, weight: .regular, design: .serif))
                .lineSpacing(3)
                .foregroundColor(DualTheme.creamSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22 * scale)
        .padding(.vertical, 20 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28 * scale, style: .continuous)
                .fill(LinearGradient(colors: [DualTheme.cream, DualTheme.creamEnd], startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28 * scale, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)
    }
}

// MARK: - Root (splash, then the flow)

struct DualOnboardingRoot: View {
    // The splash is already shown by SplashVc (see showDualSplash), so the flow starts at Welcome.
    @State private var showSplash = false
    @State private var content = DualOnboardingData.fallback

    var body: some View {
        ZStack {
            if showSplash {
                DualSplashView()
                    .transition(.opacity)
            } else {
                NavigationView {
                    DualWelcomeView(content: content)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let loaded = DualOnboardingData.load()
                DispatchQueue.main.async { content = loaded }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                withAnimation(.easeInOut(duration: 0.35)) { showSplash = false }
            }
        }
    }
}

// MARK: - 0. Splash

struct DualSplashView: View {
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        let s: CGFloat = isPad ? 1.4 : 1.0
        ZStack {
            DualBackground()
            VStack(spacing: 0) {
                DualAppIconView(size: 168 * s)
                    .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 14)
                Text(APPNAME_SPLASH)
                    .font(.system(size: 36 * s, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                    .padding(.horizontal, 24)
                    .padding(.top, 34 * s)
                Text("Two Bibles. One verse.")
                    .font(.system(size: 17 * s))
                    .foregroundColor(DualTheme.dim)
                    .padding(.top, 10 * s)
            }
            .offset(y: -20)
        }
    }
}

// MARK: - 1. Welcome

private struct DualWelcomeView: View {
    let content: DualOnboardingData.Content
    @State private var swapped = false
    @State private var navigateForward = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        GeometryReader { geo in
            let s = DualTheme.scale(isPad: isPad, height: geo.size.height)
            let maxWidth: CGFloat = isPad ? 600 : .infinity
            ZStack {
                DualBackground()
                VStack(spacing: 0) {
                    GeometryReader { area in
                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                    HStack(spacing: 12 * s) {
                        DualAppIconView(size: 46 * s)
                        Text(APPNAME_SPLASH)
                            .font(.system(size: 22 * s, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 14 * s)

                    DualSerifTitle(lines: ["Two Bibles.", "One verse."], size: 46 * s)
                        .padding(.horizontal, 30)
                        .padding(.top, 22 * s)

                    Text("Read your language and \(content.secondName) side by side.\nUnderstand every verse. Remember it.")
                        .font(.system(size: 16 * s))
                        .lineSpacing(4)
                        .foregroundColor(DualTheme.dim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 30)
                        .padding(.top, 12 * s)

                    Spacer(minLength: 12 * s)

                    DualVerseCard(
                        reference: swapped ? content.psalmReferenceSecond : content.psalmReference,
                        topText: swapped ? content.psalmSecond : content.psalmNative,
                        tag: swapped ? content.nativeName : content.secondName,
                        bottomText: swapped ? content.psalmNative : content.psalmSecond,
                        showDivider: true,
                        scale: s
                    )
                    .rotationEffect(.degrees(-2.2))
                    .padding(.horizontal, 28)

                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) { swapped.toggle() } }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 24 * s, weight: .bold))
                            .foregroundColor(DualTheme.goldInk)
                            .frame(width: 66 * s, height: 66 * s)
                            .background(
                                Circle().fill(
                                    LinearGradient(colors: [Color(hex: "F8DE9A"), DualTheme.goldDeep], startPoint: .top, endPoint: .bottom)
                                )
                            )
                            .overlay(Circle().stroke(Color(hex: "1D3399"), lineWidth: 4))
                            .shadow(color: DualTheme.gold.opacity(0.35), radius: 14, x: 0, y: 6)
                    }
                    .offset(y: -12 * s)
                    .padding(.bottom, -12 * s)

                    Text("Reading · Quiz · Streak · AI help")
                        .font(.system(size: 15 * s, weight: .semibold))
                        .foregroundColor(DualTheme.dim)
                        .padding(.top, 22 * s)
                        .padding(.bottom, 12 * s)
                    }
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: area.size.height)
                    }
                    }

                    DualGoldButton(title: "Begin") { navigateForward = true }
                        .padding(.horizontal, 30)
                        .frame(maxWidth: maxWidth)

                    DualDots(current: 0)
                        .padding(.top, 20 * s)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 18))
                }

                NavigationLink(destination: DualGoalView(content: content), isActive: $navigateForward) { EmptyView() }
                    .hidden()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - 2. Your goal

private struct DualGoalView: View {
    let content: DualOnboardingData.Content
    @State private var selected = 0
    @State private var navigateForward = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private struct Option {
        enum Icon { case symbol(String), text(String) }
        let icon: Icon
        let title: String
        let subtitle: String
    }

    private var options: [Option] {
        [
            Option(icon: .symbol("arrow.left.arrow.right"), title: "Compare two translations", subtitle: "Your language next to \(content.secondName)"),
            Option(icon: .symbol("sparkle"), title: "Understand the Bible deeper", subtitle: "Plain-word help for every verse"),
            Option(icon: .text("Aa"), title: "Grow my \(content.secondName)", subtitle: "Read both and grow your \(content.secondName)"),
            Option(icon: .text("🔥"), title: "Build a daily reading habit", subtitle: "A little every day"),
            Option(icon: .text("···"), title: "Something else", subtitle: "Just exploring for now")
        ]
    }

    var body: some View {
        GeometryReader { geo in
            let s = DualTheme.scale(isPad: isPad, height: geo.size.height)
            let maxWidth: CGFloat = isPad ? 600 : .infinity
            ZStack {
                DualBackground()
                VStack(spacing: 0) {
                    GeometryReader { area in
                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: { UIKitNavigationHelper.navigateToIAPView() }) {
                            Text("Skip →")
                                .font(.system(size: 15 * s, weight: .semibold))
                                .foregroundColor(DualTheme.dim)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 14 * s)

                    DualSerifTitle(lines: ["What brings", "you here?"], size: 40 * s)
                        .padding(.horizontal, 30)
                        .padding(.top, 16 * s)

                    Text("One tap. You can change it later.")
                        .font(.system(size: 16 * s))
                        .foregroundColor(DualTheme.dim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top, 8 * s)

                    VStack(spacing: 10 * s) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            optionRow(option, index: index, scale: s)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20 * s)
                    .padding(.bottom, 12 * s)
                    }
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: area.size.height, alignment: .top)
                    }
                    }

                    DualGoldButton(title: "Continue") {
                        UserDefaults.standard.set(selected, forKey: "DualOnboardingGoal")
                        navigateForward = true
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: maxWidth)

                    DualDots(current: 1)
                        .padding(.top, 20 * s)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 18))
                }

                NavigationLink(destination: DualExplainView(content: content), isActive: $navigateForward) { EmptyView() }
                    .hidden()
            }
        }
        .navigationBarHidden(true)
    }

    private func optionRow(_ option: Option, index: Int, scale s: CGFloat) -> some View {
        let isSelected = index == selected
        return Button(action: { selected = index }) {
            HStack(spacing: 14 * s) {
                iconTile(option.icon, scale: s)
                VStack(alignment: .leading, spacing: 3 * s) {
                    Text(option.title)
                        .font(.system(size: 17 * s, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(option.subtitle)
                        .font(.system(size: 14 * s))
                        .foregroundColor(DualTheme.dim)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 6)
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                        .opacity(isSelected ? 0 : 1)
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "F8DE9A"), DualTheme.goldDeep], startPoint: .top, endPoint: .bottom))
                        .opacity(isSelected ? 1 : 0)
                    Image(systemName: "checkmark")
                        .font(.system(size: 13 * s, weight: .heavy))
                        .foregroundColor(DualTheme.goldInk)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 30 * s, height: 30 * s)
            }
            .padding(.horizontal, 14 * s)
            .padding(.vertical, 13 * s)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24 * s, style: .continuous)
                    .fill(Color.white.opacity(isSelected ? 0.14 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24 * s, style: .continuous)
                    .stroke(isSelected ? DualTheme.gold : Color.white.opacity(0.18), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func iconTile(_ icon: Option.Icon, scale s: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14 * s, style: .continuous)
                .fill(Color.white.opacity(0.14))
            switch icon {
            case .symbol(let name):
                Image(systemName: name)
                    .font(.system(size: 20 * s, weight: .semibold))
                    .foregroundColor(DualTheme.gold)
            case .text(let value):
                Text(value)
                    .font(.system(size: 19 * s, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 50 * s, height: 50 * s)
    }
}

// MARK: - 3. Explain a verse

private struct DualExplainView: View {
    let content: DualOnboardingData.Content
    @State private var showNative = true
    @State private var navigateForward = false
    /// Set when "Explain This Verse" is tapped. Same flow as the earlier onboarding: ask the AI, wait up to 3 seconds,
    /// then use the built-in text, and type the result on.
    @State private var revealed = false
    @State private var isLoading = false
    @State private var aiText: [String: String] = [:]
    @State private var fallbackKeys: Set<String> = []
    @State private var waitingKey: String?
    @State private var typingID = UUID()

    private static let aiTimeout: TimeInterval = 3

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private var activeKey: String { showNative ? "native" : "second" }

    private var activeCode: String { showNative ? content.nativeCode : content.secondCode }

    private var builtIn: DualOnboardingData.Explanation {
        DualOnboardingData.explanation(forCode: activeCode)
    }

    var body: some View {
        GeometryReader { geo in
            let s = DualTheme.scale(isPad: isPad, height: geo.size.height)
            let maxWidth: CGFloat = isPad ? 600 : .infinity
            ZStack {
                DualBackground()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Text("UNDERSTAND WITH CLARITY")
                                .font(.system(size: 13 * s, weight: .heavy))
                                .tracking(1.6)
                                .foregroundColor(DualTheme.eyebrow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 30)
                                .padding(.top, 14 * s)

                            DualSerifTitle(lines: ["What Does", "This Verse Mean?"], size: 38 * s)
                                .padding(.horizontal, 30)
                                .padding(.top, 8 * s)

                            DualVerseCard(
                                reference: content.philippiansReference,
                                topText: content.philippiansNative,
                                tag: content.secondName,
                                bottomText: content.philippiansSecond,
                                showDivider: false,
                                scale: s * 0.9
                            )
                            .padding(.horizontal, 30)
                            .padding(.top, 18 * s)

                            Button(action: showExplanation) {
                                Text("✦ Explain This Verse")
                                    .font(.system(size: 18 * s, weight: .bold))
                                    .foregroundColor(DualTheme.gold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 17 * s)
                                    .overlay(Capsule().stroke(DualTheme.gold, lineWidth: 1.5))
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 14 * s)

                            if revealed {
                                explanationPanel(scale: s)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 14 * s)
                            }

                            Text("Any verse. Any chapter. Ask in your language or in English.")
                                .font(.system(size: 14 * s, weight: .semibold))
                                .foregroundColor(DualTheme.dim)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                                .padding(.top, 10 * s)
                                .padding(.bottom, 12 * s)
                        }
                        .frame(maxWidth: maxWidth)
                        .frame(maxWidth: .infinity)
                    }

                    DualGoldButton(title: "Continue") { navigateForward = true }
                        .padding(.horizontal, 30)
                        .frame(maxWidth: maxWidth)

                    DualDots(current: 2)
                        .padding(.top, 20 * s)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 18))
                }

                NavigationLink(destination: DualRemindersView(content: content), isActive: $navigateForward) { EmptyView() }
                    .hidden()
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: prefetch)
    }

    // MARK: AI explanation (same service and flow as the earlier onboarding)

    private func verseText(forKey key: String) -> String {
        key == "native" ? content.philippiansNative : content.philippiansSecond
    }

    private func languageCode(forKey key: String) -> String {
        (key == "native" ? content.nativeCode : content.secondCode).lowercased()
    }

    /// Short body, as before: at most about 180 characters, ending on a full stop when possible.
    private static func mediumBody(_ text: String) -> String {
        let raw = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.count <= 180 { return raw }
        let prefix = String(raw.prefix(180))
        if let period = prefix.lastIndex(where: { $0 == "." || $0 == "।" }) {
            return String(prefix[...period])
        }
        if let space = prefix.lastIndex(of: " ") {
            return String(prefix[..<space]) + "…"
        }
        return prefix + "…"
    }

    /// Ask the AI while the user reads the verse. The reply is cached, so Explain shows it at once.
    private func prefetch() {
        request(key: "native")
        if content.hasTwoLanguages { request(key: "second") }
    }

    private func request(key: String) {
        guard aiText[key] == nil else { return }
        OpenAIExplanationService.shared.fetchExplanation(
            verseReference: content.philippiansReference,
            verseText: verseText(forKey: key),
            bibleVersion: APPNAME,
            responseLanguageCode: languageCode(forKey: key)
        ) { result in
            DispatchQueue.main.async {
                guard !fallbackKeys.contains(key) else { return }
                switch result {
                case .success(let text):
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    aiText[key] = Self.mediumBody(trimmed)
                    if waitingKey == key && isLoading {
                        isLoading = false
                        waitingKey = nil
                        typingID = UUID()
                    }
                case .failure:
                    if waitingKey == key && isLoading { useBuiltIn(for: key) }
                }
            }
        }
    }

    private func useBuiltIn(for key: String) {
        fallbackKeys.insert(key)
        if waitingKey == key {
            waitingKey = nil
            isLoading = false
            typingID = UUID()
        }
    }

    private func showExplanation() {
        let key = activeKey
        revealed = true
        if aiText[key] != nil || fallbackKeys.contains(key) {
            isLoading = false
            waitingKey = nil
            typingID = UUID()
            return
        }
        isLoading = true
        waitingKey = key
        request(key: key)
        // No AI reply in time: show the built-in text.
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.aiTimeout) {
            guard isLoading, waitingKey == key else { return }
            useBuiltIn(for: key)
        }
    }

    private func switchLanguage(native: Bool) {
        guard showNative != native else { return }
        showNative = native
        if revealed { showExplanation() }
    }

    private func explanationPanel(scale s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("EXPLANATION")
                    .font(.system(size: 14 * s, weight: .heavy))
                    .tracking(1.2)
                    .foregroundColor(DualTheme.dim)
                Spacer()
                if content.hasTwoLanguages {
                    languageToggle(scale: s)
                }
            }

            if isLoading {
                HStack(spacing: 10) {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Getting explanation…")
                        .font(.system(size: 16 * s))
                        .foregroundColor(DualTheme.dim)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18 * s)
                .padding(.bottom, 6 * s)
            } else {
                DualExplainTyping(
                    contextText: aiText[activeKey] ?? builtIn.context,
                    todayText: builtIn.today,
                    scale: s
                )
                .id(typingID)
                .padding(.top, 2 * s)
            }
        }
        .padding(18 * s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28 * s, style: .continuous)
                .fill(Color.white.opacity(0.09))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28 * s, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func languageToggle(scale s: CGFloat) -> some View {
        HStack(spacing: 0) {
            toggleSegment(content.nativeCode, selected: showNative, scale: s) { switchLanguage(native: true) }
            toggleSegment(content.secondCode, selected: !showNative, scale: s) { switchLanguage(native: false) }
        }
        .padding(3)
        .background(Capsule().fill(Color.white.opacity(0.12)))
    }

    private func toggleSegment(_ title: String, selected: Bool, scale s: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15 * s, weight: .heavy))
                .foregroundColor(selected ? DualTheme.goldInk : DualTheme.dim)
                .padding(.horizontal, 14 * s)
                .padding(.vertical, 6 * s)
                .background(
                    Capsule().fill(
                        selected
                            ? LinearGradient(colors: [Color(hex: "F8DE9A"), DualTheme.goldDeep], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
                    )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Types the explanation on, same type-on as the earlier onboarding. The full text is kept (hidden)
/// so the card does not grow while typing.
private struct DualExplainTyping: View {
    let contextText: String
    let todayText: String
    let scale: CGFloat

    @State private var typedCount = 0
    @State private var clock = Clock()

    private var total: Int { contextText.count + todayText.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section(title: "CONTEXT", body: contextText, offset: 0)
            section(title: "WHAT IT MEANS TODAY", body: todayText, offset: contextText.count)
        }
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
        .onAppear(perform: startTyping)
    }

    private func section(title: String, body: String, offset: Int) -> some View {
        VStack(alignment: .leading, spacing: 4 * scale) {
            Text(title)
                .font(.system(size: 13 * scale, weight: .heavy))
                .tracking(0.8)
                .foregroundColor(DualTheme.eyebrow)
                .padding(.top, 14 * scale)
            ZStack(alignment: .topLeading) {
                Text(body).hidden()
                Text(typedPart(body, offset: offset))
            }
            .font(.system(size: 19 * scale))
            .lineSpacing(3)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func typedPart(_ text: String, offset: Int) -> String {
        let count = min(max(typedCount - offset, 0), text.count)
        return String(text.prefix(count))
    }

    private func startTyping() {
        guard !clock.started else { return }
        clock.started = true
        let total = self.total
        let timer = Timer(timeInterval: 0.012, repeats: true) { timer in
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                typedCount = min(typedCount + 4, total)
            }
            if typedCount >= total {
                timer.invalidate()
                clock.timer = nil
            }
        }
        clock.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private final class Clock {
        var timer: Timer?
        var started = false
    }
}

// MARK: - 4. Reminders

private struct DualRemindersView: View {
    let content: DualOnboardingData.Content
    @State private var morningOn = true
    @State private var eveningOn = true
    @State private var morningHour = 7
    @State private var eveningHour = 20
    @State private var isSaving = false

    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    private static func timeText(_ hour: Int) -> String {
        let suffix = hour < 12 ? "AM" : "PM"
        let shown = hour % 12 == 0 ? 12 : hour % 12
        return "\(shown):00 \(suffix)"
    }

    var body: some View {
        GeometryReader { geo in
            let s = DualTheme.scale(isPad: isPad, height: geo.size.height)
            let maxWidth: CGFloat = isPad ? 600 : .infinity
            ZStack {
                DualBackground()
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Text("STAY ON TRACK")
                                .font(.system(size: 13 * s, weight: .heavy))
                                .tracking(1.6)
                                .foregroundColor(DualTheme.eyebrow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 30)
                                .padding(.top, 14 * s)

                            DualSerifTitle(lines: ["Keep God's", "Word Close"], size: 40 * s)
                                .padding(.horizontal, 30)
                                .padding(.top, 8 * s)

                            Text("Your verse, waiting for you each morning and evening.")
                                .font(.system(size: 16 * s))
                                .lineSpacing(3)
                                .foregroundColor(DualTheme.dim)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 30)
                                .padding(.top, 10 * s)

                            Text("WHAT YOU'LL RECEIVE")
                                .font(.system(size: 12.5 * s, weight: .heavy))
                                .tracking(1.8)
                                .foregroundColor(DualTheme.eyebrow)
                                .padding(.top, 20 * s)

                            VStack(spacing: 12 * s) {
                                previewCard(
                                    title: "Morning verse",
                                    time: Self.timeText(morningHour),
                                    message: "\(content.psalmReference) · \(content.psalmNative)",
                                    isEnabled: morningOn,
                                    scale: s
                                )
                                previewCard(
                                    title: "Evening verse",
                                    time: Self.timeText(eveningHour),
                                    message: "A short verse to end your day in peace.",
                                    isEnabled: eveningOn,
                                    scale: s
                                )
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 12 * s)

                            VStack(spacing: 0) {
                                timeRow(title: "Morning verse", hour: $morningHour, hours: Array(5...11), isOn: $morningOn, divider: true, scale: s)
                                timeRow(title: "Evening verse", hour: $eveningHour, hours: Array(17...23), isOn: $eveningOn, divider: false, scale: s)
                            }
                            .padding(.horizontal, 48)
                            .padding(.top, 14 * s)

                            Text("Two gentle reminders a day. Nothing more, unless you ask.")
                                .font(.system(size: 13 * s))
                                .foregroundColor(DualTheme.dim)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.top, 8 * s)
                                .padding(.bottom, 12 * s)
                        }
                        .frame(maxWidth: maxWidth)
                        .frame(maxWidth: .infinity)
                    }

                    VStack(spacing: 4) {
                        DualGoldButton(
                            title: "Yes, send my verses",
                            isEnabled: !isSaving && (morningOn || eveningOn)
                        ) { saveAndContinue() }
                            .padding(.horizontal, 30)
                        DualGhostButton(title: "Maybe later") { UIKitNavigationHelper.navigateToIAPView() }
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: maxWidth)

                    DualDots(current: 3)
                        .padding(.top, 10 * s)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 18))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func previewCard(title: String, time: String, message: String, isEnabled: Bool, scale s: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 14 * s) {
            DualAppIconView(size: 46 * s)
            VStack(alignment: .leading, spacing: 4 * s) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.system(size: 17 * s, weight: .bold))
                        .foregroundColor(.white)
                    Spacer(minLength: 8)
                    Text(time)
                        .font(.system(size: 14 * s))
                        .foregroundColor(DualTheme.dim)
                }
                Text(message)
                    .font(.system(size: 16 * s))
                    .lineSpacing(2)
                    .foregroundColor(Color.white.opacity(0.9))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14 * s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24 * s, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24 * s, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .opacity(isEnabled ? 1 : 0.35)
        .allowsHitTesting(isEnabled)
    }

    private func timeRow(title: String, hour: Binding<Int>, hours: [Int], isOn: Binding<Bool>, divider: Bool, scale s: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8 * s) {
                    Text(title)
                        .font(.system(size: 19 * s, weight: .bold))
                        .foregroundColor(.white)
                    Menu {
                        ForEach(hours, id: \.self) { value in
                            Button(Self.timeText(value)) { hour.wrappedValue = value }
                        }
                    } label: {
                        Text("\(Self.timeText(hour.wrappedValue)) ▾")
                            .font(.system(size: 14 * s, weight: .bold))
                            .foregroundColor(DualTheme.gold)
                            .padding(.horizontal, 14 * s)
                            .padding(.vertical, 6 * s)
                            .background(Capsule().fill(DualTheme.gold.opacity(0.12)))
                            .overlay(Capsule().stroke(DualTheme.gold.opacity(0.7), lineWidth: 1))
                    }
                }
                Spacer(minLength: 8)
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .toggleStyle(DualGoldToggleStyle())
            }
            .padding(.vertical, 14 * s)
            if divider {
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
            }
        }
    }

    // MARK: Actions

    private func saveAndContinue() {
        guard !isSaving else { return }
        isSaving = true
        OnboardingNotificationScheduler.applyFromOnboarding(
            dailyVerse: morningOn,
            journey: eveningOn,
            memory: false,
            prayer: false
        ) {
            applyChosenTimes()
            isSaving = false
            UIKitNavigationHelper.navigateToIAPView()
        }
    }

    /// Runs only when the user allowed notifications: puts the chosen morning / evening times into Settings.
    private func applyChosenTimes() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: OnboardingNotificationScheduler.PrefKey.settingsTimesApplied) else { return }
        defaults.set(String(format: "%02d:00", morningHour), forKey: "Shift 1")
        defaults.set(String(format: "%02d:00", eveningHour), forKey: "Shift 3")
        defaults.set(morningOn, forKey: "Shift1ON")
        defaults.set(eveningOn, forKey: "Shift3ON")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.onRegisterPushNotification()
        }
    }
}
