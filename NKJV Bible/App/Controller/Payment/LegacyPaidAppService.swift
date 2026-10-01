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

    /// CFBundleVersion of the FIRST free (paywall) production release.
    /// 0 disables legacy detection. Set it once before release and never raise it afterwards.
    private let freeModelStartBuild = 0

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
        return freeModelStartBuild > 0 && UserDefaults.standard.bool(forKey: verifiedLegacyKey)
    }

    func refreshAtLaunch() {
        Task { await checkLegacyStatus() }
    }

    /// `forceRefresh` calls `AppTransaction.refresh()` (may prompt sign-in); use only from a user action.
    @discardableResult
    func checkLegacyStatus(forceRefresh: Bool = false) async -> LegacyStatus {
        guard freeModelStartBuild > 0 else { return .unknown }
        guard #available(iOS 16.0, *) else { return .unknown }

        do {
            let result = forceRefresh ? try await AppTransaction.refresh() : try await AppTransaction.shared
            switch result {
            case .verified(let appTransaction):
                let status = classify(originalVersion: appTransaction.originalAppVersion)
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

    private func classify(originalVersion: String) -> LegacyStatus {
        print("[LegacyPaidApp] originalAppVersion:", originalVersion, "free model starts:", freeModelStartBuild)
        guard let originalBuild = Int(originalVersion.trimmingCharacters(in: .whitespaces)) else {
            // Sandbox / TestFlight report "1.0", which is not a build number.
            return .unknown
        }
        return originalBuild < freeModelStartBuild ? .legacyPaid : .freeAcquisition
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
