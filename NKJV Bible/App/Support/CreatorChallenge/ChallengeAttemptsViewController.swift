//
//  ChallengeAttemptsViewController.swift
//  NKJV Bible
//
//  Settings → Challenge Attempts
//  Lists my challenges, then players who attempted each one.
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
        title = "Challenge Attempts"
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)
        if let bar = navigationController?.navigationBar {
            savedNavBarHidden = navigationController?.isNavigationBarHidden
            savedTintColor = bar.tintColor
            savedStandardAppearance = bar.standardAppearance.copy()
            savedScrollEdgeAppearance = bar.scrollEdgeAppearance?.copy()
        }
        let root = ChallengeAttemptsScreen { [weak self] in
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

private struct ChallengeAttemptsScreen: View {
    var onClose: () -> Void

    @StateObject private var directory = ChallengeCreatorDirectory()
    @State private var selectedId: String?

    var body: some View {
        Group {
            if let selectedId = selectedId,
               let quiz = directory.created.first(where: { $0.id == selectedId }) {
                ChallengeCreatorParticipantsView(
                    quiz: quiz,
                    directory: directory,
                    onBack: { self.selectedId = nil }
                )
            } else {
                ChallengeCreatorQuizListView(
                    title: "Challenge Attempts",
                    quizzes: directory.created,
                    directory: directory,
                    showsFilters: true,
                    onBack: onClose,
                    onOpen: { selectedId = $0.id }
                )
            }
        }
        .onAppear { directory.reload() }
    }
}
