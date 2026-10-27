//
//  ChallengeCreateFlowViewController.swift
//  NKJV Bible
//

import UIKit
import SwiftUI
import Toast_Swift

final class ChallengeCreateFlowViewController: UIViewController {

    var isEmbeddedTab = false
    var sessionConfig: ChallengeSessionConfig?
    var verseContext: ChallengeVerseContext?

    private var flowHost: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        showGateOrFlow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func showGateOrFlow() {
        let root = AnyView(makeCreateFlow())
        if let flowHost = flowHost {
            flowHost.rootView = root
            return
        }
        let host = UIHostingController(rootView: root)
        flowHost = host
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

    private func makeCreateFlow() -> ChallengeCreateFlowView {
        ChallengeCreateFlowView(
            showBackButton: !isEmbeddedTab,
            sessionConfig: sessionConfig,
            verseContext: verseContext,
            onUnlock: { [weak self] done in
                self?.presentUnlock(then: done)
            },
            onBack: { [weak self] in
                self?.leave()
            },
            onMyChallenges: { [weak self] in
                self?.openMyChallenges()
            }
        )
    }

    private func leave() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func presentUnlock(then done: @escaping () -> Void) {
        if ChallengeCreatorAccess.isUnlocked {
            done()
            return
        }
        if let message = getConnection.shared.networkBlockMessage() {
            view.makeToast(message, duration: 2.0, position: .top)
            return
        }
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
        // Challenge profile commented out.
        // if NetworkManager.sharedInstance.isConnectedToInternet() {
        //     let hub = ChallengeCreatorHubView { [weak self] in
        //         self?.navigationController?.popViewController(animated: true)
        //     }
        //     let host = UIHostingController(rootView: hub)
        //     host.view.backgroundColor = .white
        //     navigationController?.setNavigationBarHidden(true, animated: false)
        //     navigationController?.pushViewController(host, animated: true)
        // } else {
        //     view.makeToast("No internet connection", duration: 2.0, position: .top)
        // }
        leave()
    }
}
