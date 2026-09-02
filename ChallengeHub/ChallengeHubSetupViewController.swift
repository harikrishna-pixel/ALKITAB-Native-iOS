//
//  ChallengeHubSetupViewController.swift
//  NKJV Bible
//

import UIKit
import SwiftUI

final class ChallengeHubSetupViewController: UIViewController {

    var prefillBook: String = ""
    var prefillChapter: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        let root = ChallengeHubSetupView(
            prefillBook: prefillBook,
            prefillChapter: prefillChapter,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onStart: { [weak self] config in
                guard let self else { return }
                let hub = ChallengeHubViewController()
                hub.sessionConfig = config
                self.navigationController?.pushViewController(hub, animated: true)
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
}
