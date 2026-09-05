//
//  ChallengeHubViewController.swift
//  NKJV Bible
//

import UIKit
import SwiftUI

final class ChallengeHubViewController: UIViewController {

    var isEmbeddedTab = false
    var sessionConfig: ChallengeSessionConfig?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        let root = ChallengeHubView(
            showBackButton: !isEmbeddedTab,
            sessionConfig: sessionConfig,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onOpenPremiumPaywall: { [weak self] in
                self?.openPaywall()
            },
            onOpenLegacyQuiz: { [weak self] in
                self?.openLegacyQuiz()
            },
            onOpenChallenge: { [weak self] kind, verse, config in
                self?.openChallenge(kind, verse: verse, config: config)
            }
        )

        let host = UIHostingController(rootView: root)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func openChallenge(_ kind: ChallengeKind, verse: ChallengeVerseContext, config: ChallengeSessionConfig?) {
        let root = ChallengeGameScreen(
            kind: kind,
            verse: verse,
            sessionConfig: config,
            onClose: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onOpenLegacyQuiz: { [weak self] in
                guard let self = self, let nav = self.navigationController else { return }
                nav.popViewController(animated: false)
                self.openLegacyQuiz()
            },
            onOpenPremiumPaywall: { [weak self] in
                self?.openPaywall()
            }
        )
        let host = ChallengePushedHostingController(rootView: root)
        host.view.backgroundColor = .white
        navigationController?.pushViewController(host, animated: true)
    }

    private func openLegacyQuiz() {
        let vc = kStoryboardQuizIphone.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openPaywall() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            if #available(iOS 15.0, *) {
                var swiftUIView = BibleSubscriptionView(isPresentedFromOnboarding: false)
                // Must dismiss the presented IAP — empty handler left the paywall stuck open.
                swiftUIView.dismissHandler = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                let hostingController = UIHostingController(rootView: swiftUIView)
                hostingController.modalPresentationStyle = .fullScreen
                present(hostingController, animated: true, completion: nil)
            } else {
                let vc = kStoryboardMainIphone.instantiateViewController(withIdentifier: "SubscrbViewController") as! SubscrbViewController
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
}

private final class ChallengePushedHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
