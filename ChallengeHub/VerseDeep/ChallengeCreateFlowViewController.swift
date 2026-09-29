//
//  ChallengeCreateFlowViewController.swift
//  NKJV Bible
//

import UIKit
import SwiftUI

final class ChallengeCreateFlowViewController: UIViewController {

    var isEmbeddedTab = false
    var sessionConfig: ChallengeSessionConfig?
    var verseContext: ChallengeVerseContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        let root = ChallengeCreateFlowView(
            showBackButton: !isEmbeddedTab,
            sessionConfig: sessionConfig,
            verseContext: verseContext,
            onUnlock: { [weak self] done in
                self?.presentUnlock(then: done)
            },
            onBack: { [weak self] in
                if let nav = self?.navigationController, nav.viewControllers.count > 1 {
                    nav.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true)
                }
            },
            onMyChallenges: { [weak self] in
                self?.openMyChallenges()
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

    private func presentUnlock(then done: @escaping () -> Void) {
        if #available(iOS 15.0, *) {
            var paywall = BibleSubscriptionView(isPresentedFromOnboarding: false)
            paywall.dismissHandler = { [weak self] in
                self?.dismiss(animated: true) {
                    done()
                }
            }
            let host = UIHostingController(rootView: paywall)
            host.modalPresentationStyle = .fullScreen
            present(host, animated: true)
        } else {
            done()
        }
    }

    private func openMyChallenges() {
        if NetworkManager.sharedInstance.isConnectedToInternet() {
            let vc = ChallengeAttemptsViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            view.makeToast("No internet connection", duration: 2.0, position: .bottom)
        }
    }
}
