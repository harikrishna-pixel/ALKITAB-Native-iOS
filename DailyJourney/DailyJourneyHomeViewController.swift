//
//  DailyJourneyHomeViewController.swift
//  NKJV Bible
//

import UIKit
import SwiftUI
import Photos

/// Hosts the Daily Journey Home UI inside the existing Reader shell.
final class DailyJourneyHomeViewController: UIViewController {

    private var hostingController: UIHostingController<DailyJourneyHomeView>?
    private weak var journeyModalHost: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)

        DispatchQueue.main.async {
            NotificationList_data.sharedInstance.UpdateDailyVerse()
        }

        embedHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DailyJourneyStore.shared.reload()
    }

    private func embedHome() {
        let root = makeRootView()
        let host = UIHostingController(rootView: root)
        host.view.backgroundColor = .clear
        hostingController = host
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }

    private func makeRootView() -> DailyJourneyHomeView {
        DailyJourneyHomeView(
            store: .shared,
            onContinueReading: { [weak self] in
                self?.continueReading()
            },
            onOpenPrayerWall: { [weak self] in
                self?.openPrayerWall()
            },
            onShareVerse: { [weak self] verse in
                self?.shareVerse(verse)
            },
            onBookmarkVerse: { [weak self] verse, completion in
                self?.bookmarkVerse(verse, completion: completion)
            },
            onOpenVerseFullscreen: { [weak self] verse, onUpdated in
                self?.presentVerseFullscreen(verse: verse, onUpdated: onUpdated)
            },
            onOpenMemoryChallenge: { [weak self] verse in
                self?.presentMemoryChallenge(verse: verse, proceedToReflection: false)
            },
            onOpenReflection: { [weak self] verse in
                self?.presentReflection(verse: verse)
            },
            onPresentStreakComplete: { [weak self] in
                guard let self = self, self.journeyModalHost == nil else { return }
                self.presentStreakComplete()
            }
        )
    }

    private func topModalPresenter() -> UIViewController {
        let root = sharePresenter()
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    private func presentFromOutsideNavigateframe(
        _ viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        viewController.modalPresentationStyle = .fullScreen
        journeyModalHost = viewController
        topModalPresenter().present(viewController, animated: animated, completion: completion)
    }

    private func dismissJourneyModal(completion: (() -> Void)? = nil) {
        if let host = journeyModalHost {
            journeyModalHost = nil
            host.dismiss(animated: true, completion: completion)
            return
        }
        topModalPresenter().presentedViewController?.dismiss(animated: true, completion: completion)
    }

    private func presentVerseFullscreen(
        verse: DailyVerseSnapshot,
        onUpdated: @escaping (DailyVerseSnapshot) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            var current = verse
            let vc = DailyVerseFullscreenViewController(verse: current)
            vc.onClose = { [weak vc] in
                vc?.dismiss(animated: true, completion: nil)
            }
            vc.onForward = { [weak vc] in
                current.cycleWallpaper()
                DailyJourneyStore.shared.markVerseCompleted()
                vc?.update(with: current)
                onUpdated(current)
            }
            vc.onContinue = { [weak self, weak vc] in
                let store = DailyJourneyStore.shared
                store.reload()
                let verseSnapshot = current
                if store.allStepsComplete {
                    vc?.dismiss(animated: true, completion: nil)
                } else if store.memoryCompleted {
                    vc?.dismiss(animated: true) {
                        self?.presentReflection(verse: verseSnapshot)
                    }
                } else {
                    vc?.dismiss(animated: true) {
                        self?.presentMemoryChallenge(
                            verse: verseSnapshot,
                            proceedToReflection: !store.reflectionCompleted
                        )
                    }
                }
            }

            self.presentFromOutsideNavigateframe(vc)
        }
    }

    private func presentMemoryChallenge(verse: DailyVerseSnapshot, proceedToReflection: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let root = NavigationView {
                MemoryChallengeView(
                    verse: verse,
                    store: .shared,
                    onDone: { [weak self] in
                        self?.dismissJourneyModal()
                    },
                    onProceed: proceedToReflection ? { [weak self] in
                        self?.dismissJourneyModal {
                            self?.presentReflection(verse: verse)
                        }
                    } : nil
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())

            let host = UIHostingController(rootView: root)
            self.presentFromOutsideNavigateframe(host)
        }
    }

    private func presentReflection(verse: DailyVerseSnapshot) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let shouldAutoShowStreak = !DailyJourneyStore.shared.allStepsComplete

            let root = NavigationView {
                ReflectionView(
                    verse: verse,
                    store: .shared,
                    onDone: { [weak self] in
                        self?.dismissJourneyModal {
                            if shouldAutoShowStreak, DailyJourneyStore.shared.allStepsComplete {
                                self?.presentStreakComplete()
                            }
                        }
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())

            let host = UIHostingController(rootView: root)
            self.presentFromOutsideNavigateframe(host)
        }
    }

    private func presentStreakComplete() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let root = NavigationView {
                StreakCompleteView(store: .shared) { [weak self] in
                    self?.dismissJourneyModal()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())

            let host = UIHostingController(rootView: root)
            self.presentFromOutsideNavigateframe(host)
        }
    }

    private func continueReading() {
        let book = UserDefaults.standard.string(forKey: "BookName") ?? DefaultBookName
        let chapter = max(UserDefaults.standard.integer(forKey: "BookChapter"), 1)
        let title = "\(book) \(chapter):1"
        UserDefaults.standard.set(title, forKey: "readdata")
        UserDefaults.standard.set("1", forKey: "AppOpenFirst")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            App_Protocol.delegateReaderSource?.navigateToSelectedVerse()
        }
    }

    private func openPrayerWall() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = PrayerWallViewController()
            let presenter = presentingController()
            if let nav = presenter.navigationController {
                nav.pushViewController(vc, animated: true)
            } else if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                presenter.present(vc, animated: true)
            }
        } else {
            presentingController().view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }

    // MARK: - Same share / save behavior as HomeController

    private func shareVerse(_ verse: DailyVerseSnapshot) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let image = self.renderVerseCardImage(verse)
            let safeName = self.safeFileName(from: verse.reference)
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(safeName).png")
            let pngData = image.pngData()
            try? pngData?.write(to: fileURL)

            // Match HomeController.sharedImage
            let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController
            vc.VerseImgData = pngData
            vc.VerseStr = verse.text.isEmpty ? " " : verse.text
            vc.Bookname = verse.reference.isEmpty ? "Today's Verse" : verse.reference
            vc.VerseImgName = safeName
            vc.ShareVerseImageURL = [fileURL]
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve

            // Present from this VC if possible (same as HomeController); otherwise climb to Reader / window.
            let presenter = self.sharePresenter()
            if presenter.presentedViewController != nil {
                presenter.dismiss(animated: false) {
                    presenter.present(vc, animated: true, completion: nil)
                }
            } else {
                presenter.present(vc, animated: true, completion: nil)
            }
        }
    }

    private func bookmarkVerse(_ verse: DailyVerseSnapshot, completion: @escaping (Bool) -> Void) {
        let image = renderVerseCardImage(verse)
        let presenter = sharePresenter()

        let handleStatus: (PHAuthorizationStatus) -> Void = { newStatus in
            DispatchQueue.main.async {
                if newStatus == .authorized || newStatus == .limited {
                    CustomPhotoAlbum.sharedInstance.saveImage(image: image)
                    presenter.view.makeToast("Image Saved Successfully!", duration: 2.0, position: .center)
                    completion(true)
                } else {
                    SettingAlert.GallaryPermission(SorceVc: presenter)
                    completion(false)
                }
            }
        }

        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: handleStatus)
        } else {
            PHPhotoLibrary.requestAuthorization(handleStatus)
        }
    }

    /// Prefer a full-screen host so share sheet is not clipped by Navigateframe masksToBounds.
    private func sharePresenter() -> UIViewController {
        var walker: UIViewController? = self
        while let current = walker {
            if let nav = current.navigationController {
                return nav
            }
            walker = current.parent
        }
        if let window = view.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           var root = window.rootViewController {
            while let presented = root.presentedViewController {
                root = presented
            }
            if let nav = root as? UINavigationController {
                return nav.visibleViewController ?? nav
            }
            return root
        }
        return self
    }

    private func presentingController() -> UIViewController {
        sharePresenter()
    }

    private func safeFileName(from reference: String) -> String {
        let trimmed = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: " ", with: "_")
        return cleaned.isEmpty ? "Todays_Verse" : cleaned
    }

    private func renderVerseCardImage(_ verse: DailyVerseSnapshot) -> UIImage {
        // Match HomeController: snapshot a full square card (wallpaper fills entire image + text overlay).
        // Previous Core Graphics path filled the lower half with opaque black, so shares looked "half-hidden".
        let side: CGFloat = 1080
        let container = UIView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        container.backgroundColor = UIColor(red: 0.11, green: 0.18, blue: 0.42, alpha: 1)

        let bgView = UIImageView(frame: container.bounds)
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.image = UIImage(named: verse.imageName) ?? UIImage(named: HomeVerseImage)
        container.addSubview(bgView)

        let gradientHost = UIView(frame: CGRect(x: 0, y: side * 0.42, width: side, height: side * 0.58))
        gradientHost.isUserInteractionEnabled = false
        container.addSubview(gradientHost)
        let gradient = CAGradientLayer()
        gradient.frame = gradientHost.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.72).cgColor
        ]
        gradient.locations = [0, 0.35, 1]
        gradientHost.layer.insertSublayer(gradient, at: 0)

        let padding: CGFloat = 64
        let contentWidth = side - padding * 2

        let refLabel = UILabel()
        refLabel.text = verse.reference
        refLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        refLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        refLabel.numberOfLines = 2
        refLabel.lineBreakMode = .byWordWrapping

        let textLabel = UILabel()
        textLabel.text = verse.text
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 42, weight: .medium)
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping

        let refHeight = ceil(refLabel.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude)).height)
        let textHeight = ceil(textLabel.sizeThatFits(CGSize(width: contentWidth, height: side * 0.42)).height)
        let blockHeight = refHeight + 16 + textHeight
        let blockTop = side - padding - blockHeight

        refLabel.frame = CGRect(x: padding, y: blockTop, width: contentWidth, height: refHeight)
        textLabel.frame = CGRect(x: padding, y: blockTop + refHeight + 16, width: contentWidth, height: textHeight)
        container.addSubview(refLabel)
        container.addSubview(textLabel)

        container.setNeedsLayout()
        container.layoutIfNeeded()
        return container.asImage()
    }
}
