//
//  LegacyPaidAppService.swift
//  NKJV Bible
//
//  Detects customers who downloaded the app while it was a PAID app (before the
//  free + paywall model) using StoreKit 2 AppTransaction. Those customers get
//  Lifetime-level access. Purchases, restore and subscriptions are untouched.
//

import Foundation
import StoreKit

final class LegacyPaidAppService {

    static let shared = LegacyPaidAppService()

    private init() {}

    /// 0 keeps the automatic launch check off. The Pro paywall Restore uses the build below.
    private let freeModelStartBuild = 0

    /// Build of this free Pro paywall. A first download below this build paid to install the app.
    static let proPaywallFreeModelStartBuild = 57

    enum LegacyStatus {
        case legacyPaid
        case freeAcquisition
        case unknown
    }

    private let verifiedLegacyKey = "verifiedLegacyPaidApp"
    #if DEBUG
    private let debugForceLegacyKey = "debugForceLegacyPaidApp"
    #endif

    /// Positive result cached from a verified AppTransaction.
    var isLegacyPaidAppUser: Bool {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: debugForceLegacyKey) { return true }
        #endif
        return UserDefaults.standard.bool(forKey: verifiedLegacyKey)
    }

    func refreshAtLaunch() {
        Task { await checkLegacyStatus() }
    }

    /// `forceRefresh` calls `AppTransaction.refresh()` (may prompt sign-in); use only from a user action.
    @discardableResult
    func checkLegacyStatus(forceRefresh: Bool = false) async -> LegacyStatus {
        await checkLegacyStatus(startBuild: freeModelStartBuild, forceRefresh: forceRefresh)
    }

    /// Pro paywall Restore passes `proPaywallFreeModelStartBuild`. Launch stays off while `freeModelStartBuild` is 0.
    @discardableResult
    func checkLegacyStatus(startBuild: Int, forceRefresh: Bool = false) async -> LegacyStatus {
        guard startBuild > 0 else { return .unknown }
        guard #available(iOS 16.0, *) else { return .unknown }

        do {
            let result = forceRefresh ? try await AppTransaction.refresh() : try await AppTransaction.shared
            switch result {
            case .verified(let appTransaction):
                let status = classify(originalVersion: appTransaction.originalAppVersion, startBuild: startBuild)
                store(status)
                return status
            case .unverified(_, let error):
                print("[LegacyPaidApp] Unverified:", error)
                return .unknown
            }
        } catch {
            print("[LegacyPaidApp] Error:", error)
            return .unknown
        }
    }

    private func classify(originalVersion: String, startBuild: Int) -> LegacyStatus {
        print("[LegacyPaidApp] originalAppVersion:", originalVersion, "free model starts:", startBuild)
        guard let originalBuild = Int(originalVersion.trimmingCharacters(in: .whitespaces)) else {
            // Sandbox / TestFlight report "1.0", which is not a build number.
            return .unknown
        }
        return originalBuild < startBuild ? .legacyPaid : .freeAcquisition
    }

    private func store(_ status: LegacyStatus) {
        let wasLegacy = UserDefaults.standard.bool(forKey: verifiedLegacyKey)
        switch status {
        case .legacyPaid:
            UserDefaults.standard.set(true, forKey: verifiedLegacyKey)
        case .freeAcquisition:
            UserDefaults.standard.set(false, forKey: verifiedLegacyKey)
        case .unknown:
            return
        }
        if wasLegacy != (status == .legacyPaid) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("ReloadTable"), object: nil)
            }
        }
    }
}
