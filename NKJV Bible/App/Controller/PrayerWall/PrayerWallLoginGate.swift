//
//  PrayerWallLoginGate.swift
//  NKJV Bible
//

import SwiftUI
import UIKit

enum PrayerWallLoginGate {
    static var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: "OnboardingLoggedIn")
    }

    /// If logged in, runs `action` immediately. Otherwise shows a login required alert, then the login sheet.
    static func requireLogin(from viewController: UIViewController, then action: @escaping () -> Void) {
        if isLoggedIn {
            action()
            return
        }

        let alert = UIAlertController(
            title: "Login Required",
            message: "You should login to do this action.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            presentLogin(from: viewController, onSuccess: action)
        }))
        viewController.present(alert, animated: true)
    }

    private static func presentLogin(from viewController: UIViewController, onSuccess: @escaping () -> Void) {
        let loginView = PrayerWallLoginView(
            onSuccess: {
                viewController.dismiss(animated: true) {
                    onSuccess()
                }
            },
            onCancel: {
                viewController.dismiss(animated: true)
            }
        )
        let host = UIHostingController(rootView: loginView)
        host.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = host.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
        viewController.present(host, animated: true)
    }
}
