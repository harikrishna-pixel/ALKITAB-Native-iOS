//
//  ChallengeAttemptsViewController.swift
//  NKJV Bible
//
//  Settings → Challenge Attempts
//  Opens the creator profile.
//

import UIKit
import SwiftUI

final class ChallengeAttemptsViewController: UIViewController {

    /// Shared nav bar state from the screen we came from (restored when leaving).
    private var savedNavBarHidden: Bool?
    private var savedTintColor: UIColor?
    private var savedStandardAppearance: UINavigationBarAppearance?
    private var savedScrollEdgeAppearance: UINavigationBarAppearance?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .white
        if let bar = navigationController?.navigationBar {
            savedNavBarHidden = navigationController?.isNavigationBarHidden
            savedTintColor = bar.tintColor
            savedStandardAppearance = bar.standardAppearance.copy()
            savedScrollEdgeAppearance = bar.scrollEdgeAppearance?.copy()
        }
        let root = ChallengeCreatorHubView { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        let host = UIHostingController(rootView: root)
        host.view.backgroundColor = view.backgroundColor
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent, let nav = navigationController else { return }
        if let savedStandardAppearance = savedStandardAppearance {
            nav.navigationBar.standardAppearance = savedStandardAppearance
        }
        nav.navigationBar.scrollEdgeAppearance = savedScrollEdgeAppearance
        nav.navigationBar.tintColor = savedTintColor
        if let savedNavBarHidden = savedNavBarHidden {
            nav.setNavigationBarHidden(savedNavBarHidden, animated: animated)
        }
    }
}
